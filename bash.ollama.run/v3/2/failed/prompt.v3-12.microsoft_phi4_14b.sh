# Bash completion function for 'ollama run <model>'
_ollama_run_completion() {
    # Check if we are completing after 'ollama run'
    local cur prev words cword
    _get_comp_words_by_ref -n : cur prev words cword

    if [[ $cword -eq 2 && "${words[0]}" == "ollama" && "${words[1]}" == "run" ]]; then
        # Retrieve model list from 'ollama list'
        local models
        models=$(ollama list 2>/dev/null)

        if [[ $? -ne 0 || -z "$models" ]]; then
            return # Graceful failure on error or empty output
        fi

        # Extract model names, sort them, and filter by current prefix
        mapfile -t sorted_models < <(echo "$models" | awk '/^  / {print $2}' | sort)

        local completions=()
        for model in "${sorted_models[@]}"; do
            if [[ "$model" == "$cur"* ]]; then
                completions+=("$model")
            fi
        done

        # Populate COMPREPLY with filtered and sorted models
        COMPREPLY=( $(compgen -W "${completions[*]}" -- "$cur") )
    fi
}

# Fallback for _get_comp_words_by_ref if it's not defined
if ! type _get_comp_words_by_ref &>/dev/null; then
    _ollama_run_completion_fallback() {
        local cur prev words cword
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
        words=("${COMP_WORDS[@]}")
        cword=$COMP_CWORD

        # Call the main function with fallback variables
        _ollama_run_completion
    }
fi

# Attach completion to 'ollama'
complete -F _ollama_run_completion_fallback ollama

# Installation instructions:
# Save this script in a file, e.g., ~/.bash_ollama_completion.sh
# Add the following line to your .bashrc:
# source ~/.bash_ollama_completion.sh
# Then reload your shell: source ~/.bashrc or open a new terminal session.
