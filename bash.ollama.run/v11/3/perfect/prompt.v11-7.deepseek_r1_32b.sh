#Thinking...
#Okay, I need to create a Bash completion script for the `ollama run` command that dynamically completes model names. The models can have colons in their names, which is tricky because Bash splits words on colons by default. So, I have to handle this properly.
#
#First, I'll define a function named `_ollama_completions`. This function will check if the current command is `ollama` and if the previous word is `run`. If not, it returns early to avoid unnecessary processing.
#
#Next, handling colons is crucial. I remember that using `_get_comp_words_by_ref -n :` can prevent Bash from splitting words on colons. But some systems might not have bash-completion installed, so I need a fallback. In the fallback, I'll directly set `cur` and `prev` from `COMP_WORDS`, which might not handle colons as well but is necessary for compatibility.
#
#If the previous word is `run`, I proceed to fetch model names using `ollama list`. The output includes headers, so I need to skip the first line. Using `awk '{print $1}'` after the second line should extract the model names correctly.
#
#I'll store these models in an array and filter them based on the current word (`cur`). This involves checking each model name to see if it starts with `cur`, considering case sensitivity.
#
#After filtering, I sort the matches to ensure a consistent order. Then, using `compgen -W` with the sorted list generates possible completions.
#
#But wait, without trimming colons in the completion display, users might see extra colons. So, calling `__ltrim_colon_completions "$cur"` is essential to clean up the output and handle cases where a colon was part of the word break.
#
#Finally, I register the completion function with `complete -F _ollama_completions ollama`. This ensures that whenever someone types `ollama run` followed by a tab, the script provides the correct model names without breaking on colons.
#
#I should also include error handling. Check if `ollama` exists before calling it to avoid errors. If there are no matches, set `COMPREPLY=()` to indicate no completions available.
#
#Putting it all together, I structure the script with detailed comments explaining each step, especially the colon handling parts. This makes the code more maintainable and understandable for others who might look at it later.
#...done thinking.

# Auto-generated Bash completion script for ollama run command
_ollama_completions() {
    # Only handle completions for 'ollama' commands
    if [[ ${COMP_WORDS[0]} != "ollama" ]]; then
        return 0
    fi
    
    # Check if previous word is 'run'
    local cur prev
    if ! _get_comp_words_by_ref -n : cur prev; then
        # Fallback for systems without bash-completion
        local cword=$((COMP_CWORD))
        cur="${COMP_WORDS[cword]}"
        prev="${COMP_WORDS[cword-1]}"
    fi
    
    # Only trigger completions when previous word is 'run'
    if [[ "${prev}" != "run" ]]; then
        return 0
    fi

    # Get list of available models from ollama list command
    local models=()
    if command -v ollama &> /dev/null; then
        while IFS=$'\n' read -r line; do
            # Skip header row and parse model names
            [[ "$line" =~ ^NAME ]] && continue
            model=$(echo "$line" | awk '{print $1}')
            models+=("$model")
        done < <(ollama list)
    fi

    # Generate matches for current word
    local matches=()
    for model in "${models[@]}"; do
        if [[ "$model" == "$cur"* ]]; then
            matches+=("$model")
        fi
    done

    # Sort matches alphabetically
    IFS=$'\n' sorted_matches=($(sort <<< "${matches[*]}"))
    
    # Generate completion suggestions
    COMPREPLY=( $(compgen -W "${sorted_matches[*]}" -- "$cur") )
    
    # Handle colon-separated completions properly
    __ltrim_colon_completions "$cur"
}

# Register the completion function with bash
complete -F _ollama_completions ollama
