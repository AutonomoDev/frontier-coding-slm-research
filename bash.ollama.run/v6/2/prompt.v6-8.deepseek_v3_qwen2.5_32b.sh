# ollama-run-completion.sh -- Bash completion for 'ollama run' command

_ollama_run() {
    local cur prev words cword
    # Fallback if _get_comp_words_by_ref is not available (e.g., old bash-completion)
    if ! declare -F _get_comp_words_by_ref &>/dev/null; then
        IFS=' ' read -r -a words <<< "$COMP_LINE"
        cword="$COMP_POINT"
        cur="${words[$cword]}"
        prev="${words[$((cword-1))]}"
    else
        # Use standard approach when available
        _get_comp_words_by_ref -n =: cur prev words cword
    fi

    # Check command structure: must be 'ollama run ...'
    if [[ "${#words[@]}" -ge 2 && "${words[0]}" == "ollama" && "$prev" == "run" ]]; then
        # Get available models from ollama list, skipping header and empty lines
        local models=$(ollama list | awk 'NR>1 {print $1}' | tr '\n' ' ')
        
        # Extract the model names (first column) using cut or awk
        COMPREPLY=( $(compgen -W "$models" -- "$cur") )
    fi

    # Ensure unique entries by filtering duplicates
    local i=0
    while [[ $i -lt ${#COMPREPLY[@]} ]]; do
        if [[ " ${COMPREPLY[@]:i+1} " =~ " ${COMPREPLY[i]} " ]]; then
            unset COMPREPLY[i]
        else
            ((i++))
        fi
    done

    # Filter out empty strings that may have crept in (unlikely, but defensive coding)
    COMPREPLY=("${COMPREPLY[@]//''/}")
}

# Define completion function for 'ollama run'
complete -F _ollama_run ollama

# EOF

