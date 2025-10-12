# Thinking...
# Alright, I need to create a Bash completion script for the `ollama run` command. Let me go through the requirements and figure out how to approach this.
#
# First, the function should be named `_ollama_completions`. It's important that it only activates when the user types `ollama run`, so I'll check if `COMP_WORDS[0]` is "ollama" and `COMP_WORDS[1]` is "run". If not, I'll exit early.
#
# Next, handling colons in model names is tricky. By default, Bash splits on colons, which messes up the completions. The solution is to use `_get_comp_words_by_ref -n : cur prev` to prevent splitting. If that doesn't work, I'll manually extract from `COMP_WORDS`.
#
# For parsing the models, I need to run `ollama list` and process its output. I should check if `ollama` exists first using `command -v`. Then, redirect stderr to /dev/null in case there are errors. The output has a header line that I must skip, so I'll read each line after the first and extract the first column using `awk '{print $1}'`.
#
# Once I have the model list, I'll filter them based on the current prefix (`$cur`). Sorting isn't strictly necessary for completion, but it's good practice. Finally, I'll set `COMPREPLY` with `compgen` to provide the suggestions and call `__ltrim_colon_completions` to handle any trailing colons.
#
# I should also register the function so that Bash recognizes it using `complete -F _ollama_completions ollama`.
#
# Putting it all together, I'll structure the script step by step, ensuring each part meets the requirements and handles edge cases like missing models or the `ollama` command not being installed.
# ...done thinking.

# Bash completion function for 'ollama run'
# Must be named _ollama_completions
function _ollama_completions {
    # Critical check: Only activate if command is 'ollama run'
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

    # Handle colon in model names (e.g., codellama:13b)
    _get_comp_words_by_ref -n : cur prev

    # Get list of available models
    local models=()
    
    # Check if 'ollama' command exists
    if command -v ollama &>/dev/null; then
        # Run 'ollama list' and parse output
        while IFS= read -r line; do
            # Skip header line
            [[ "$line" == "NAME"* ]] && continue
            # Extract first column (model name) using awk to handle multi-word names
            models+=($(echo "$line" | awk '{print $1}'))
        done < <(ollama list 2>/dev/null)
    fi

    # Generate completions based on current prefix
    COMPREPLY=($(compgen -W "${models[*]}" -- "$cur"))
    
    # Fix colon handling in completions (MANDATORY)
    __ltrim_colon_completions "$cur"
}

# Register the completion function for 'ollama'
complete -F _ollama_completions ollama
