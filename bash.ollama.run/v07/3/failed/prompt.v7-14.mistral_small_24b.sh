# _ollama_run_completion - Provide autocompletion suggestions for `ollama run` command

_ollama_run_completion() {
    local cur prev words cword
    if _get_comp_words_by_ref -n : cur prev words cword; then
        : # Do nothing, just use the values from _get_comp_words_by_ref
    else
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
        words=("${COMP_WORDS[@]}")
        cword=$COMP_CWORD
    fi

    local run_index
    run_index=$(for i in "${!words[@]}"; do [[ ${words[i]} == "run" ]] && echo $i; done)

    if [[ -z "$run_index" || $cword != $((run_index + 1)) ]]; then
        return 0
    fi

    local old_wb=$COMP_WORDBREAKS
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}

    local model_list
    model_list=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}')

    if [[ -z "$model_list" ]]; then
        COMP_WORDBREAKS=$old_wb
        return 0
    fi

    local wordlist
    wordlist=$(echo "$model_list" | awk '!seen[$0]++')
    compgen -W "$wordlist" -- "$cur"

    COMP_WORDBREAKS=$old_wb
}

complete -F _ollama_run_completion ollama
