# Bash completion function for 'ollama run <model>'
_ollama_run() {
    local cur prev words cword
    _init_completion || return

    # If we're completing the second argument (model name)
    if [[ $cword -eq 2 ]]; then
        # Parse model names from 'ollama list'
        # Skip first line (header) and extract first field
        local models
        models=$(ollama list 2>/dev/null | sed '1d' | awk '{print $1}' 2>/dev/null)
        COMPREPLY=($(compgen -W "$models" -- "$cur"))
    fi
}

# Register the completion function
complete -F _ollama_run ollama
