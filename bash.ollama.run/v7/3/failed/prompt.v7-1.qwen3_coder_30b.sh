# Bash completion function for 'ollama run' command
_ollama_run_completion() {
    local cur prev words cword
    _get_comp_words_by_ref -n : cur prev words cword

    # Find the index of the 'run' subcommand
    local run_index=-1
    local i
    for ((i=0; i < ${#words[@]}; i++)); do
        if [[ "${words[i]}" == "run" ]]; then
            run_index=$i
            break
        fi
    done

    # Only complete if we are directly after 'run'
    if [[ $cword -ne $((run_index + 1)) ]]; then
        return 0
    fi

    # Save original COMP_WORDBREAKS
    local old_wb=$COMP_WORDBREAKS

    # Temporarily remove colon from COMP_WORDBREAKS to handle model names with colons
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}

    # Get list of models, skip header, extract first column
    local models
    models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | awk '!seen[$0]++')

    # Restore COMP_WORDBREAKS in all code paths
    COMP_WORDBREAKS=$old_wb

    # If no models found, exit quietly
    if [[ -z "$models" ]]; then
        return 0
    fi

    # Generate completions using compgen with prefix filtering
    compgen -W "$models" -- "$cur" | while read -r model; do
        COMPREPLY+=("$model")
    done

    # Ensure no space is added after completion (for model names)
    compopt -o nospace 2>/dev/null
}

# Register the completion function for 'ollama'
complete -F _ollama_run_completion ollama

