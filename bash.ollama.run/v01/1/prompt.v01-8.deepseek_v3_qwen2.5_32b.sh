```bash
# bash-completion for ollama run <model>
_ollama_run() {
    local cur model_list models

    # Check if we're completing after 'run'
    [[ ${COMP_WORDS[0]} == "ollama" ]] || return 1
    case ${COMP_CWORD} in
        2) # Completing the second argument (the model)
            COMPREPLY=()
            cur="${COMP_WORDS[COMP_CWORD]}"
            
            if models=$(ollama list 2>/dev/null); then
                IFS=$'\n' read -r -d '' -a model_list <<< "$models"
                
                # Filter models that start with 'cur'
                for model in "${model_list[@]}"; do
                    [[ $model == $cur* ]] && COMPREPLY+=("$model")
                done
            fi
            
            return 0
    esac
}
complete -F _ollama_run ollama

# To activate this completion:
#
# Save this script to a file, say /etc/bash_completion.d/ollama-completion.bash,
# or add the above code directly into your .bashrc.
# Then source it (e.g., `source /path/to/script`) and test by typing 'ollama run <Tab>'.
```

### Installation Instructions
1. **Save to Completion Directory**: 
   Place the script in `/etc/bash_completion.d/` or a similar directory where your system loads completions.

2. **Add to .bashrc**:
   Alternatively, copy the code directly into your `~/.bashrc`.

3. **Reload Shell Configuration**:
   After saving or adding, source the file (e.g., `source /path/to/script`) or restart your terminal session.

4. **Test Completion**:
   Type `ollama run` followed by `<Tab>` to see model suggestions.

