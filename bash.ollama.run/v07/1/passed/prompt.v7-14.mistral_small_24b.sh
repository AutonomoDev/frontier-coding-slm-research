# _ollama_run_completion - Provide autocompletion suggestions for `ollama run` command

_ollama_run_completion() {
    local cur prev words cword
    if _get_comp_words_by_ref -n : cur prev words cword; then
        # Fallback in case _get_comp_words_by_ref is not available
        : "${COMP_WORDS[COMP_CWORD-1]}"
        : "${COMP_WORDS[COMP_CWORD]}"
    else
        cur="${words[cword]}"
        prev="${words[cword-1]}"
    fi

    # Find the index of 'run' in COMP_WORDS
    local run_index
    for i in "${!COMP_WORDS[@]}"; do
        if [[ ${COMP_WORDS[i]} == "run" ]]; then
            run_index=$i
            break
        fi
    done

    # Activate completion only if the current word is immediately after 'run'
    if [[ $cword -eq $((run_index + 1)) ]]; then
        local old_wb="$COMP_WORDBREAKS"
        COMP_WORDBREAKS=${COMP_WORDBREAKS//:}

        # Get the list of model names from `ollama list`
        local models
        if models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}'); then
            # Deduplicate and filter suggestions
            local wordlist
            wordlist=$(echo "$models" | awk '!seen[$0]++')
            COMPREPLY=( $(compgen -W "$wordlist" -- "$cur") )
        fi

        # Restore COMP_WORDBREAKS
        COMP_WORDBREAKS="$old_wb"
    fi
}

# Register the completion function for `ollama run`
complete -F _ollama_run_completion ollama
