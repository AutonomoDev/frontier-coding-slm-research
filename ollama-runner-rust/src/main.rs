// Cargo.toml dependencies for this refactored version:
// [dependencies]
// anyhow = "1.0"
// clap = { version = "4.5", features = ["derive"] }
// ctrlc = "3.4"
// regex = "1.10"

use anyhow::{Context, Result};
use clap::Parser;
use regex::Regex;
use std::{
    fs::{self, File, OpenOptions},
    io::{self, Read, Write},
    path::{Path, PathBuf},
    process::{Command, Stdio},
    sync::{
        atomic::{AtomicBool, Ordering},
        Mutex,
    },
    time::Instant,
};

// Global atomic flag for signal handling
static SHOULD_CLEANUP: AtomicBool = AtomicBool::new(false);

// Global mutex-protected path to track the current output file being processed
static CURRENT_OUTPUT: Mutex<Option<PathBuf>> = Mutex::new(None);

// Function to setup signal handler for CTRL+C and termination
fn setup_signal_handler() -> Result<()> {
    ctrlc::set_handler(|| {
        eprintln!("\nReceived interrupt signal, cleaning up...");
        SHOULD_CLEANUP.store(true, Ordering::SeqCst);

        // Perform cleanup
        cleanup_current_output();

        std::process::exit(1);
    })
    .context("Failed to set up signal handler")
}

// Function to clean up the current output file if it exists
fn cleanup_current_output() {
    if let Ok(mut current) = CURRENT_OUTPUT.lock() {
        if let Some(path) = current.take() {
            if path.exists() {
                eprintln!("Cleaning up incomplete output file: {}", path.display());
                let _ = fs::remove_file(&path);
            }
        }
    }
}

// Function to set the current output file being processed
fn set_current_output(path: PathBuf) {
    if let Ok(mut current) = CURRENT_OUTPUT.lock() {
        *current = Some(path);
    }
}

// Function to clear the current output file (on successful completion)
fn clear_current_output() {
    if let Ok(mut current) = CURRENT_OUTPUT.lock() {
        *current = None;
    }
}

// CLI argument parser
#[derive(Parser, Debug)]
#[command(version, about = "Run Ollama models with prompts across iterations", long_about = None)]
struct Args {
    /// Path to the run directory (e.g., 'v9/my-run/'). Must contain a 'vX' pattern for version extraction.
    destination: String,

    /// Number of times to run the models. Defaults to 1. Must be a positive integer without leading zeros.
    #[arg(default_value = "1")]
    max_iterations: String,
}

// Validate max_iterations: positive integer, no leading zeros for multi-digit.
fn validate_max_iterations(iter_str: &str) -> Result<usize> {
    if iter_str.is_empty() {
        anyhow::bail!("MAX_ITERATIONS cannot be empty.");
    }
    if iter_str == "0" {
        anyhow::bail!("MAX_ITERATIONS must be a positive integer. Got '0'.");
    }
    if iter_str.len() > 1 && iter_str.starts_with('0') {
        anyhow::bail!("MAX_ITERATIONS cannot have leading zeros for multi-digit numbers. Got '{}'.", iter_str);
    }
    if !iter_str.chars().all(char::is_numeric) {
        anyhow::bail!("MAX_ITERATIONS must be a positive integer. Got '{}'.", iter_str);
    }
    iter_str.parse::<usize>().context("Failed to parse MAX_ITERATIONS")
}

// Parse and validate command-line arguments using Clap.
fn parse_arguments() -> Result<(String, usize)> {
    let args = Args::parse();
    let max_iterations = validate_max_iterations(&args.max_iterations)?;
    Ok((args.destination, max_iterations))
}

// Function to extract the version (e.g., 'v9') from the destination path using regex.
// Matches the first 'v[0-9]+' pattern.
fn extract_version(dest_path: &str) -> Result<String> {
    let re = Regex::new(r"v[0-9]+").context("Failed to compile regex for version extraction")?;
    let version = re
        .find(dest_path)
        .map(|m| m.as_str().to_string())
        .context(format!(
            "Could not determine version (e.g., 'v9') from destination path: {}. The destination path must contain a 'vX' pattern, e.g., 'v9/my-run/'.",
            dest_path
        ))?;

    // Double-check: starts with 'v' and rest are digits
    if !version.starts_with('v') || version[1..].chars().any(|c| !c.is_ascii_digit()) {
        anyhow::bail!("Extracted version '{}' is invalid: must be 'v' followed by digits.", version);
    }

    Ok(version)
}

