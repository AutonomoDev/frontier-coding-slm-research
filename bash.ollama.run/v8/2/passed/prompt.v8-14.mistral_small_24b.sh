# Bash completion script for `ollama run` command

# Function to handle completion for `ollama run`

_ollama_run() {
    # Save and restore COMP_WORDBREAKS to handle colons in model names
    local old_wb="$COMP_WORDBREAKS"
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}

    # Helper function fallback for _get_comp_words_by_ref
    _get_comp_words_by_ref -n : cur prev words cword 2>/dev/null || {
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    }

    # Find the exact position of "run" in COMP_WORDS array
    local run_index=-1
    for i in "${!COMP_WORDS[@]}"; do
        if [[ ${COMP_WORDS[$i]} == "run" ]]; then
            run_index=$i
            break
        fi
    done

    # Only trigger completion when COMP_CWORD is right after "run"
    if [[ $run_index -ne -1 && $COMP_CWORD == $((run_index + 1)) ]]; then
        # Retrieve model names using `ollama list`
        local models
        models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | awk '!seen[$0]++')

        # Safe prefix matching for completion
        COMPREPLY=($(compgen -W "$models" -- "$cur"))

    else
        # Clear COMPREPLY when not providing model completions
        COMPREPLY=()
    fi

    # Restore COMP_WORDBREAKS before returning/exiting
    COMP_WORDBREAKS="$old_wb"
}

# Register the completion function with `ollama` command
complete -F _ollama_run ollama

# [[HUMAN COMMENTED-OUT]]
#### Explanation:
#1. **Colon Handling**: The script saves and restores `COMP_WORDBREAKS` to handle colons in model names.
#2. **Position Detection**: It finds the exact position of "run" in the `COMP_WORDS` array and triggers completion only when `COMP_CWORD` is right after "run".
#3. **Robust Data Parsing**: The script uses `awk` to parse model names, ensuring it handles variable whitespace correctly.
#4. **Helper Function Fallback**: It includes a fallback for `_get_comp_words_by_ref`.
#5. **Safe Filtering**: It uses `compgen` for safe prefix matching.
#6. **No Filename Fallback**: The script registers with `complete -F _ollama_run ollama` without `-o default`.
#
#This script is ready to be sourced immediately and will provide the expected completion behavior for the `ollama run` command.

