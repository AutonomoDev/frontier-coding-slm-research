_completion() {
    local cur prev words cword
    _get_comp_words_by_ref -n :cur:prev:words:cword

    if [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]; then
        return 0
    fi

    COMPREPLY=()
    models=$(ollama list | tail -n +2 | awk '{print $1}')
    if [[ "$cur" == :* ]]; then
        __ltrim_colon_completions "$cur"
    fi

    COMPREPLY=( $(compgen -W "$models" -- "$cur") )
}

complete -F _completion ollama
