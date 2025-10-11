#! /bin/bash

_ollama_completions() {
    local cur prev models

    # If not run, return early
    [[ ${COMP_WORDS[1]} != "run" ]] && return 0

    # Handle colon in word breaks
    local orig_wordbreaks=${COMP_WORDBREAKS//:/}
    COMP_WORDBREAKS=${orig_wordbreaks/:/}
    _get_comp_words_by_ref -n : cur prev
    COMP_WORDBREAKS=${orig_wordbreaks}

    # Generate completions
    models=$(ollama list | awk 'NR>1 {print $1}')
    COMPREPLY=($(compgen -W "$models" -- "$cur"))

    # Register completion
    complete -F _ollama_completions ollama
}
