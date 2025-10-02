#Thinking...
#Okay, I need to create a Bash completion script for the `ollama run` command. The goal is to complete model names from the output of `ollama list`. Model names often include colons, like `codellama:13b`, so handling colons correctly is crucial.
#
#First, I'll start by creating a function called `_ollama_completions`. This function will handle the completion logic.
#
#Inside the function, I need to check if the command being executed starts with "ollama" and the previous word is "run". If not, there's nothing to complete, so I'll set `COMPREPLY` to an empty array and return.
#
#Next, I must address the issue of colons in model names. By default, Bash splits on colons, which breaks completion. To fix this, I'll use `_get_comp_words_by_ref -n : cur prev`. If this function isn't available, I'll fall back to using `COMP_WORDS` directly to get the current and previous words.
#
#Then, if the previous word is "run", I need to check if the `ollama` command exists. I'll use `command -v ollama &> /dev/null` for this check. If it doesn't exist, again, set `COMPREPLY` to empty and return.
#
#If `ollama` exists, I'll run `ollama list 2>/dev/null` to get the model names. I'll parse each line, skipping the header and any empty lines. For each valid line, I'll extract the first column (model name) using `awk '{print $1}'`.
#
#These model names will be stored in an array called `models`. If this array is empty after parsing, there are no models to complete, so set `COMPREPLY` to empty and return.
#
#Now, I'll find matches by checking which model names start with the current word (`$cur`). These matches will be collected in an array. I'll sort these matches alphabetically to make the suggestions orderly.
#
#Using `compgen -W`, I'll generate the completion options based on the sorted matches. This command will provide the appropriate completions for the current word.
#
#Finally, it's critical to call `__ltrim_colon_completions "$cur"` after setting `COMPREPLY`. This ensures that when a colon is present in the model name, the suggestions are displayed correctly without any issues.
#
#After setting up everything within the function, I'll register the completion with `complete -F _ollama_completions ollama` so that Bash recognizes this function for command completion.
#
#Throughout the script, I'll make sure to use local variables to keep the scope clean and handle errors gracefully by redirecting output to `/dev/null` where necessary. This makes the script robust and prevents unexpected behavior.
#...done thinking.

# Bash completion script for ollama run command
function _ollama_completions {
    # Check if first word is "ollama" and previous word is "run"
    if [[ "${COMP_WORDS[0]}" != "ollama" || "${prev}" != "run" ]]; then
        COMPREPLY=()
        return
    fi

    # Handle colon completion correctly
    if ! _get_comp_words_by_ref -n : cur prev; then
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # Check if ollama command exists
    if ! command -v ollama &> /dev/null; then
        COMPREPLY=()
        return
    fi

    # Get model names from ollama list
    models=()
    while read -r line; do
        # Skip header and empty lines
        if [[ "$line" == "NAME ID SIZE MODIFIED" || "$line" == "" ]]; then
            continue
        fi
        # Extract model name (first column)
        model="$(echo "$line" | awk '{print $1}')"
        if [[ -n "$model" && "$model" != ":*" ]]; then
            models+=("$model")
        fi
    done < <(ollama list 2>/dev/null)

    # If no models found, return empty
    if [[ ${#models[@]} == 0 ]]; then
        COMPREPLY=()
        return
    fi

    # Find matching models
    matches=()
    for model in "${models[@]}"; do
        if [[ "$model" == "$cur"* ]]; then
            matches+=("$model")
        fi
    done

    # Sort matches alphabetically
    sorted_matches=$(printf '%s\n' "${matches[@]}" | sort)

    # Generate completions
    COMPREPLY=( $(compgen -W "$sorted_matches" -- "$cur") )

    # Fix colon completion display
    __ltrim_colon_completions "$cur"
}

# Register the completion function
complete -F _ollama_completions ollama
