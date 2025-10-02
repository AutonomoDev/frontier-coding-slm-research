# Bash completion for "ollama run"

_ollama_run_completion() {
    # Make sure we are completing for the correct subcommand
    if [ "${COMP_WORDS[1]}" != "run" ]; then
        return
    fi

    # Get the models from "ollama list" and remove header
    local models=$(ollama list --no-trunc | awk 'NR>1 {print $1}')
    
    # Filter the models based on the current word
    COMPREPLY=( $(compgen -W "${models}" -- ${COMP_WORDS[COMP_CWORD]} ) )
}

# Register the completion function for "ollama"
complete -F _ollama_run_completion ollama

