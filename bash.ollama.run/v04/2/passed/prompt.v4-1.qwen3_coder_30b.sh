_ollama_run_completion() {
    local cur prev words cword
    local cmd

    # Ensure we're completing the 'run' subcommand
    if [[ ${COMP_WORDS[1]} != "run" ]]; then
        return 0
    fi

    # Get the current word being completed
    cur="${COMP_WORDS[COMP_CWORD]}"

    # Fetch list of models, skip header, extract first column (model names)
    local models=($(ollama list | awk 'NR>1 {print $1}'))

    # Filter models based on the current input
    COMPREPLY=()
    for model in "${models[@]}"; do
        if [[ "$model" == "$cur"* ]]; then
            COMPREPLY+=("$model")
        fi
    done

    # Remove duplicates (if any)
    local i
    local unique=()
    local seen=()

    for i in "${COMPREPLY[@]}"; do
        if [[ ! " ${seen[*]} " =~ " $i " ]]; then
            seen+=("$i")
            unique+=("$i")
        fi
    done

    COMPREPLY=("${unique[@]}")
}

# Register the completion function for ollama
complete -F _ollama_run_completion ollama
