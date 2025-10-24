#!/usr/bin/env bash
# ==== ollama_writer.sh ====
# Executes an Ollama model with a prompt provided via CLI argument, file, or STDIN.
# The model's output is always sent to STDOUT.

# --- Configuration ---
# Set to 1 to enable verbose output, 0 to disable.
VERBOSE=0
SHOW_THOUGHTS=0

# --- Functions ---

# Function to print messages to STDERR only if VERBOSE is enabled.
log_verbose() {
    if [[ "$VERBOSE" -eq 1 ]]; then
        echo "$@" >&2
    fi
}

# Function to print thoughts to STDERR only if SHOW_THOUGHTS is enabled.
log_thought() {
    if [[ "$SHOW_THOUGHTS" -eq 1 ]]; then
        echo "$@" >&2
    fi
}

# Function to display usage information and exit.
display_usage() {
    echo "Usage: $0 [OPTIONS] <MODEL_NAME> [PROMPT_OR_FILE]" >&2
    echo "" >&2
    echo "Executes an Ollama model and prints the output to STDOUT." >&2
    echo "" >&2
    echo "Arguments:" >&2
    echo "  <MODEL_NAME>:     The name of the Ollama model to use (e.g., 'llama3')." >&2
    echo "  [PROMPT_OR_FILE]: Optional. The prompt to use. Can be:" >&2
    echo "                    - A string: 'Summarize this for me.'" >&2
    echo "                    - A path to a text file containing the prompt." >&2
    echo "" >&2
    echo "Options:" >&2
    echo "  --help, -h:       Display this help message and exit." >&2
    echo "  --show-thoughts:  Display processing thoughts/progress to STDERR." >&2
    echo "" >&2
    echo "Input via STDIN:" >&2
    echo "  If [PROMPT_OR_FILE] is omitted, the script will read the prompt from STDIN." >&2
    echo "  - Pipe data: cat my_prompt.txt | $0 llama3" >&2
    echo "  - Interactive: $0 llama3 (you will be prompted to enter text)" >&2
    echo "" >&2
    echo "Example (string):" >&2
    echo "  $0 llama3 'Why is the sky blue?'" >&2
    echo "" >&2
    echo "Example (file):" >&2
    echo "  $0 llama3 ./prompts/my_question.txt" >&2
    echo "" >&2
    echo "Example (pipe):" >&2
    echo "  echo 'Translate to French: Hello World' | $0 llama3" >&2
    echo "" >&2
    echo "Example (redirect output to file):" >&2
    echo "  $0 llama3 'Explain quantum computing' > output.txt" >&2
    echo "" >&2
    echo "Example (with thoughts):" >&2
    echo "  $0 --show-thoughts llama3 'Why is the sky blue?'" >&2
    exit 1
}

# --- Argument Parsing ---

# Parse options
while [[ $# -gt 0 ]]; do
    case "$1" in
        --help|-h)
            display_usage
            ;;
        --show-thoughts)
            SHOW_THOUGHTS=1
            shift
            ;;
        -*)
            echo "Error: Unknown option '$1'" >&2
            display_usage
            ;;
        *)
            # First non-option argument is the model name
            break
            ;;
    esac
done

# --- Argument Validation ---

if [[ $# -lt 1 || $# -gt 2 ]]; then
    echo "Error: Invalid number of arguments." >&2
    display_usage
fi

MODEL_NAME="$1"

# Check if ollama command exists
if ! command -v ollama &> /dev/null; then
    echo "Error: 'ollama' command not found. Please ensure Ollama is installed and in your PATH." >&2
    exit 1
fi

# --- Prompt Acquisition ---
prompt_content=""

if [[ $# -eq 2 ]]; then
    # Case 1: Prompt from the second command-line argument (file path or literal string).
    PROMPT_ARG="$2"
    log_thought "Attempting to use '$PROMPT_ARG' as prompt source..."
    if [[ -f "$PROMPT_ARG" ]]; then
        # It's a file, try to read it.
        log_thought "Source is a file. Reading content..."
        if ! prompt_content=$(<"$PROMPT_ARG"); then
            echo "Error: Failed to read prompt file '$PROMPT_ARG'." >&2
            exit 1
        fi
    else
        # It's not a file, treat it as a literal string.
        log_thought "Source is a string."
        prompt_content="$PROMPT_ARG"
    fi
else
    # Case 2: No second argument, read from STDIN.
    if [[ -t 0 ]]; then
        # STDIN is a terminal (interactive mode). Prompt the user.
        echo "Enter prompt, press CTRL+D when finished:" >&2
        prompt_content=$(cat)
    else
        # STDIN is a pipe or redirection. Read it silently.
        log_thought "Reading prompt from STDIN..."
        prompt_content=$(cat)
    fi
fi

# Final check to ensure we have a prompt from one of the sources.
if [[ -z "$prompt_content" ]]; then
    echo "Error: Prompt is empty. Nothing to do." >&2
    exit 1
fi

# --- Core Ollama Execution Logic ---

log_thought "--- Starting Ollama Execution ---"
log_thought "Model:       $MODEL_NAME"
# Send status messages to STDERR to keep STDOUT clean for the model's response.
if [[ "$SHOW_THOUGHTS" -eq 1 ]]; then
    echo "Running '$MODEL_NAME'..." >&2
fi

# Record start time
start_time=$(date +%s)

# Execute the ollama run command.
# - Pass the prompt content as the second argument.
# - The model's output will go directly to this script's STDOUT.
if ! ollama run "$MODEL_NAME" "$prompt_content"; then
    echo "Error: Ollama command failed for model '$MODEL_NAME'." >&2
    exit 1
fi

# Record end time and calculate duration
end_time=$(date +%s)
time_taken=$((end_time - start_time))
minutes=$((time_taken / 60))
seconds=$((time_taken % 60))
formatted_time=$(printf "%02d:%02d" "$minutes" "$seconds")

log_thought "---------------------------------"
log_thought "Ollama command completed successfully."
log_thought "Time taken: $formatted_time"

# Exit cleanly
exit 0
