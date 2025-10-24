_ollama_completion() {
    local cur prev models

    # Get current and previous word, remove spaces around them
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    # Check if we're currently completing the second word (right after `run`)
    if [[ "$prev" != "run" ]]; then
        return 0
    fi

    # Get list of all model names from 'ollama list', skipping header
    models=$(ollama list | awk 'NR>1 {print $1}' | sort -u)

    # Filter list based on content of current word
    COMPREPLY=($(compgen -W "$models" -- "$cur"))
}
complete -F _ollama_completion ollama

