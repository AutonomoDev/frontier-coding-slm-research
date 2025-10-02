#Thinking...
#Alright, I need to create a Bash completion script for the `ollama run` command. The main goal is to make sure that when someone types `ollama run` followed by a model name, they get suggestions based on the models listed by `ollama list`.
#
#First, I remember that model names often have colons, like `codellama:13b`. Bash has a default behavior where it splits words at colons, which would mess up the completion. So, I need to handle this carefully.
#
#I'll start by defining a function called `_ollama_completions` as per the requirements. The function needs to check if the command being completed is indeed `ollama run`. If not, it should do nothing and return early. That means checking if the first word is "ollama" and the previous word is "run".
#
#Next, I need to handle the colon issue. I'll use `_get_comp_words_by_ref` with the `-n :` option to tell Bash not to split on colons. If this function isn't available (maybe in older versions of bash-completion), I'll fall back to using `COMP_WORDS` directly to get `cur` and `prev`.
#
#Once that's set up, I check if the previous word is "run". Then, I verify if the `ollama` command exists. If it doesn't, there's nothing to complete, so I return with an empty COMPREPLY.
#
#I'll run `ollama list`, redirecting any errors to /dev/null in case something goes wrong. The output needs parsing: I have to skip the header line and extract only the model names from the first column. Using `awk '{print $1}'` should do that. I'll read each line, trim whitespace, and collect non-empty model names into an array.
#
#If there are no models found, COMPREPLY remains empty. Otherwise, I filter the models to those starting with the current word (`$cur`). Sorting these matches will make the suggestions appear in a logical order.
#
#Setting `COMPREPLY` is straightforward using `compgen -W` with the sorted matches. But crucially, after setting COMPREPLY, I must call `__ltrim_colon_completions "$cur"` to handle how the suggestions are displayed when a colon is present. This function ensures that the colon doesn't cause issues in the completion list.
#
#Finally, I register the completion function with `complete -F _ollama_completions ollama` so that Bash knows to use this function for completing the `ollama` command.
#
#I made sure all variables are local for safety and included comments to explain each part, especially the handling of colons and parsing. This should make the script robust and maintainable.
#...done thinking.

_ollama_completions() {
    # Only complete after "ollama run"
    local first_word=${COMP_WORDS[0]}
    if [[ "$first_word" != "ollama" ]] || [[ "${prev}" != "run" ]]; then
        COMPREPLY=()
        return 0
    fi

    # Handle colon in model names
    local cur prev
    if ! _get_comp_words_by_ref -n : cur prev; then
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # Only complete models after "run"
    if [[ "$prev" != "run" ]]; then
        COMPREPLY=()
        return 0
    fi

    # Check if ollama command exists
    if ! command -v ollama &> /dev/null; then
        COMPREPLY=()
        return 0
    fi

    # Get list of models from ollama
    local models=()
    while IFS=$'\n' read -r line; do
        # Skip header and empty lines
        if [[ "$line" == "NAME ID SIZE MODIFIED" ]] || [[ -z "$line" ]]; then
            continue
        fi

        # Extract first column (model name)
        local model=$(echo "$line" | awk '{print $1}' | xargs)
        if [[ -n "$model" ]]; then
            models+=("$model")
        fi
    done < <(ollama list 2>/dev/null)

    # No models found
    if [[ ${#models[@]} -eq 0 ]]; then
        COMPREPLY=()
        return 0
    fi

    # Filter matches starting with current word
    local matches=()
    for model in "${models[@]}"; do
        if [[ "$model" == "$cur"* ]]; then
            matches+=("$model")
        fi
    done

    # Sort matches
    local sorted_matches
    sorted_matches=$(printf '%s\n' "${matches[@]}" | sort)

    # Generate completions and handle colon correctly
    COMPREPLY=($(compgen -W "$sorted_matches" -- "$cur"))
    __ltrim_colon_completions "$cur"

    return 0
}

# Register the completion function
complete -F _ollama_completions ollama
