Here is the completed bash completion script for `ollama run` command:
```bash
#!/usr/bin/env bash

# Function to complete 'ollama run'
_ollama_completions() {
    # Check if we are completing "ollama run"
    [[ ${COMP_WORDS[0]} != "ollama" || ${COMP_WORDS[1]} != "run" ]] && { COMPREPLY=(); return 0; }
    
    # If there's no model name yet, we don't need to complete it
    [[ $COMP_CWORD -ne 2 ]] && return 0
  
    local cur prev
    if type _get_comp_words_by_ref &>/dev/null; then 
        _get_comp_words_by_ref -n : cur prev
    else
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # Get the models list from ollama list
    local models=()
    if command -v ollama &>/dev/null; then 
        models=($(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}'))
    fi
  
    # Sort the models for better user experience
    IFS=$'\n' models=($(sort <<<"${models[*]}"))
    unset IFS

    # Complete with models, and handle colon-based completion
    COMPREPLY=( $(compgen -W "${models[*]}" -- "$cur") )
    
    if type __ltrim_colon_completions &>/dev/null; then 
        __ltrim_colon_completions "$cur"
    fi
}

# Register our function for completion of 'ollama run'
complete -F _ollama_completions ollama
```
The script checks if the user is typing `ollama run`, then gets the list of models from `ollama list` and completes with those model names. It also handles colons correctly by using `__ltrim_colon_completions`. 

