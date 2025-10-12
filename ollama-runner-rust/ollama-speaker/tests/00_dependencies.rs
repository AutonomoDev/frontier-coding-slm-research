// ==== tests/00_dependencies.rs ====

//! Integration test module to ensure Ollama CLI and required models are available.
//! This test runs first (by convention) and will panic if dependencies are missing,
//! preventing other integration tests from running unnecessarily.

use anyhow::{Context, Result};
use std::process::{Command, Stdio};

/// Checks if the Ollama CLI is installed, in the PATH, and if the 'gemma3:270m' model is available.
/// Panics with a descriptive error message if any check fails.
#[test]
fn check_ollama_and_model_availability() {
    println!("\n--- Running dependency checks ---");
    println!("Checking for Ollama CLI and 'gemma3:270m' model...");

    // 1. Check if 'ollama' command exists and runs
    let ollama_version_output = Command::new("ollama")
        .arg("--version")
        // Capture stdout and stderr to provide detailed error messages if the command fails
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .output() // Use .output() to spawn, wait, and capture output in one step
        .with_context(|| {
            "Failed to execute 'ollama --version'. \
             Ensure Ollama is installed and its executable is in your system's PATH."
        })
        .expect("Ollama CLI check failed during execution");

    if !ollama_version_output.status.success() {
        let stderr = String::from_utf8_lossy(&ollama_version_output.stderr);
        panic!(
            "Ollama command failed with status: {}. Stderr: '{}'\n\
             Please ensure Ollama is installed correctly and is accessible via your PATH.",
            ollama_version_output.status, stderr
        );
    }
    println!("✅ Ollama CLI found.");

    // 2. Check if 'gemma3:270m' model is available by attempting a minimal run.
    //    We use the correct arguments now: ollama run <model> <prompt>
    let mut model_check_command = Command::new("ollama");
    model_check_command.arg("run")
           .arg("gemma3:270m")
        // Removed incorrect flags: .arg("--quiet"), .arg("-p")
           .arg("test") // Correctly passing the prompt as a positional argument
           .stdin(Stdio::null()) // No stdin needed
           .stdout(Stdio::piped()) // Capture stdout
           .stderr(Stdio::piped()); // Capture stderr for error reporting

    // Spawn the process
    let mut child = model_check_command.spawn()
        .with_context(|| "Failed to spawn 'ollama run gemma3:270m'. Ensure Ollama is installed and in PATH.")
        .expect("Ollama model check spawn failed");

    // Wait for the command to finish and capture its output and status
    let output = child.wait_with_output()
        .context("Failed to wait for 'ollama run gemma3:270m' process")
        .expect("Ollama model check wait failed");

    // Check the exit status
    if !output.status.success() {
        // Format stderr nicely for the panic message
        let stderr = String::from_utf8_lossy(&output.stderr);
        panic!(
            "Ollama model 'gemma3:270m' check failed with status: {}. \
             Ensure the model is downloaded ('ollama pull gemma3:270m') and the Ollama server is running.\n\
             Ollama stderr:\n'{}'",
            output.status, stderr
        );
    }

    // If we reach here, the command ran successfully.
    println!("✅ Model 'gemma3:270m' is available and functional.");
    println!("--- Dependency checks passed. Proceeding with integration tests... ---\n");
}
