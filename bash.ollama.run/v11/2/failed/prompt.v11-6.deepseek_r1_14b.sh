#Thinking...
#Okay, I need to create a bash completion script for the `ollama run` command that dynamically completes model names from `ollama list`. The main challenge is handling model names with colons without breaking due to default word-splitting.
#
#First, I'll start by defining the function `_ollama_completions`. This function will handle completions only when the command is `ollama` and the previous word is `run`.
#
#Next, I need to correctly parse the words around a colon. Using `_get_comp_words_by_ref` with `-n :` will help avoid issues on systems where bash-completion is installed. If it's not available, I'll fallback to parsing `COMP_WORDS` directly.
#
#Then, when `prev` is "run", I'll retrieve model names using `ollama list`. Parsing this output correctly, skipping the header, and extracting the first column is crucial. I'll use `awk` for this, focusing on lines after the header.
#
#I need to filter these models based on the current word `$cur`. Storing them in an array and checking each against a pattern will allow me to find matches efficiently.
#
#Once I have the matches, sorting them and using `compgen -W` will generate the appropriate completions. It's important to call `__ltrim_colon_completions` after setting `COMPREPLY` to handle the display correctly when colons are present.
#
#Finally, I'll register the completion function with `complete`. I'll also ensure error handling by checking if `ollama` exists and gracefully handling empty outputs.
#
#Throughout this process, I must avoid adding any markdown or extra text, keeping everything as valid bash code with inline comments for clarity.
#...done thinking.

# Bash completion script for ollama run command
# Function to handle completions
function _ollama_completions {
    # Only trigger for 'ollama' command and when previous word is 'run'
    if [[ ${COMP_WORDS[0]} != "ollama" || "${prev}" != "run" ]]; then
        return 0
    fi

    # Try to get words with proper handling of colons
    if ! _get_comp_words_by_ref -n : cur prev; then
        # Fallback for systems without bash-completion
        local cur="${COMP_WORDS[COMP_CWORD]}"
        local prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # If we're completing after 'run', generate model completions
    if [[ ${prev} == "run" ]]; then
        # Get list of available models
        local models=()
        if command -v ollama > /dev/null 2>&1; then
            # Extract model names from first column, skipping header
            while IFS=$'\t' read -r name _ _ _; do
                models+=("$name")
            done < <(ollama list | awk 'NR>1 {print $1}')
        fi

        # Filter matching models
        local matches=()
        for model in "${models[@]}"; do
            if [[ ${model} == "$cur"* ]]; then
                matches+=("$model")
            fi
        done

        # Generate completion output
        if [[ ${#matches[@]} -gt 0 ]]; then
            COMPREPLY=($(compgen -W "$(printf '%s\n' "${matches[@]}" | sort)" -- "$cur"))
            __ltrim_colon_completions "$cur"
        else
            COMPREPLY=()
        fi
    fi
}

# Register the completion function for ollama command
complete -F _ollama_completions ollama

# Explanation:
# - Handles model names with colons by properly parsing words
# - Uses both bash-completion (if available) and fallback parsing
# - Dynamically retrieves models from 'ollama list' output
# - Filters and sorts matches for better completion experience
# - Properly trims colons in completions display
