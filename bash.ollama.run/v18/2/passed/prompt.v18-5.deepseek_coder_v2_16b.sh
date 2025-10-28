# Bash completion for `ollama run <model>`

_ollama_completions() {
    # Activate only for `ollama run` and ensure correct index
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return 0; }
    [[ $COMP_CWORD -ne 2 ]] && return 0;

    # Handle colons and parse ollama list output
    local cur prev models=()
    if type _get_comp_words_by_ref &>/dev/null; then
        _get_comp_words_by_ref -n : cur prev
    else
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # Parse models from `ollama list` output
    if command -v ollama &>/dev/null; then
        IFS=$'\n' read -rd '' -a models <<< "$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')"
    fi

    # Sort and set completions
    if [[ ${#models[@]} -ne 0 ]]; then
        IFS=$'\n' models=($(sort <<<"${models[*]}"))
        unset IFS
        COMPREPLY=( $(compgen -W "${models[*]}" -- "$cur") )
    fi

    # Fix colons if necessary
    if type __ltrim_colon_completions &>/dev/null; then
        __ltrim_colon_completions "$cur"
    fi
}

# Register the completion function
complete -F _ollama_completions ollama
