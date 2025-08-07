#!/bin/env bash

# Check for correct number of arguments
if [[ $# -ne 3 ]]; then
    echo "Usage: $0 <DESTINATION> <PROMPT_FILE> <MAX_ITERATIONS>"
    exit 1
fi

DESTINATION="$1"
PROMPT_FILE="$2"
MAX_ITERATIONS="$3"

# Check for models.txt in the parent directory of DESTINATION
MODELS_FILE="$DESTINATION/models.txt"
if [[ ! -f "$MODELS_FILE" ]]; then
    echo "Error: models.txt file not found at $MODELS_FILE"
    exit 1
fi

# Verify that prompt file exists
if [[ ! -f "$PROMPT_FILE" ]]; then
    echo "Error: Prompt file '$PROMPT_FILE' not found!"
    exit 1
fi

# Ensure the destination directory exists
    mkdir -p "$DESTINATION"

# Count non-empty lines in MODELS_FILE
MODEL_COUNT=$(grep -v '^[[:space:]]*$' "$MODELS_FILE" | wc -l)

ITERATION=1
# Check if any iterations exist
if [ ! -d "$DESTINATION/1" ]; then
    # No iterations exist, create first one
    mkdir "$DESTINATION/$ITERATION"
fi

# Cleanup function to remove incomplete output
cleanup() {
    if [[ -n "$CURRENT_OUTPUT" && -f "$CURRENT_OUTPUT" ]]; then
        echo "Cleaning up incomplete output file: $CURRENT_OUTPUT"
        rm -f "$CURRENT_OUTPUT"
    fi
    exit 1
}

# Trap signals and errors
trap cleanup SIGINT SIGTERM ERR

while [[ $ITERATION -le $MAX_ITERATIONS ]]; do
    if [ ! -d "$DESTINATION/$ITERATION" ]; then
        mkdir -p "$DESTINATION/$ITERATION"
    fi

    # Initialize time log file
    TIME_LOG="$DESTINATION/$ITERATION/time.log"
    touch "$TIME_LOG"


    # Process each model in models.txt
    while IFS='=>' read -r model _ output_file; do
        model=$(echo "$model" | xargs)
        output_file=$(echo "$output_file" | xargs)
        #echo "$model -> $output_file"; continue;

        # Skip empty lines or invalid entries
        if [[ -z "$model" ]]; then
            continue
        fi

        CURRENT_OUTPUT="$DESTINATION/$ITERATION/$output_file"
        FAILED_OUTPUT="$DESTINATION/$ITERATION/failed/$output_file"
        PASSED_OUTPUT="$DESTINATION/$ITERATION/passed/$output_file"

        # Skip if output file already exists
        if [[ -f "$CURRENT_OUTPUT" || -f "$FAILED_OUTPUT" || -f "$PASSED_OUTPUT" ]]; then
            echo "Skipping $model - output file already exists: $CURRENT_OUTPUT"
            continue
        fi

        echo "Running ollama with model: $model and prompt: $PROMPT_FILE"
        echo "Output will be saved to: $CURRENT_OUTPUT"

        # Run the ollama command with timing and save output to the specified file
        start_time=$(date +%s)
        if ! ollama run "$model" "$(cat "$PROMPT_FILE")" < /dev/null | tee "$CURRENT_OUTPUT"; then

            echo "Error: Command failed for model $model"
            cleanup
        fi
        end_time=$(date +%s)

        # Calculate time taken in MM:SS format
        time_taken=$((end_time - start_time))
        minutes=$((time_taken / 60))
        seconds=$((time_taken % 60))
        TIME_TAKEN=$(printf "%02d:%02d" "$minutes" "$seconds")

        # Log the time taken upon successful execution
        echo "$model: $TIME_TAKEN" >> "$TIME_LOG"

        # Clear CURRENT_OUTPUT on successful completion
        unset CURRENT_OUTPUT

        echo "Output saved to $CURRENT_OUTPUT"
        echo "Time taken: $TIME_TAKEN"
        echo "----------------------------------------"
    done < "$MODELS_FILE"

    ((ITERATION++))
done

echo "All models processed."

# Script created by DeepSeek-Coder via deepseek.com.
