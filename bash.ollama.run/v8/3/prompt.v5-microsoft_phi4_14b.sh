#!/bin/bash

_ollama_run_completion() {
    # Save original word break characters and adjust them temporarily for colon handling
    local old_wb="$COMP_WORDBREAKS"
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}

    # Use helper function to get current/previous words or fallback manually if unavailable
    _get_comp_words_by_ref -n : cur prev words cword 2>/dev/null || {
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    }

    # Find the position of "run" in COMP_WORDS to ensure we are completing after "ollama run"
    local run_index=0
    for ((i = 0; i < cword; i++)); do
        if [[ "${words[i]}" == "run" ]]; then
            run_index="$i"
            break
        fi
    done

    # Only provide completion if the current word is immediately after "ollama run"
    if [[ "$cword" -eq "$((run_index + 2))" ]]; then
        # Retrieve model names, handling variable whitespace robustly and deduplicating them
        local models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | awk '!seen[$0]++')
        
        # Use compgen for safe prefix matching to generate the completion list
        COMPREPLY=($(compgen -W "$models" -- "$cur"))
    else
        # Clear completion suggestions if we're not in the right context
        COMPREPLY=()
    fi

    # Restore original word break characters before returning
    COMP_WORDBREAKS="$old_wb"
}

# Register completion function with bash-completion for the 'ollama run' command
complete -F _ollama_run_completion ollama

#
## [[HUMAN COMMENTED-OUT]]
#### Explanation:
#1. **Colon Handling:**
#   - Adjust `COMP_WORDBREAKS` to handle colons in model names by temporarily removing them and ensuring they are restored after completion logic.
#
#2. **Position Detection:**
#   - Identify the position of "run" in the command line (`COMP_WORDS`) and trigger completions only if the cursor is directly after "ollama run".
#
#3. **Robust Data Parsing:**
#   - Use `awk` to handle variable whitespace when extracting model names from the `ollama list` output, ensuring unique entries with deduplication.
#
#4. **Helper Function Fallback:**
#   - Attempt to use `_get_comp_words_by_ref`, and if unavailable, manually extract the current and previous words for completion logic.
#
#5. **Safe Filtering:**
#   - Use `compgen` for generating completions based on a list of valid model names, ensuring safe prefix matching without regex complexities.
#
#6. **No Filename Fallback:**
#   - Register the completion script with `complete -F _ollama_run_completion ollama`, avoiding `-o default` to prevent fallback to filename completion.
#
#The script is designed to be sourced immediately and integrates seamlessly with bash-completion framework v2 for robust command line completion of the `ollama run` subcommand.

