_ollama() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    
    if [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]; then
        return 0
    fi

    _get_comp_words_by_ref -n : cur
    COMPREPLY=($(ollama list | awk 'NR>1 && $0 !~ /^$/ {print $1}'))
    __ltrim_colon_completions "$cur"
    return 0
}
complete -F _ollama ollama
