_ollama_run() {
    local cur prev words cword
    _init_completion || return

    # If we're completing the model name (after 'ollama run')
    if [[ $cword -ge 2 && "${words[cword-1]}" == "run" ]]; then
        # Get models from ollama list, skip first line (header), and extract first column
        local models
        models=$(ollama list 2>/dev/null | sed '1d' | awk '{print $1}' 2>/dev/null) || return
        COMPREPLY=($(compgen -W "$models" -- "$cur"))
    fi
}

complete -F _ollama_run ollama
