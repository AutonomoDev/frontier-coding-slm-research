# Function to handle completions for `ollama run <model>`
_ollama_completions() {
    local cur prev models=()

    # Check if the command is ollama and the second word is run
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return 0; }
    [[ $COMP_CWORD -ne 2 ]] && return 0;

    # Handle colons and get the current word and previous word
    if type _get_comp_words_by_ref &>/dev/null; then
        _get_comp_words_by_ref -n : cur prev
    else
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # Parse models from ollama list command
    if command -v ollama &>/dev/null; then
        IFS=$'\n' read -rd '' -a models <<< "$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')"
    fi

    # Sort the models to ensure consistent output
    if [[ ${#models[@]} -gt 0 ]]; then
        IFS=$'\n' models=($(sort <<<"${models[*]}"))
        unset IFS
    fi

    # Generate completions based on the current word and previous word
    COMPREPLY=( $(compgen -W "${models[*]}" -- "$cur") )

    # Handle colons to ensure proper completion after ":"
    if type __ltrim_colon_completions &>/dev/null; then
        __ltrim_colon_completions "$cur"
    fi
}

# Register the function for ollama run command completions
complete -F _ollama_completions ollama
