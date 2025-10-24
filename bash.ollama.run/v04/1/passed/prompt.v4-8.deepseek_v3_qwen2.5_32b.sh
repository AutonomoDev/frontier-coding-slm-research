# Bash completion script for ollama run

_ollama_run_complete() {
    local cur=${COMP_WORDS[COMP_CWORD]}
    # Check if the second word is 'run' and current is being completed after it
    if [ $COMP_CWORD -eq 2 ] && [ "${COMP_WORDS[1]}" = "run" ]; then
        # Fetch model names from ollama list, skipping header line, taking first column
        local models=$(ollama list | awk 'NR>1 {print $1}' | sort -u)

        # Filter models based on current input and set completion candidates
        COMPREPLY=( $(compgen -W "$models" -- "$cur") )
    fi
}

# Register the completion function for ollama run
complete -F _ollama_run_complete ollama

