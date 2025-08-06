# Bash completion function for ollama run <model>
_ollama_run() {
    local cur prev cmd
    # Get current and previous words; fallback if _get_comp_words_by_ref isn't available
    _get_comp_words_by_ref -n 2 -c cur prev || { 
        cur=${COMP_WORDS[COMP_CWORD]}
        prev=${COMP_WORDS[COMP_CWORD-1]}
    }
    
    # Only trigger when completing model after 'run'
    if [[ $prev != "run" ]] && ! (( ${#COMP_WORDS[@]} > 2 && ${COMP_WORDS[-2]} == "run" )); then
        return
    fi

    # Get list of models, exit silently on failure
    local models_output=$(ollama list 2>/dev/null)
    if [[ $? -ne 0 || -z "$models_output" ]]; then
        return
    fi

    # Split output into array and filter by current word prefix
    IFS=$'\n' read -r -d '' -a models <<< "$models_output"
    local matches=()
    for model in "${models[@]}"; do
        if [[ $model == "$cur"* ]]; then
            matches+=("$model")
        fi
    done

    # Sort matching models alphabetically
    IFS=$'\n' sorted_matches=($(sort <<< "${matches[*]}"))
    
    # Set completions
    COMPREPLY=()
    compgen -W "${sorted_matches[*]}" -- "$cur" > /dev/null
}

# Attach completion function to ollama command
complete -F _ollama_run ollama

# Installation: Add the following line to your ~/.bashrc and source it
# echo "source ~/.bash_completion" >> ~/.bashrc && source ~/.bashrc



