_ollama_completions() {
    local cur prev words cword
    _get_comp_words_by_ref -n : cur prev
    
    # Fallback to standard COMP_WORDS parsing if _get_comp_words_by_ref is unavailable
    if [ "$cur" = "" ]; then
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi
    
    # Checking if the command is 'ollama' and previous word is 'run'
    if [ "${prev}" = "run" ]; then
        local models=$(ollama list 2>/dev/null | awk 'NR > 1 {print $1}') || return
        
        # Generating completions using the model names from ollama list, matching against current word
        COMPREPLY=($(compgen -W "$models" -- "$cur"))
        
        # Handling colon-separated completions
        __ltrim_colon_completions "$cur"
    fi
}
# Registering the function for ollama command
complete -F _ollama_completions ollama
