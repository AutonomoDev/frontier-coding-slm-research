// Ollama-specific provider implementation

use anyhow::{Context, Result};
use std::{
    fs::File,
    io::{self, Read, Write},
    process::{Command, Stdio},
    time::Instant,
};
use llm_metrics::{LlmMetrics, estimate_tokens};

use super::LLMProvider;

pub struct OllamaProvider;

impl OllamaProvider {
    pub fn new() -> Self {
        OllamaProvider
    }
}

impl LLMProvider for OllamaProvider {
    fn name(&self) -> &str {
        "Ollama"
    }

    fn run_model(
        &self,
        model_name: &str,
        prompt_content: &str,
        output_file: &mut File,
        check_interrupt: &dyn Fn() -> Result<()>,
    ) -> Result<(std::time::Duration, f64)> {
        let start_time = Instant::now();

        // Initialize metrics tracker
        let metrics = LlmMetrics::new().context("Failed to initialize metrics")?;

        let mut command = Command::new("ollama")
            .arg("run")
            .arg(model_name)
            .arg(prompt_content)
            .stdin(Stdio::null())
            .stdout(Stdio::piped())
            .stderr(Stdio::inherit())
            .spawn()
            .context(format!("Failed to spawn ollama for model {}", model_name))?;

        let stdout = command
            .stdout
            .take()
            .context("Child process did not have a stdout handle")?;
        let mut reader = std::io::BufReader::new(stdout);
        let mut buffer = [0; 1024];

        loop {
            check_interrupt()?;

            let bytes_read = reader.read(&mut buffer).context("Failed to read from ollama stdout")?;

            if bytes_read == 0 {
                break;
            }

            let data_slice = &buffer[..bytes_read];

            // Write to stdout
            io::stdout().write_all(data_slice)?;
            io::stdout().flush()?;

            // Write to output file
            output_file.write_all(data_slice)?;
            output_file.flush()?;

            // Update metrics with token estimate
            if let Ok(text) = std::str::from_utf8(data_slice) {
                let tokens = estimate_tokens(text);
                metrics.add_tokens(tokens);
            }

            // Display metrics in lower-right corner
            metrics.display()?;
        }

        // Clear metrics display before final output
        metrics.clear()?;

        let status = command
            .wait()
            .context(format!("Failed to wait for ollama process for model {}", model_name))?;

        if !status.success() {
            anyhow::bail!(
                "ollama command failed for model {}. Exit status: {:?}",
                model_name,
                status.code()
            );
        }

        let end_time = Instant::now();
        let time_taken = end_time.duration_since(start_time);
        let tokens_per_sec = metrics.tokens_per_second();

        Ok((time_taken, tokens_per_sec))
    }
}