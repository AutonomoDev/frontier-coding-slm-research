# Bash completion function for `ollama run` command
# Handles model names with colons properly using COMP_WORDBREAKS manipulation

_ollama_run_completion() {
    # Save original COMP_WORDBREAKS to restore later
    local old_wb="$COMP_WORDBREAKS"

    # Find the position of "run" in COMP_WORDS array
    local run_index=-1
    local i
    for ((i=0; i<${#COMP_WORDS[@]}; i++)); do
        if [[ "${COMP_WORDS[i]}" == "run" ]]; then
            run_index=$i
            break
        fi
    done

    # If "run" is not found, do nothing
    if [[ $run_index -eq -1 ]]; then
        COMPREPLY=()
        COMP_WORDBREAKS="$old_wb"
        return
    fi

    # Only complete after the "run" keyword
    if [[ $COMP_CWORD -ne $((run_index + 1)) ]]; then
        COMPREPLY=()
        COMP_WORDBREAKS="$old_wb"
        return
    fi

    # Remove colon from COMP_WORDBREAKS to handle colons in model names
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}

    # Get current word being completed
    local cur="${COMP_WORDS[COMP_CWORD]}"

    # Fetch models using ollama list and parse them safely
    local models
    models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | awk '!seen[$0]++')

    # Restore COMP_WORDBREAKS before any return/exit
    COMP_WORDBREAKS="$old_wb"

    # Generate completions based on current input
    COMPREPLY=($(compgen -W "$models" -- "$cur"))
}

# Register the completion function for `ollama`
complete -F _ollama_run_completion ollama

