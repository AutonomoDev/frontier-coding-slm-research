#!/usr/bin/env bash

echo "WARNING!!! This is deprecated!!! Use the Rust ./ollama-runner instead!"
exit 42

# Global variable to store the path of the current output file being processed.
# Used by the cleanup function.
CURRENT_OUTPUT=""

# Function to display usage information and exit.
display_usage() {
    echo "Usage: $0 <DESTINATION> [MAX_ITERATIONS=1]"
    echo "  <DESTINATION>: Path to the run directory (e.g., 'v9/my-run/')."
    echo "                 Must contain a 'vX' pattern for version extraction."
    echo "  [MAX_ITERATIONS]: Optional. Number of times to run the models. Defaults to 1."
    exit 1
}

# Function to parse and validate command-line arguments.
# Sets DESTINATION and MAX_ITERATIONS global variables.
parse_arguments() {
    if [[ $# -lt 1 || $# -gt 2 ]]; then
        display_usage
    fi

    DESTINATION="$1"
    # Default MAX_ITERATIONS to 1 if not provided.
    MAX_ITERATIONS="${2:-1}"

    # Validate MAX_ITERATIONS is a positive integer.
    if ! [[ "$MAX_ITERATIONS" =~ ^[1-9][0-9]*$ ]]; then
        echo "Error: MAX_ITERATIONS must be a positive integer. Got '$MAX_ITERATIONS'."
        exit 1
    fi
}

# Function to extract the version (e.g., 'v9') from the destination path.
# Returns the version string or exits with an error.
extract_version() {
    local dest_path="$1"
    # Use -E for extended regex, + for one or more digits, and head -n 1 for robustness.
    local version=$(echo "$dest_path" | grep -oE 'v[[:digit:]]+' | head -n 1)

    if [[ -z "$version" ]]; then
        echo "Error: Could not determine version (e.g., 'v9') from destination path: $dest_path"
        echo "The destination path must contain a 'vX' pattern, e.g., 'v9/my-run/'."
        exit 1
    fi
    echo "$version" # Return the version
}

# Function to construct and validate required file paths.
# Sets PROMPT_FILE and MODELS_FILE global variables.
setup_paths() {
    local dest="$1"
    local version="$2"

    PROMPT_FILE="$(dirname "$dest")/prompt.${version}.md"
    MODELS_FILE="$dest/models.txt"

    echo "PROMPT FILE: $PROMPT_FILE (Derived from $dest and $version)"
    echo "MODELS File: $MODELS_FILE"

    # Verify that models.txt exists
    if [[ ! -f "$MODELS_FILE" ]]; then
        echo "Error: models.txt file not found at $MODELS_FILE"
        exit 1
    fi

    # Verify that prompt file exists
    if [[ ! -f "$PROMPT_FILE" ]]; then
        echo "Error: Prompt file '$PROMPT_FILE' not found!"
        exit 1
    fi
}

# Function to prepare directories for an iteration.
# Arguments: destination path, iteration number.
prepare_iteration_directory() {
    local dest="$1"
    local iteration_num="$2"
    local iteration_dir="$dest/$iteration_num"

    echo "Preparing directory for iteration $iteration_num: $iteration_dir"
    mkdir -p "$iteration_dir" || { echo "Error: Could not create directory $iteration_dir"; exit 1; }

    # Initialize time log file for this iteration
    touch "$iteration_dir/time.log" || { echo "Error: Could not create time log $iteration_dir/time.log"; exit 1; }
}

# Cleanup function to remove incomplete output files on script termination (e.g., Ctrl+C).
cleanup() {
    if [[ -n "$CURRENT_OUTPUT" && -f "$CURRENT_OUTPUT" ]]; then
        echo "Cleaning up incomplete output file: $CURRENT_OUTPUT"
        rm -f "$CURRENT_OUTPUT"
    fi
    # Exit with a non-zero status code to indicate abnormal termination.
    exit 1
}

# Function to process a single model.
# Arguments: model name, output file base name, destination path, iteration number, version, prompt file.
process_model() {
    local model="$1"
    local output_file_base="$2"
    local dest="$3"
    local iteration_num="$4"
    local version="$5"
    local prompt_file="$6"
    local current_iteration_dir="$dest/$iteration_num"

    # Automatically prepend 'prompt.vX-' to the output filename.
    # Example: if output_file_base is '1.google' and VERSION is 'v9',
    # then prefixed_output_file becomes 'prompt.v9-1.google.sh'.
    local prefixed_output_file="prompt.${version}-${output_file_base}.sh"

    local output_path="$current_iteration_dir/$prefixed_output_file"
    local failed_path="$current_iteration_dir/failed/$prefixed_output_file"
    local passed_path="$current_iteration_dir/passed/$prefixed_output_file"
    local perfect_path="$current_iteration_dir/perfect/$prefixed_output_file" # Added perfect_path
    local time_log_path="$current_iteration_dir/time.log"

    echo "Effective Output file (derived): $prefixed_output_file"

    # Skip if output file already exists (now checking for the prefixed name)
    # Added perfect_path to the check
    if [[ -f "$output_path" || -f "$failed_path" || -f "$passed_path" || -f "$perfect_path" ]]; then
        echo "Skipping $model - output file already exists in output, failed, passed, or perfect directory: $prefixed_output_file"
        return 0 # Return 0 for success to continue the loop
    fi

    echo "Running ollama with model: $model and prompt: $prompt_file"
    echo "Output will be saved to: $output_path"

    # Set CURRENT_OUTPUT globally for cleanup function.
    CURRENT_OUTPUT="$output_path"

    # Run the ollama command with timing and save output to the specified file
    local start_time=$(date +%s)
    if ! ollama run "$model" "$(cat "$prompt_file")" < /dev/null | tee "$output_path"; then
        echo "Error: Command failed for model $model."
        # The trap will call cleanup, so just exit here.
        exit 1
    fi
    local end_time=$(date +%s)

    # Calculate time taken in MM:SS format
    local time_taken=$((end_time - start_time))
    local minutes=$((time_taken / 60))
    local seconds=$((time_taken % 60))
    local formatted_time=$(printf "%02d:%02d" "$minutes" "$seconds")

    # Log the time taken upon successful execution
    echo "$model: $formatted_time" >> "$time_log_path"

    # Clear CURRENT_OUTPUT on successful completion
    CURRENT_OUTPUT=""

    echo "Output saved to $output_path"
    echo "Time taken: $formatted_time"
    echo "----------------------------------------"
}

# Main function to orchestrate the script execution.
main() {
    # Trap signals and errors
    trap cleanup SIGINT SIGTERM ERR

    # Parse arguments
    parse_arguments "$@"

    # Extract version
    VERSION=$(extract_version "$DESTINATION")

    # Setup and validate paths
    setup_paths "$DESTINATION" "$VERSION"

    # Ensure the destination base directory exists
    mkdir -p "$DESTINATION" || { echo "Error: Could not create destination directory $DESTINATION"; exit 1; }

    # Count non-empty lines in MODELS_FILE
    local model_count=$(grep -v '^[[:space:]]*$' "$MODELS_FILE" | wc -l)
    echo "MODELS Count: $model_count"

    # Outer loop for iterations
    local iteration=1
    while [[ "$iteration" -le "$MAX_ITERATIONS" ]]; do
        prepare_iteration_directory "$DESTINATION" "$iteration"

        # Inner loop to process each model from models.txt
        # FIX: Use sed to replace " => " with a unique delimiter like "|"
        # Then use '|' as IFS for read.
        while IFS='|' read -r model_name output_file_base || [[ -n "$model_name" ]]; do
            # Trim whitespace from model_name and output_file_base
            # xargs is still useful for trimming any leading/trailing spaces within the fields themselves
            model_name=$(echo "$model_name" | xargs)
            output_file_base=$(echo "$output_file_base" | xargs)

            # Skip empty lines or lines without a valid model name/output file base after trimming
            if [[ -z "$model_name" || -z "$output_file_base" ]]; then
                continue
            fi

            process_model \
                "$model_name" \
                "$output_file_base" \
                "$DESTINATION" \
                "$iteration" \
                "$VERSION" \
                "$PROMPT_FILE"
        done < <(sed 's/ => /|/' "$MODELS_FILE") # Process substitution for sed output

        ((iteration++))
    done

    echo "All models processed across $MAX_ITERATIONS iterations."
    # Unset trap on successful completion to avoid cleanup being called unnecessarily on exit.
    trap - SIGINT SIGTERM ERR
}

# Call the main function with all command-line arguments.
main "$@"

# Script created by DeepSeek-Coder via deepseek.com and refactored by GPT-4 and then by gemini-2.5-flash.
