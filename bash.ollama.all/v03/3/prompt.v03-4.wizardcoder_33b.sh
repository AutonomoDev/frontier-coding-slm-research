```bash
#!/bin/bash

# Function for model name completion
__ollama_model_names() {
    # Extract word info
    local cur prev
    _get_comp_words_by_ref -n : cur prev
    
    # Fetch models
    if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
    local models
    models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
    
    # Generate completions
    [[ -z "$models" ]] && { COMPREPLY=(); return; }
    COMPREPLY=($(compgen -W "$models" -- "$cur"))
    
    # Sort and trim
    COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
    __ltrim_colon_completions "$cur"
}

# Main completion function for ollama
_ollama_completions() {
    # Top-level completion: provide list of all subcommands as completions
    if [[ ${#COMP_WORDS[@]} -le 2 ]]; then
        COMPREPLY=($(compgen -W "create help list ls pull ps run show serve signin signout start stop" -- "${COMP_WORDS[-1]}"))
    else
        # Subcommand-specific completion logic
        case ${COMP_WORDS[1]} in
            create|pull|start|signin|signout)  # commands with no argument completion
                COMPREPLY=();;
            help|ls|ps)  # 'help', 'ls', and 'ps' are aliases for 'list'
                __ollama_model_names;;
            stop)  # Special handling for 'stop': use 'ollama ps' output to complete models
                COMPREPLY=($(compgen -W "$(ollama ps | tail -n +2 | awk '{print $1}')" -- "${COMP_WORDS[-1]}"));;
            *)  # commands requiring <MODEL> completion: use _ollama_model_names
                __ollama_model_names;;
        esac
    fi
}

# Register the completion function for ollama
complete -F _ollama_completions ollama
``` 

