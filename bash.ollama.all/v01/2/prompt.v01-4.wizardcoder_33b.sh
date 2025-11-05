```bash
function _ollama_completions() {
    # validate command and get words for completion
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != ${COMMAND} ]] && return
    
    local cur prev
    _get_comp_words_by_ref -n : cur prev
    
    # get models
    if ! command -v ollama &>/dev/null; then 
        COMPREPLY=()
        return
    fi
    local models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
    
    # generate completions
    [[ -z "$models" ]] && COMPREPLY=() || COMPREPLY=($(compgen -W "$models" -- "$cur"))
    
    # sort and trim
    if [[ "${#COMPREPLY[@]}" -ne 0 ]]; then
        COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
        __ltrim_colon_completions "$cur"
    fi
}
complete -F _ollama_completions ollama
``` 

