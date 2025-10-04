#!/usr/bin/env bash

# A script to send a file to an OpenRouter LLM for refactoring into a functional Bash script.
# Streams the model output live (token-by-token) while writing to a temporary file.
# Includes automatic syntax checking and retry with different models on failure.

set -e
set -o pipefail

# --- Configuration ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FETCH_SCRIPT="${SCRIPT_DIR}/openrouter-fetch.sh"
PARSE_SCRIPT="${SCRIPT_DIR}/openrouter-parse.sh"

DEFAULT_MODEL="anthropic/claude-sonnet-4.5"

MODEL_POOL=(
    "google/gemini-2.5-flash"
    "deepseek/deepseek-v3.2-exp"
    "openai/gpt-5-mini"
    "x-ai/grok-code-fast-1"
    "google/gemini-2.5-pro"
)

# System prompt for the LLM
SYSTEM_PROMPT="You are an expert Bash programmer. Your task is to rewrite the user-provided text file into a functional, clean, and valid Bash script. You must follow the user's rules precisely."

# --- Function Definitions ---

usage() {
    echo "Usage: $0 <input_file_path> [initial_model_name] [--show-prompt]" >&2
    echo "" >&2
    echo "Arguments:" >&2
    echo "  <input_file_path>     : Path to the file to be refactored" >&2
    echo "  [initial_model_name]  : First LLM model to try (default: $DEFAULT_MODEL)" >&2
    echo "  --show-prompt         : Display the prompt and exit without executing" >&2
    exit 1
}

check_bash_syntax() {
    local script_file="$1"
    if bash -n "$script_file" >/dev/null 2>&1; then
        echo "✅ Syntax check passed for $script_file"
        return 0
    else
        echo "❌ Syntax check FAILED for $script_file"
        bash -n "$script_file" 2>&1 | head -n 5
        return 1
    fi
}

call_openrouter() {
    local model="$1"
    local input_file="$2"
    local temp_output_file="$3"
    local show_prompt_flag="$4"

    echo "🔄 Attempting with model: $model"

    local file_content
    file_content=$(<"$input_file")

    local user_prompt="Rules:
You are an expert Bash programmer. Rewrite the user's text into a valid Bash script following these **strictly ordered** rules:

1. **Marker processing first**:
   - For all lines *strictly between* \`Thinking...\` and \`...done thinking\`:
     → Prepend '#' to each line (comment them out)
   - For all lines *strictly between* \`<think>\` and \`</think>\`:
     → Prepend '#' to each line (comment them out)
   - **Keep the marker lines themselves, but commented out.**

2. **Code fence handling**:
   - Remove any standalone lines beginning with \`\`\` from the input
   - The final output must be plain text Bash script with NO formatting markers
   - Do NOT add \`\`\`bash, \`\`\`sh, or any other code fence markers to the output

3. **General non-Bash text**:
   For any remaining non-Bash text (not covered by Rule 1):
   → Comment it out with \`# [[HUMAN COMMENTED-OUT]]\` on the first line of the block

--- FILE TO REWRITE ---
\`\`\`
${file_content}
\`\`\`"

    # Reset the temp file
    : > "$temp_output_file"

    # Build the fetch command with optional --show-prompt flag
    local fetch_cmd=("$FETCH_SCRIPT" "$model" "$user_prompt" "true" "$SYSTEM_PROMPT")
    if [[ -n "$show_prompt_flag" ]]; then
        fetch_cmd+=("$show_prompt_flag")
        # Execute and exit (no piping to parse script)
        "${fetch_cmd[@]}"
        exit 0
    fi

    # Normal execution: pipe to parser, filtering out code fence lines (```), even with leading whitespace.
    if ! "${fetch_cmd[@]}" | "$PARSE_SCRIPT" "$temp_output_file"; then
        echo "❌ API call or parsing failed for model $model" >&2
        return 1
    fi

    if [[ ! -s "$temp_output_file" ]]; then
        echo "❌ Output file is empty after API call for model $model." >&2
        return 1
    fi

    return 0
}

shuffle_models() {
    if command -v shuf >/dev/null 2>&1; then
        printf "%s\n" "$@" | shuf
    else
        printf "%s\n" "$@" | sort -R
    fi
}

