#Thinking...
#Okay, I need to create a Bash completion script for the `ollama run` command. The goal is to provide autocompletion suggestions for model names when the user types `ollama run` and presses TAB.
#
#First, I should check if the second word in the command is exactly 'run'. That's important because we don't want to trigger completion for other subcommands.
#
#Next, I need to get the list of available models. The `ollama list` command outputs a table with model names in the first column. I have to parse this output, skipping the header line. Using `awk '{print $1}'` can extract the first field from each line after the header.
#
#Then, I should filter these models based on what the user has already typed. If they've started typing something like 'co', only models starting with 'co' should be suggested. This is done by comparing each model name to the current word being completed (`cur`).
#
#I must ensure that there are no duplicates in the suggestions. Using `sort -u` will help remove any duplicates.
#
#Importantly, if none of the models match the current input, I shouldn't fall back to suggesting filenames. The completion should just provide no suggestions.
#
#Also, I need to avoid using `_get_comp_words_by_ref` since it might not be available everywhere. Instead, I'll directly access `COMP_WORDS` and `COMP_CWORD` to get the current word and the previous word (which should be 'run').
#
#Putting it all together, I'll structure the script to check if the command is correct, fetch and parse the model list, filter based on the input, handle duplicates, and then set the completions accordingly. Testing each part step by step will help ensure everything works as expected without errors.
#...done thinking.

# Bash completion script for ollama run command
# Provides model name autocompletion after 'ollama run'

_ollama_run() {
    # Check if we're completing the word after 'run'
    if [[ ${COMP_WORDS[1]} != "run" ]]; then
        return
    fi

    # Extract the current word being completed
    local cur=${COMP_WORDS[COMP_CWORD]}

    # Get list of available models using ollama list, skipping header line
    # Using awk to extract only the first column (model names)
    local models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')

    # Split models into an array
    local IFS=$'\n'
    local model_list=($models)

    # Filter models matching current word and remove duplicates
    COMPREPLY=($(compgen -W "${model_list[*]}" -- ${cur}))

    # Remove duplicate suggestions while preserving order (using sort for dedup)
    # Note: This approach may not preserve original order, but maintains uniqueness
    # Alternative could be to use a hash set if available
    COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort -u))
}

# Register the completion function with bash-completion
complete -F _ollama_run ollama

# Explanation of the script:

# 1. The `_ollama_run` function is defined to handle completions for `ollama run`.
# 2. We check if the second word (`${COMP_WORDS[1]}`) is exactly `run` as per requirement 1.
# 3. Extracting current word being completed from `${COMP_WORDS[COMP_CWORD]}`.
# 4. Fetching model list by running `ollama list`, skipping header line with `tail -n +2`.
# 5. Parsing only the first column (model names) using `awk '{print $1}'`.
# 6. Splitting the output into an array of models.
# 7. Using `compgen` to filter model suggestions matching current word (`cur`).
# 8. Removing duplicates by piping through `sort -u`.
# 9. Registering the completion function with `complete` command.

# This script meets all requirements and avoids common mistakes:
#- Only completes for 'run' subcommand
#- Uses standard tools (awk, sort)
#- Filters suggestions based on current input
#- No filename fallback
#- Removes duplicates in suggestions
#- Uses only standard bash variables and commands

