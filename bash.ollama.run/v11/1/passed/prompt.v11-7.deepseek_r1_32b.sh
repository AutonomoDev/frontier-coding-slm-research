#Thinking...
#Okay, I need to create a robust Bash completion script for the `ollama run` command. The main issue is handling model names that contain colons, which Bash treats as word separators by default. This can break the completion logic.
#
#First, I'll structure the function `_ollama_completions`. It should check if the current command is `ollama` and the previous word is `run`. If not, it returns early with an empty COMPREPLY to avoid unnecessary processing.
#
#Next, handling colons properly is crucial. By default, Bash splits words on colons, which messes up model names like `codellama:13b`. To fix this, I'll use `_get_comp_words_by_ref` with the `-n :` flag. This tells Bash not to split words at colons. But since some systems might not have bash-completion loaded, I need a fallback. The fallback sets `cur` and `prev` directly from `COMP_WORDS`, ensuring compatibility.
#
#For completion logic, when the previous word is `run`, I'll retrieve model names using `ollama list`. Parsing this output with awk or a while loop will extract the first column, skipping the header. Then, I'll filter these models to match the current input (`$cur`), sort them, and use `compgen -W` to generate possible completions.
#
#It's critical to call `__ltrim_colon_completions "$cur"` after setting COMPREPLY. This function ensures that when a colon is present in the model name, Bash displays the completions correctly without splitting on it.
#
#I'll also include error handling: check if `ollama` exists before running commands and handle cases where the output might be empty or fail. Using local variables appropriately will prevent unintended side effects.
#
#Finally, I'll register the completion function with `complete -F _ollama_completions ollama` so that it's active in the shell. Adding detailed inline comments will help others understand each part of the script, especially the colon handling sections.
#
#Putting it all together, the script should dynamically complete model names correctly, even when they contain colons, ensuring a smooth user experience.
#...done thinking.

# Bash completion script for ollama run command
_ollama_completions() {
    local cur prev cmd

    # Check if current command is 'ollama' and previous word is 'run'
    cmd="${COMP_WORDS[0]}"
    if [[ "${cmd}" != "ollama" ]]; then
        return 1
    fi
    
    # Handle colon in word breaks using _get_comp_words_by_ref with fallback
    if ! _get_comp_words_by_ref -n : cur prev; then
        # Fallback for systems without bash-completion
        local cword=$((COMP_CWORD))
        cur="${COMP_WORDS[cword]}"
        prev="${COMP_WORDS[cword-1]}"
    fi

    # Only complete when previous word is 'run'
    if [[ "${prev}" != "run" ]]; then
        return 1
    fi

    # Check if ollama command exists
    command -v ollama &> /dev/null || {
        COMPREPLY=()
        return 1
    }

    # Get list of models from 'ollama list' and extract first column (model names)
    local models=$(ollama list 2>/dev/null | awk '{if(NR>1) print $1}')

    if [[ $? -ne 0 ]] || [[ -z "$models" ]]; then
        COMPREPLY=()
        return 1
    fi

    # Filter matches where model name starts with current word
    local sorted_matches=$(echo "$models" | while read -r line; do
        if [[ "$line" == "$cur"* ]]; then
            echo "$line"
        fi
    done | sort)

    # Generate completions
    COMPREPLY=($(compgen -W "$sorted_matches" -- "$cur"))

    # Critical step to handle colon in completions display
    __ltrim_colon_completions "$cur"

    return 0
}

# Register completion function for ollama command
complete -F _ollama_completions ollama

