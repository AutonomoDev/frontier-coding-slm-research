```bash
# Bash Completion for `ollama run <model>`

_ollama_completions() {
    # Check if command is 'ollama run'
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return 0; }
    
    # Only complete the third word (model name after 'ollama run')
    [[ $COMP_CWORD -ne 2 ]] && return 0
    
    local cur prev
    if type _get_comp_words_by_ref &>/dev/null; then
        _get_comp_words_by_ref -n : cur prev
    else
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi
    
    # Fetch and parse available models from 'ollama list'
    local models=()
    if command -v ollama &>/dev/null; then
        models=($(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}'))
    else
        COMPREPLY=(); return 0
    fi
    
    # Sort the model names for better completion experience
    IFS=$'\n' models=($(sort <<<"${models[*]}"))
    unset IFS
    
    # Generate completions based on current input (cur)
    COMPREPLY=( $(compgen -W "${models[*]}" -- "$cur") )
    
    # Handle colon completions properly
    if type __ltrim_colon_completions &>/dev/null; then
        __ltrim_colon_completions "$cur"
    fi
}

# Register completion for 'ollama'
complete -F _ollama_completions ollama

```

