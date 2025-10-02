_ollama_run_completion() {
    local cur prev words cword
    _init_completion || return

    # Only trigger completion for the word after 'run'
    if [[ ${COMP_WORDS[1]} == "run" ]]; then
        # Get the current word being completed
        cur="${COMP_WORDS[COMP_CWORD]}"

        # Fetch list of models, skip header, extract first column (model names)
        local models
        models=$(ollama list 2>/dev/null | awk 'NR > 1 {print $1}' | sort -u)

        # Filter models based on current input
        COMPREPLY=($(compgen -W "$models" -- "$cur"))
    fi
}

complete -F _ollama_run_completion ollama

