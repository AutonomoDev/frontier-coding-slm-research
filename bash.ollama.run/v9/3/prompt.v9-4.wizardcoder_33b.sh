# `_get_comp_words_by_ref` is a Bash helper function for word splitting. It populates
# the array COMP_WORDS and COMP_CWORD based on the current command line, but also
# allows to customize the colon-separated word breaks. By temporarily removing colon
# from `COMP_WORDBREAKS`, we're ensuring that the colon in a model name like "codellama:13b"
# doesn't break our completion logic. 

_ollama_completions() {
    local cur prev words cword
    
    # Save original word breaks
    local _old_wb=${COMP_WORDBREAKS}
    
    # Modify COMP_WORDBREAKS to remove the colon.
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}
    
    # Use _get_comp_words_by_ref to parse current and previous word.
    # The `-n :` option tells it not to split on colon. 
    _get_comp_words_by_ref -n : cur prev words cword

    # Restore original word breaks immediately to avoid side-effects.
    COMP_WORDBREAKS=${_old_wb}
    
    if [[ "$prev" == "run" ]]; then 
        local models=$(ollama list | awk 'NR>1 {print $1}')
        COMPREPLY=( $(compgen -W "$models" -- "$cur") )
    fi
}
complete -F _ollama_completions ollama
unset _old_wb

# Note: 
# This solution assumes that `ollama list` outputs the model names without additional spaces or escape characters. The awk command is used to get all model names in a single line, skipping the header line with 'NR>1'. If your version of `ollama list` outputs model names differently, you might need to adjust this part of the solution. 

