 ```bash
# Function to provide completions for `ollama run <model>`
_ollama_completions() {
    # Ensure the command is ollama run and COMP_CWORD is at the correct position
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return 0; }
    [[ $COMP_CWORD -ne 2 ]] && return 0;

    # Local variables for current and previous words
    local cur prev
    if type _get_comp_words_by_ref &>/dev/null; then
        _get_comp_words_by_ref -n : cur prev
    else
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # Parse models from ollama list command
    local models=()
    if command -v ollama &>/dev/null; then
        models=($(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}'))
    fi

    # Sort models for completion suggestions
    IFS=$'\n' models=($(sort <<<"${models[*]}"))
    unset IFS

    # Generate completions based on the current word and previous word
    COMPREPLY=( $(compgen -W "${models[*]}" -- "$cur") )

    # Handle colons to ensure proper completion after ":"
    if type __ltrim_colon_completions &>/dev/null; then
        __ltrim_colon_completions "$cur"
    fi
}

# Register the completion function for ollama run command
complete -F _ollama_completions ollama
```

