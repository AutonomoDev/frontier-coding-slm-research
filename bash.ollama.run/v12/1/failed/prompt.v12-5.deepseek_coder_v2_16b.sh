function _ollama_completions {
    if ! _get_comp_words_by_ref -n : cur prev; then
        compgen_fallback=yes
        local cur="${COMP_WORDS[COMP_CWORD]}"
        local prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    if [[ "${COMP_WORDS[0]}" != "ollama" || "$prev" != "run" ]]; then
        COMPREPLY=()
        return
    fi

    if ! command -v ollama &> /dev/null; then
        COMPREPLY=()
        return
    fi

    local models=()
    while IFS= read -r line; do
        if [[ "$line" =~ ^NAME[[:space:]] ]]; then
            continue
        elif [[ -z "$line" ]]; then
            continue
        else
            model=$(echo "$line" | awk '{print $1}')
            models+=("$model")
        fi
    done < <(ollama list 2>/dev/null)

    if [[ ${#models[@]} -eq 0 ]]; then
        COMPREPLY=()
        return
    fi

    local matches=()
    for model in "${models[@]}"; do
        if [[ "$model" == "$cur"* ]]; then
            matches+=("$model")
        fi
    done

    if [[ ${#matches[@]} -eq 0 ]]; then
        COMPREPLY=()
        return
    fi

    local sorted_matches=$(printf '%s\n' "${matches[@]}" | sort)
    COMPREPLY=( $(compgen -W "$sorted_matches" -- "$cur") )

    if [[ $compgen_fallback == "yes" ]]; then
        __ltrim_colon_completions "$cur"
    fi
}

complete -F _ollama_completions ollama
