_ollama_completions() {
    local cur prev words cword split colon_prefixes
    _init_completion -s || return
    
    # Check for command and subcommand
    if [[ ${COMP_WORDS[0]} != "ollama" ]] || [[ "$prev" != "run" ]]; then
        return
    fi
  
    # Handle colon in word breaks
    if  ! _get_comp_words_by_ref -n : cur prev; then
       cur=${COMP_WORDS[COMP_CWORD]}
       prev=${COMP_WORDS[COMP_CWORD-1]}
    fi
  
    # Check if ollama command exists
    if ! command -v "ollama" &> /dev/null; then
        return 
    fi
  
    # Get model names from 'ollama list' output
    local models=($(ollama list 2> /dev/null | awk 'NR > 1 {print $1}'))
  
    if ((${#models[@]} == 0)); then
        return
    fi
    
    # Filter matches using array iteration and pattern matching against `$cur`
    local sorted_matches=($(compgen -W "${models[*]}" -- "$cur"))
  
    if (( ${#sorted_matches} == 0 )); then
        COMPREPLY=()
        return
    fi
    
    # Generate completions and handle colon properly with __ltrim_colon_completions
    compgen -W "${sorted_matches[*]}" -- "$cur" | while IFS= read -r m; do COMPREPLY+=("$m"); done
    __ltrim_colon_completions "$cur"
}

complete -F _ollama_completions ollama
