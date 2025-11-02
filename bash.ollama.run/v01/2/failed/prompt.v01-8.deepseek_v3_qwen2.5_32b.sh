# ollama_complete - Bash completion for 'ollama run' command

_ollama_run() {
    local cur models ret=0
    COMPREPLY=()
    
    # Only complete if the second word is 'run'
    if [[ ${COMP_CWORD} -eq 2 && "${COMP_WORDS[1]}" == "run" ]]; then
        cur="${COMP_WORDS[COMP_CWORD]}"
        
        # Get model list from `ollama list`, split into array
        IFS=$'\n' models=($(LC_ALL=C ollama list 2>/dev/null | tr ' ' '\n'))
        
        # Filter models that start with the current prefix (case-insensitive)
        COMPREPLY=( $(compgen -W "${models[*]}" -- "$cur") )
    fi
}

complete -F _ollama_run ollama

# Installation:
# 1. Save this script as ~/.bash_completion.d/ollama.sh
# 2. Add to your .bashrc: [[ $- == *i* ]] && source ~/.bash_completion.d/ollama.sh
# 3. Activate immediately: source ~/.bash_completion.d/ollama.sh

# [[HUMAN COMMENTED-OUT]]
# ### Explanation:
# 1. **Completion Function**: The `_ollama_run` function handles completion when the user types `ollama run <Tab>`. It checks if the second word is "run" and fetches models via `ollama list`.
# 2. **Error Handling**: `ollama list` runs with `LC_ALL=C` for consistent splitting, and errors are silenced (`2>/dev/null`). 
# 3. **Filtering**: Matches are generated using `compgen`, ensuring case-insensitive prefix matching.
# 4. **Installation**: The script is sourced from `.bashrc` to activate completions dynamically.
# 
# This ensures robustness by silently handling command failures and adheres to POSIX-compliant operations without external dependencies like `jq`.