// Function to construct and validate required file paths.
// Returns (PROMPT_FILE_PATH, MODELS_FILE_PATH)
fn setup_paths(dest: &str, version: &str) -> Result<(PathBuf, PathBuf)> {
    let dest_path_buf = PathBuf::from(dest);
    let parent_dir = dest_path_buf
        .parent()
        .context(format!("Invalid destination path: {}. Could not determine parent directory.", dest))?;

    let prompt_file = parent_dir.join(format!("prompt.{}.md", version));
    let models_file = dest_path_buf.join("models.txt");

    println!("PROMPT FILE: {} (Derived from {} and {})", prompt_file.display(), dest, version);
    println!("MODELS File: {}", models_file.display());

    // Verify that models.txt exists
    if !models_file.is_file() {
        anyhow::bail!("models.txt file not found at {}", models_file.display());
    }

    // Verify that prompt file exists
    if !prompt_file.is_file() {
        anyhow::bail!("Prompt file '{}' not found!", prompt_file.display());
    }

    Ok((prompt_file, models_file))
}

// Struct to hold a model entry
#[derive(Debug, Clone)]
struct ModelEntry {
    name: String,
    output_file_base: String,
}

// Parse models from the file into a Vec<ModelEntry>
fn parse_models(models_file: &Path) -> Result<Vec<ModelEntry>> {
    let content = fs::read_to_string(models_file).context("Failed to read models.txt")?;
    let models: Vec<ModelEntry> = content
        .lines()
        .filter_map(|line| {
            let trimmed = line.trim();
            if trimmed.is_empty() {
                return None;
            }
            if let Some((model_name, output_file_base)) = trimmed.split_once(" => ") {
                let model_name_trimmed = model_name.trim();
                let output_file_base_trimmed = output_file_base.trim();
                if !model_name_trimmed.is_empty() && !output_file_base_trimmed.is_empty() {
                    return Some(ModelEntry {
                        name: model_name_trimmed.to_string(),
                        output_file_base: output_file_base_trimmed.to_string(),
                    });
                }
            }
            None
        })
        .collect();

    println!("MODELS Count: {}", models.len());
    Ok(models)
}

// Function to prepare directories for an iteration.
// Arguments: destination path, iteration number.
fn prepare_iteration_directory(dest: &Path, iteration_num: usize) -> Result<PathBuf> {
    let iteration_dir = dest.join(iteration_num.to_string());
    println!("Preparing directory for iteration {}: {}", iteration_num, iteration_dir.display());
    fs::create_dir_all(&iteration_dir).context("Failed to create iteration directory")?;

    Ok(iteration_dir)
}

// Check for cleanup signal and return Err if set
fn check_interrupt() -> Result<()> {
    if SHOULD_CLEANUP.load(Ordering::SeqCst) {
        Err(anyhow::anyhow!("Interrupted by user"))
    } else {
        Ok(())
    }
}

// Format duration as MM:SS
fn format_duration(duration: std::time::Duration) -> String {
    let total_seconds = duration.as_secs();
    let minutes = total_seconds / 60;
    let seconds = total_seconds % 60;
    format!("{:02}:{:02}", minutes, seconds)
}

