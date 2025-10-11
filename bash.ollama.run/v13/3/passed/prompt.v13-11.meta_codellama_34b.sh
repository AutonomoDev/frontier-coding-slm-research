
### Completion Script for `ollama` Command:

_get_comp_words_by_ref() {
    local exclude=($1)
    shift
    local words=("${COMP_WORDS[@]}")
    for ((i = 0; i < ${#words[@]}; i++)); do
        for j in "${exclude[@]}"; do
            [[ "${words[i]}" == "$j" ]] && unset words[i]
        done
    done
COMPREPLY=( "${words[@]}" )
}

_ollama() {
    local cur=${COMP_WORDS[COMP_CWORD]}
    local prev=${COMP_WORDS[COMP_CWORD-1]}
    COMPREPLY=()

    if [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]; then
        return 0
    fi

    # Handle colon in model names
    _get_comp_words_by_ref -n :

    # Process `ollama list` output correctly
    local models="$(ollama list | awk 'NR > 1 {print $1}')"
    COMPREPLY=($(compgen -W "${models}" -- ${cur}))
    __ltrim_colon_completions "$cur"
}
complete -F _ollama ollama
