# Bash programmable completion for 'ollama run'

_get_comp_words_by_ref() { 
    local exclude i j cur_;
    if [ "$1" = "-n" ]; then
        # for backwards compatibility with bash < 4.3
        exclude=$2; shift 2 || return 1
        i=0
        for cur_ in ${COMP_WORDS[@]}; do
            [[ $i -ge $exclude ]] && printf '%s ' "$cur_"
            (( i++ ))
        done
    fi
}

_ollama_run_completions() {
    local cur prev words cword split;
    _get_comp_words_by_ref -n : cur prev words cword;

    if [[ "${COMP_WORDS[1]}" == "run" ]]; then
        # Save COMP_WORDBREAKS before modifying it.
        local COMP_WORDBREAKS_bak=$COMP_WORDBREAKS;
        
        # Modify COMP_WORDBREAKS to prevent colon (:) from being considered a word break.
        COMP_WORDBREAKS=${COMP_WORDBREAKS//:}
        
        # Re-parse the current and previous words with the new COMP_WORDBREAKS settings.
        _get_comp_words_by_ref -n : cur prev words cword;

        local models=$(ollama list | awk 'NR>1 {print $1}')  # Fetch model names from ollama list
        
        COMPREPLY=( $( compgen -W "$models" -- "$cur") );  # Provide completions to COMPREPLY.

        # Restore original COMP_WORDBREAKS.
        COMP_WORDBREAKS=$COMP_WORDBREAKS_bak;
    fi
}

# Register the function with compspec keyword 'ollama' and function _ollama_run_completions.
complete -F _ollama_run_completions ollama