_ollama() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    # Check if the command is "ollama run"
    if [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]; then
        return 0
    fi

    _get_comp_words_by_ref -n : cur prev words cword
    opts=$(ollama list | awk 'NR>1 && $1 ~ /^llama:/ {print $1}')

    COMPREPLY=( $(compgen -W "${opts}" -- "$cur") )
    __ltrim_colon_completions "$cur"
}

complete -F _ollama ollama
