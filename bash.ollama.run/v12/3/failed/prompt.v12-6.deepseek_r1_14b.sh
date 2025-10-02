#Thinking...
#Okay, I need to create a Bash completion script for the `ollama run` command. The main goal is to complete model names from the output of `ollama list`. Model names often include colons, which can cause issues in Bash completions because Bash splits on colons by default.
#
#First, I'll start by defining the function `_ollama_completions`. This function will handle the completion logic.
#
#The first step inside the function is to check if the command is `ollama run`. I'll do this by verifying that the first word is "ollama" and the previous word is "run". If not, set `COMPREPLY` to an empty array and return early. This ensures we only complete after `ollama run`.
#
#Next, I need to handle colons correctly. Using `_get_comp_words_by_ref` with `-n :` tells Bash not to split on colons when getting the current and previous words. If this function isn't available, I'll fallback to using `COMP_WORDS` directly.
#
#Then, if the previous word is "run", I need to check if the `ollama` command exists by using `command -v ollama`. If it doesn't exist, set `COMPREPLY` to empty and return.
#
#After confirming `ollama` exists, I'll run `ollama list` with errors redirected to `/dev/null` to avoid output. The output is processed line by line. I need to skip the header row "NAME ID SIZE MODIFIED" and any empty lines. For each valid line, I'll extract the first column (model name) using `awk '{print $1}'`.
#
#I'll store these model names in an array called `models`. If this array is empty after processing, set `COMPREPLY` to empty and return.
#
#Next, I'll find matches where model names start with `$cur`. These are stored in the `matches` array. I'll sort these matches to ensure they're presented in a logical order.
#
#Using `compgen -W`, I'll generate the completion options from the sorted matches. This is assigned back to `COMPREPLY`.
#
#Finally, it's crucial to call `__ltrim_colon_completions "$cur"` to fix how suggestions display after colons. Without this, completions won't show correctly when a colon is present.
#
#After setting up all the logic, I'll register the completion function with `complete -F _ollama_completions ollama` so that Bash recognizes it for command-line completions.
#
#Throughout the process, I made sure to use local variables to keep things clean and avoid unnecessary global state. Error handling includes checking if commands exist and gracefully handling cases where no models are found or commands fail.
#...done thinking.

# Bash completion script for ollama run command
# Completes model names from ollama list output, handles colons correctly

complete -F _ollama_completions ollama

function _ollama_completions() {
    # Check if we're completing after "ollama run"
    if [[ "${COMP_WORDS[0]}" != "ollama" || "${prev}" != "run" ]]; then
        COMPREPLY=()
        return
    fi

    # Handle colon in model names by getting words without splitting on :
    if ! _get_comp_words_by_ref -n : cur prev; then
        # Fallback to basic index access if function isn't available
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # Check if ollama command exists
    if ! command -v ollama &> /dev/null; then
        COMPREPLY=()
        return
    fi

    # Get list of models and extract names
    local models=()
    local header=true
    ollama list 2>/dev/null | while read -r line; do
        if $header; then
            header=false
            continue
        fi
        if [[ -z "$line" ]]; then continue
        fi
        # Extract first column (model name)
        model=$(echo "$line" | awk '{print $1}')
        models+=("$model")
    done

    # If no models found, return empty
    if [ ${#models[@]} -eq 0 ]; then
        COMPREPLY=()
        return
    fi

    # Find matches starting with current word
    local matches=()
    for model in "${models[@]}"; do
        if [[ "$model" == "$cur"* ]]; then
            matches+=("$model")
        fi
    done

    # Sort the matches before using compgen
    sorted_matches=$(printf '%s\n' "${matches[@]}" | sort)

    # Generate completion options
    COMPREPLY=( $(compgen -W "$sorted_matches" -- "$cur") )

    # Critical: Fix colon handling for completions
    __ltrim_colon_completions "$cur"
}

# Example usage:
# When typing "ollama run codellama:", it will complete model names like "codellama:13b", "codellama:7b" etc.
