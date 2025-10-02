#Thinking...
#Alright, I need to create a Bash completion script for the `ollama run` command that dynamically completes model names from `ollama list`. The main issue is handling model names with colons, which Bash treats as word breaks.
#
#First, I'll structure the function `_ollama_completions` to handle completions. It should check if the command is "ollama" and the previous word is "run". If not, it returns early.
#
#Next, I need to parse the current (`cur`) and previous (`prev`) words correctly. Using `_get_comp_words_by_ref -n :` helps split words without treating colons as separators. However, this might not be available everywhere, so a fallback sets `cur` and `prev` from `COMP_WORDS`.
#
#If `prev` is "run", I'll fetch model names using `ollama list`. Parsing with `awk` skips the header and extracts the first column. Models are stored in an array.
#
#Then, I filter models matching `$cur` and sort them. Using `compgen -W` generates completions. It's crucial to call `__ltrim_colon_completions "$cur"` after setting `COMPREPLY` to handle colon display correctly.
#
#I'll also ensure error handling: check if `ollama` exists, handle empty output, and use local variables. If no matches, set `COMPREPLY=()`.
#
#Finally, I'll register the function with `complete -F _ollama_completions ollama`. All steps are commented for clarity.
#...done thinking.

# Bash completion script for Ollama run command
_ollama_completions() {
    local cur prev cmd

    # Check if command is 'ollama' and previous word is 'run'
    cmd="${COMP_WORDS[0]}"
    if [[ "$cmd" != "ollama" ]]; then
        return 0
    fi

    # Get current and previous words, handling colons properly
    local -a comp_words
    if ! _get_comp_words_by_ref -n : cur prev; then
        # Fallback for systems without bash-completion
        comp_words=("${COMP_WORDS[@]}")
        local cword=$(( COMP_CWORD ))
        cur="${comp_words[$cword]}"
        prev="${comp_words[$((cword-1))]}"
    fi

    # Only complete model names after 'run'
    if [[ "$prev" != "run" ]]; then
        return 0
    fi

    # Retrieve and parse available models from ollama list output
    local -a models
    if command -v ollama &> /dev/null; then
        while IFS= read -r line; do
            [[ "$line" == "NAME"* ]] && continue  # Skip header
            model_name=$(echo "$line" | awk '{print $1}' | sed 's/[[:space:]]*$//')
            models+=("$model_name")
        done < <(ollama list 2>/dev/null)
    fi

    # Filter matching models and sort them
    local -a matches
    for model in "${models[@]}"; do
        [[ "$model" == "$cur"* ]] && matches+=("$model")
    done

    if (( ${#matches[@]} > 0 )); then
        COMPREPLY=($(compgen -W "${matches[*]}" -- "$cur"))
        __ltrim_colon_completions "$cur"
    else
        COMPREPLY=()
    fi
}

complete -F _ollama_completions ollama
