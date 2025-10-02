_ollama_completions() {
    local cur prev models matches line

    if ! _get_comp_words_by_ref -n : cur prev; then
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    if [ "$prev" != "run" ]; then
        COMPREPLY=()
        return
    fi

    if ! command -v ollama &> /dev/null; then
        COMPREPLY=()
        return
    fi

    models=(`ollama list 2>/dev/null | awk 'NR>1 && $1!="" {print $1}'`)

    if [ "${#models[@]}" -eq 0 ]; then
        COMPREPLY=()
        return
    fi

    matches=()
    for model in "${models[@]}"; do
        if [[ "$model" == "$cur"* ]]; then
            matches+=("$model")
        fi
    done

    sorted_matches=$(printf '%s\n' "${matches[@]}" | sort)
    COMPREPLY=($(compgen -W "$sorted_matches" -- "$cur"))

    __ltrim_colon_completions "$cur"
}
complete -F _ollama_completions ollama
