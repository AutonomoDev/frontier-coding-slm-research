# Ollama run model completion function
_ollama_run_model() {
    # Get current and previous words safely
    _get_comp_words_by_ref "$@" || {
        cur=${COMP_WORDS[COMP_CWORD]}
        prev=${COMP_WORDS[COMP_CWORD-1]}
    }
    
    # Only trigger if command is 'ollama' and previous word is 'run'
    if [[ $COMMAND == "ollama" && $prev == "run" ]]; then
        # Get list of models once
        local models=$(ollama list 2>/dev/null)
        
        # If ollama list fails or returns empty, return nothing
        if ! [[ "$models" ]]; then
            return
        fi
        
        # Split output into an array and filter models by current prefix
        local model_list=($(echo "$models" | tr -s '[:space:]'))
        local completions=()
        
        for model in "${model_list[@]}"; do
            if [[ $model == "$cur"* ]]; then
                completions+=("$model")
            fi
        done
        
        # Sort completions alphabetically
        IFS=$'\n' completions=($(sort <<<"${completions[*]}"))
        
        # Generate completion output
        compgen -W "${completions[*]}" -- "$cur"
    fi
}

# Install and activate: add to .bashrc and source it
# Source this script or embed the function directly in your .bashrc.
# Then run 'source ~/.bashrc' to apply changes.

complete -F _ollama_run_model ollama
