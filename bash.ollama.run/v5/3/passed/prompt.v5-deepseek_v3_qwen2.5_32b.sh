# Here is a robust Bash completion script for `ollama run` command.
#
# The script provides autocompletion for model names based on the output of `ollama list`.
# It ensures correct triggering, precise parsing, contextual filtering, and avoids common mistakes.

_ollama_run_completion() {
    # Check if the current word is being completed
    local cur="${COMP_WORDS[COMP_CWORD]}"

    # Ensure completion only activates for the run subcommand
    if [[ "${COMP_WORDS[1]}" == "run" ]]; then
        # Get list of models from ollama list output, skipping header and taking first column
        local models=$(ollama list | awk 'NR>1 {print $1}' 2>/dev/null)

        # Split the model names into an array
        IFS=$'\n' read -r -d '' -a models_array <<< "$models"

        # Filter models based on current input (case-sensitive)
        COMPREPLY=($(compgen -W "${models_array[*]}" -- "$cur"))
    fi
}

# Complete ollama's run subcommand with model names
complete -F _ollama_run_completion ollama

# To enable this completion, source the script:
#   source my_script.sh

# [[HUMAN COMMENTED-OUT]]
#### Explanation:
#1. **Triggering Condition**: The script checks if the second word (`${COMP_WORDS[1]}`) is `run` to activate completion for model names.
#2. **Parsing Models**: It uses `ollama list | awk 'NR>1 {print $1}'` to parse only the first column (model names), skipping the header line.
#3. **Filtering**: Uses `compgen -W` to filter suggestions based on the user's input (`$cur`).
#4. **No Fallback**: If no models match, it gracefully provides no suggestions without error.
#
#### Usage:
#- Source the script in your shell or add it to your completion files for auto-completion when using `ollama run`.

