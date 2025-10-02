_ollama_completion() {
    local cur opts base
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"

    if [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]; then
        return 0
    fi

    # Get the list of models via `ollama list` command
    opts=$(ollama list --format="{{.Name}} {{.ID}} {{.Size}} {{.Modified}}" 2>/dev/null | _get_comp_words_by_ref -n : | {
        read -r header
        while read -r line; do
            [[ -n "$line" ]] && printf "%s\n" "${line%%[[:space:]]*}"
        done
    })

    COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
    __ltrim_colon_completions "$cur"

    return 0
}
complete -F _ollama_completion ollama
