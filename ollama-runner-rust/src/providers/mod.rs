use anyhow::Result;
use std::fs::File;

pub mod ollama;

/// Trait for LLM providers (using LLM in all caps per project requirements)
pub trait LLMProvider {
    /// Returns the name of the provider
    fn name(&self) -> &str;

    /// Run a model with the given prompt and write output to file
    /// Returns (duration, tokens_per_second)
    fn run_model(
        &self,
        model_name: &str,
        prompt_content: &str,
        output_file: &mut File,
        check_interrupt: &dyn Fn() -> Result<()>,
    ) -> Result<(std::time::Duration, f64)>;
}