# Bash completion function for 'ollama run' command
# Handles model names with colons properly by managing COMP_WORDBREAKS

_ollama_run_completion() {
    # Save original COMP_WORDBREAKS to restore later
    local old_wb="$COMP_WORDBREAKS"

    # Get the index of "run" in COMP_WORDS (position of command)
    local run_index=-1
    for i in "${!COMP_WORDS[@]}"; do
        if [[ "${COMP_WORDS[i]}" == "run" ]]; then
            run_index=$i
            break
        fi
    done

    # If "run" is not found or we're not completing after it, exit early
    if [[ $run_index -eq -1 ]] || [[ $COMP_CWORD -ne $((run_index + 1)) ]]; then
        # Restore COMP_WORDBREAKS and clear COMPREPLY
        COMP_WORDBREAKS="$old_wb"
        COMPREPLY=()
        return
    fi

    # Remove colon from COMP_WORDBREAKS to allow colon in completions
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}

    # Get current word being completed
    local cur="${COMP_WORDS[COMP_CWORD]}"

    # Fetch list of models, skip header row, extract first field (model name)
    local models
    models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | awk '!seen[$0]++')

    # Restore COMP_WORDBREAKS immediately before any return
    COMP_WORDBREAKS="$old_wb"

    # If no models found, clear COMPREPLY and exit
    if [[ -z "$models" ]]; then
        COMPREPLY=()
        return
    fi

    # Generate completions using compgen for safe prefix matching
    COMPREPLY=($(compgen -W "$models" -- "$cur"))
}

# Register the completion function with ollama command
complete -F _ollama_run_completion ollama
