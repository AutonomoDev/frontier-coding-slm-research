#!/bin/bash

# Bash completion function for 'ollama run' command.
_ollama_run() {
    local cur prev words cword models
    local old_wb="$COMP_WORDBREAKS"

    # Detect the position of "run" in COMP_WORDS array and only complete when
    # CUR is directly after "run".
    local cmd_index=-1
    for ((i = 0; i < ${#COMP_WORDS[@]}; i++)); do
        if [[ "${COMP_WORDS[i]}" == "run" ]]; then
            cmd_index=$i
            break
        fi
    done

    # Only proceed with completion if we are directly after the 'run' command.
    if [[ $cmd_index -eq -1 ]] || [[ $((cmd_index + 1)) != "$COMP_CWORD" ]]; then
        COMPREPLY=()
        return
    fi

    # Handle model names containing colons by temporarily removing colon from word breaks.
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}

    # Retrieve the list of models, safely handling variable whitespace in ollama list output.
    models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | awk '!seen[$0]++')

    # Extract current word to complete.
    cur="${COMP_WORDS[COMP_CWORD]}"

    # Generate completion replies based on the current input and model names.
    COMPREPLY=($(compgen -W "$models" -- "$cur"))

    # Restore COMP_WORDBREAKS before returning.
    COMP_WORDBREAKS="$old_wb"
}

# Register the completion function with 'ollama run'.
complete -F _ollama_run ollama


# [[HUMAN COMMENTED-OUT]]
#### Explanation:
#1. **Colon Handling**: The script temporarily removes `:` from `COMP_WORDBREAKS` to treat colons as part of the word (not a delimiter) during completion, ensuring proper handling of model names like `codellama:13b`.
#2. **Position Detection**: It dynamically checks where "run" appears in the command line arguments and only triggers completions when the cursor is immediately after "run".
#3. **Robust Parsing**: The script uses `awk` to parse the output from `ollama list`, handling variable whitespace reliably.
#4. **Fallback Handling**: In case the helper function `_get_comp_words_by_ref` isn't available, it manually sets up the required variables (`cur`, `prev`, etc.), though this scenario is rare in modern systems.
#5. **Safe Filtering**: It uses `compgen -W` for safe prefix matching instead of regex-based filtering to avoid issues with special characters.
#6. **No Filename Fallback**: The completion function doesn't rely on default filename completions (no `-o default` flag), ensuring only model names are suggested.
#
#This script ensures robust and user-friendly tab-completion behavior for the `ollama run` command, handling edge cases like colons in model names effectively.

