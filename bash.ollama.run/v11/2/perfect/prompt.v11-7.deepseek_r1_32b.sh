#Thinking...
#Alright, I need to create a robust Bash completion script for the `ollama run` command. The main issue is handling model names that contain colons, which Bash typically splits on.
#
#First, I'll structure the function `_ollama_completions`. It should check if the current command starts with 'ollama' and if the previous word is 'run'. If not, it exits early to avoid unnecessary processing.
#
#Next, I need to handle the colon issue. Using `_get_comp_words_by_ref -n :` will prevent Bash from splitting on colons. But since some systems might not have bash-completion loaded, I'll add a fallback that sets `cur` and `prev` manually.
#
#When `prev` is 'run', I retrieve model names using `ollama list`. Parsing this output with `awk` skips the header and extracts the first column. These models are stored in an array for filtering.
#
#I'll loop through each model, checking if it starts with `$cur`. Matches are collected into a sorted list to provide a clean completion suggestion.
#
#After setting `COMPREPLY`, calling `__ltrim_colon_completions "$cur"` ensures that colons don't cause display issues. Finally, I register the completion function with `complete`.
#
#I also need to handle cases where `ollama` isn't installed or if there are no models, ensuring the script doesn't break and handles these gracefully.
#
#Throughout, I'll use local variables for efficiency and include comments explaining each step, especially the colon handling parts. This ensures maintainability and clarity for anyone reading the script.
#...done thinking.

# Bash completion function for ollama run command with model name completion
_ollama_completions() {
    # Check if current command starts with 'ollama' and previous word is 'run'
    local command="${COMP_WORDS[0]}"
    if [[ "$command" != "ollama" ]]; then
        return 0
    fi

    # Handle colons in completion words correctly
    local cur prev
    # Use _get_comp_words_by_ref with -n : to handle colons properly
    if ! _get_comp_words_by_ref -n : cur prev; then
        # Fallback for systems without bash-completion
        local cword=$((COMP_CWORD))
        cur="${COMP_WORDS[cword]}"
        prev="${COMP_WORDS[cword-1]}"
    fi

    # Only trigger completion when previous word is 'run'
    if [[ "$prev" != "run" ]]; then
        COMPREPLY=()
        return 0
    fi

    # Retrieve list of available models from ollama list command
    local models
    if ! command -v ollama &> /dev/null; then
        COMPREPLY=()
        return 1
    fi
    
    # Extract model names from first column, skipping header
    models=$(ollama list 2>/dev/null |awk 'NR>1 {print $1}')

    # Filter matches for current word
    local matches=()
    local model
    for model in $models; do
        if [[ "$model" == "$cur"* ]]; then
            matches+=("$model")
        fi
    done

    # Sort the matches to ensure consistent completion order
    IFS=$'\n' sorted_matches=($(sort <<<"${matches[*]}"))
    unset IFS

    # Generate completions and handle colon trimming
    COMPREPLY=($(compgen -W "${sorted_matches[*]}" -- "$cur"))

    # Handle colon trimming for display purposes
    __ltrim_colon_completions "$cur"

    return 0
}

# Register the completion function with bash
complete -F _ollama_completions ollama