// Function to process a single model.
fn process_model(
    model: &ModelEntry,
    dest: &Path,
    iteration_num: usize,
    version: &str,
    prompt_file: &Path,
    time_log_path: &Path,
) -> Result<()> {
    let current_iteration_dir = dest.join(iteration_num.to_string());

    // Automatically prepend 'prompt.vX-' to the output filename.
    let prefixed_output_file_name = format!("prompt.{}-{}.sh", version, model.output_file_base);

    let output_path = current_iteration_dir.join(&prefixed_output_file_name);
    let failed_path = current_iteration_dir.join("failed").join(&prefixed_output_file_name);
    let passed_path = current_iteration_dir.join("passed").join(&prefixed_output_file_name);
    let perfect_path = current_iteration_dir.join("perfect").join(&prefixed_output_file_name);

    println!("Effective Output file (derived): {}", prefixed_output_file_name);

    // Skip if output file already exists in any relevant directory
    if output_path.exists() || failed_path.exists() || passed_path.exists() || perfect_path.exists() {
        println!(
            "Skipping {} - output file already exists in output, failed, passed, or perfect directory: {}",
            model.name, prefixed_output_file_name
        );
        return Ok(());
    }

    // Check for interrupt before starting
    check_interrupt()?;

    println!(
        "Running ollama with model: {} and prompt: {}",
        model.name,
        prompt_file.display()
    );
    println!("Output will be saved to: {}", output_path.display());

    let prompt_content = fs::read_to_string(prompt_file).context("Failed to read prompt file")?;

    // Create the output file early, so we can write to it immediately.
    let mut output_file = File::create(&output_path).context("Failed to create output file")?;

    // Set the current output file for cleanup purposes
    set_current_output(output_path.clone());

    let start_time = Instant::now();

    // Spawn the `ollama` command with stdout piped for `tee` behavior
    let mut command = Command::new("ollama")
        .arg("run")
        .arg(&model.name)
        .arg(&prompt_content)
        .stdin(Stdio::null()) // Equivalent to < /dev/null
        .stdout(Stdio::piped())
        .stderr(Stdio::inherit()) // Inherit stderr to see ollama's error messages immediately
        .spawn()
        .context(format!("Failed to spawn ollama for model {}", model.name))?;

    // Get the stdout pipe from the child process
    let stdout = command
        .stdout
        .take()
        .context("Child process did not have a stdout handle")?;
    let mut reader = std::io::BufReader::new(stdout);
    let mut buffer = [0; 1024]; // Use a fixed-size buffer for reading chunks

    // Read from ollama's stdout and write to both console and file (tee behavior)
    loop {
        // Check for interrupt during processing
        check_interrupt()?;

        let bytes_read = reader.read(&mut buffer).context("Failed to read from ollama stdout")?;

        if bytes_read == 0 {
            break; // EOF
        }

        let data_slice = &buffer[..bytes_read];

        // Write to stdout
        io::stdout().write_all(data_slice)?;
        io::stdout().flush()?;

        // Write to output file
        output_file.write_all(data_slice)?;
        output_file.flush()?;
    }

    let status = command
        .wait()
        .context(format!("Failed to wait for ollama process for model {}", model.name))?;

    if !status.success() {
        // Clean up incomplete output file on command failure
        cleanup_current_output();
        anyhow::bail!(
            "ollama command failed for model {}. Exit status: {:?}",
            model.name,
            status.code()
        );
    }

    let end_time = Instant::now();
    let time_taken = end_time.duration_since(start_time);
    let formatted_time = format_duration(time_taken);

    // Log the time taken upon successful execution
    let mut time_log_file = OpenOptions::new()
        .append(true)
        .create(true)
        .open(time_log_path)
        .context("Failed to open time.log for appending")?;
    writeln!(time_log_file, "{}: {}", model.name, formatted_time)?;

    // Clear the current output file since processing completed successfully
    clear_current_output();

    println!("Output saved to {}", output_path.display());
    println!("Time taken: {}", formatted_time);
    println!("----------------------------------------");

    Ok(())
}

fn main() -> Result<()> {
    // Setup signal handler for proper cleanup
    setup_signal_handler()?;

    // Parse arguments
    let (destination, max_iterations) = parse_arguments()?;
    let dest_path_obj = PathBuf::from(&destination);

    // Extract version
    let version = extract_version(&destination)?;

    // Setup and validate paths
    let (prompt_file, models_file) = setup_paths(&destination, &version)?;

    // Ensure the destination base directory exists
    fs::create_dir_all(&dest_path_obj).context("Failed to create destination directory")?;

    // Parse models once
    let models = parse_models(&models_file)?;

    // Outer loop for iterations
    for iteration in 1..=max_iterations {
        // Check for interrupt before starting iteration
        if let Err(e) = check_interrupt() {
            eprintln!("{}", e);
            cleanup_current_output();
            return Err(e);
        }

        // prepare_iteration_directory creates the iteration directory and time.log
        let _iteration_dir = prepare_iteration_directory(&dest_path_obj, iteration)?;
        let time_log_path = _iteration_dir.join("time.log");

        // Inner loop to process each model
        for model in &models {
            // Check for interrupt during model processing
            if let Err(e) = check_interrupt() {
                eprintln!("{}", e);
                cleanup_current_output();
                return Err(e);
            }

            if let Err(e) = process_model(
                model,
                &dest_path_obj,
                iteration,
                &version,
                &prompt_file,
                &time_log_path,
            ) {
                eprintln!("Error processing model: {}", e);
                cleanup_current_output();
                return Err(e);
            }
        }
    }

    println!("All models processed across {} iterations.", max_iterations);
    Ok(())
}

// Created by Gemini 2.5-flash.
// Refactored by Grok 4-Fast, built by xAI.
// Cleanup functionality by Anthropic Claude 4.5 Sonnet.