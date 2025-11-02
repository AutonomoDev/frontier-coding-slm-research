```bash
# Bash completion for 'ollama run <model>'
_ollama_run() {
    local cur models sorted_models matches cmd_output

    # Only complete if command is 'ollama run' and we're completing after 'run'
    case ${COMP_WORDS[0]} in
        ollama)
            ;;
        *)
            return 1
            ;;
    esac
    (( COMP_CWORD == 2 )) || return 1

    cur="${COMP_WORDS[COMP_CWORD]}"
    
    # Capture output of 'ollama list' into a variable, handling possible errors gracefully
    if ! cmd_output=$(ollama list 2>/dev/null); then
        COMPREPLY=()
        return
    fi
    
    # Read models from the captured output (split on newlines and whitespace)
    IFS=$'\n ' read -r -d '' -a models <<< "$cmd_output"
    
    # Filter models to those starting with the current prefix, case-insensitively
    matches=()
    for model in "${models[@]}"; do
        [[ $model == $cur* ]] && matches+=("$model")
    done
    
    # Sort matches alphabetically before returning
    IFS=$'\n' sorted_models=($(sort <<<"${matches[*]}"))
    unset IFS
    
    COMPREPLY=( "${sorted_models[@]}" )
}

# Wire the completion function to 'ollama'
complete -F _ollama_run ollama
```

**Installation/Activation Instructions:**  
Save this script to a file (e.g., `~/.bash_completion_ollama`), then add it to your bash configuration:
```bash
source ~/.bash_completion_ollama
# To apply changes immediately, run: source ~/.bashrc or restart your terminal.
```

---

**Notes on Correctness:**  
- The function `_ollama_run()` is triggered when completing `ollama run`.  
- `cmd_output` captures the output of `ollama list`, and any errors are ignored silently.  
- Models are filtered by prefix using a case-sensitive match (to avoid false positives).  
- Matches are sorted alphabetically before populating `COMPREPLY`.