handle_final_result() {
    local success="$1"
    local attempt_num="$2"
    local current_model="$3"
    local input_file="$4"
    local temp_output_file="$5"
    local max_attempts="$6"

    echo ""

    if [[ "$success" == true ]]; then
        local orig_backup="${input_file}.orig"
        echo "🎉 SUCCESS! Valid script generated on attempt $attempt_num with model: $current_model"
        echo "🔃 Renaming original '$input_file' to '$orig_backup'"
        mv "$input_file" "$orig_backup"
        echo "✅ Moving temporary output to '$input_file'"
        mv "$temp_output_file" "$input_file"
        echo "📄 New script saved as: $input_file"
        echo "💡 Make it executable with: chmod +x $input_file"
    else
        echo "💥 CRITICAL FAILURE: All $max_attempts attempts failed."
        [[ -f "$temp_output_file" ]] && rm -f "$temp_output_file"
        if rm -f "$input_file"; then
            echo "🗑️  Original input file '$input_file' has been deleted."
        fi
        exit 1
    fi
}

# --- Parse Arguments ---

INPUT_FILE=""
INITIAL_MODEL=""
SHOW_PROMPT_FLAG=""

for arg in "$@"; do
    if [[ "$arg" == "--show-prompt" ]]; then
        SHOW_PROMPT_FLAG="--show-prompt"
    elif [[ -z "$INPUT_FILE" ]]; then
        INPUT_FILE="$arg"
    elif [[ -z "$INITIAL_MODEL" ]]; then
        INITIAL_MODEL="$arg"
    fi
done

# --- Prerequisite Checks ---

if [[ -z "$INPUT_FILE" ]]; then
    echo "Error: Input file not specified." >&2
    usage
fi

INITIAL_MODEL="${INITIAL_MODEL:-$DEFAULT_MODEL}"

# Check for helper scripts
if [[ ! -x "$FETCH_SCRIPT" ]]; then
    echo "Error: Fetch script not found or not executable: $FETCH_SCRIPT" >&2
    echo "Make sure openrouter-fetch.sh is in the same directory and executable." >&2
    exit 1
fi

if [[ ! -x "$PARSE_SCRIPT" ]]; then
    echo "Error: Parse script not found or not executable: $PARSE_SCRIPT" >&2
    echo "Make sure openrouter-parse.sh is in the same directory and executable." >&2
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo "Error: This script requires 'jq'. Please install it." >&2
    exit 1
fi

if [[ -z "${OPENROUTER_API_KEY:-}" ]]; then
    echo "Error: OPENROUTER_API_KEY environment variable is not set." >&2
    exit 1
fi

if [[ ! -f "$INPUT_FILE" ]]; then
    echo "Error: Input file not found: '$INPUT_FILE'" >&2
    exit 1
fi

ORIG_BACKUP_FILE="${INPUT_FILE}.orig"
if [[ -f "$ORIG_BACKUP_FILE" ]] && [[ -z "$SHOW_PROMPT_FLAG" ]]; then
    echo "Note: Skipping '$INPUT_FILE' - backup file already exists: '$ORIG_BACKUP_FILE'"
    exit 0
fi

TEMP_OUTPUT_FILE="${INPUT_FILE}.tmp"

# --- Main Execution ---

echo "🔄 Starting script reform process..."
echo "📁 Input file: $INPUT_FILE"
echo "🤖 Initial model: $INITIAL_MODEL"

# If --show-prompt, just show it and exit (happens inside call_openrouter)
if [[ -n "$SHOW_PROMPT_FLAG" ]]; then
    call_openrouter "$INITIAL_MODEL" "$INPUT_FILE" "$TEMP_OUTPUT_FILE" "$SHOW_PROMPT_FLAG"
    exit 0
fi

max_attempts=$((${#MODEL_POOL[@]} + 1))
success=false
current_model=""

shuffled_pool=()
mapfile -t shuffled_pool < <(shuffle_models "${MODEL_POOL[@]}")
models_to_try=("$INITIAL_MODEL" "${shuffled_pool[@]}")

for i in "${!models_to_try[@]}"; do
    current_model="${models_to_try[i]}"
    attempt_num=$((i + 1))

    echo ""
    echo "--- Attempt $attempt_num of $max_attempts ---"

    if call_openrouter "$current_model" "$INPUT_FILE" "$TEMP_OUTPUT_FILE" ""; then
        echo "📡 API call completed. Checking syntax..."
        if check_bash_syntax "$TEMP_OUTPUT_FILE"; then
            success=true
            break
        else
            echo "🔄 Syntax check failed. Will retry with different model..."
            rm -f "$TEMP_OUTPUT_FILE"
        fi
    else
        echo "🔄 API call failed. Will retry..."
    fi

    if [[ $attempt_num -lt $max_attempts ]]; then
        echo "⏳ Waiting 2 seconds..."
        sleep 2
    fi
done

handle_final_result "$success" "$attempt_num" "$current_model" "$INPUT_FILE" "$TEMP_OUTPUT_FILE" "$max_attempts"
