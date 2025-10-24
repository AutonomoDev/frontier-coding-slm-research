# Function to provide completion for 'ollama run' subcommand
_ollama_run_completion() {
    local cur prev words cword
    _get_comp_words_by_ref -n : cur prev words cword || {
        # Fallback if _get_comp_words_by_ref is not available
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    }

    # Find the index of 'run' in COMP_WORDS
    local run_index=-1 i
    for ((i=0; i < ${#COMP_WORDS[@]}; i++)); do
        if [[ "${COMP_WORDS[i]}" == "run" ]]; then
            run_index=$i
            break
        fi
    done

    # Only complete if we are directly after the 'run' command
    if [[ $run_index -ne -1 && $COMP_CWORD -eq $((run_index + 1)) ]]; then
        # Save old COMP_WORDBREAKS and remove colon
        local old_wb="$COMP_WORDBREAKS"
        COMP_WORDBREAKS=${COMP_WORDBREAKS//:}

        # Get list of models, skip header, extract first column
        local models
        models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | awk '!seen[$0]++')

        # Restore COMP_WORDBREAKS before any return
        COMP_WORDBREAKS="$old_wb"

        # Use compgen to filter and provide completions
        COMPREPLY=($(compgen -W "$models" -- "$cur"))
    else
        # Restore COMP_WORDBREAKS in case of early exit
        local old_wb="$COMP_WORDBREAKS"
        COMP_WORDBREAKS=${COMP_WORDBREAKS//:}
        COMP_WORDBREAKS="$old_wb"
    fi
}

# Register the completion function for 'ollama'
complete -F _ollama_run_completion ollama

