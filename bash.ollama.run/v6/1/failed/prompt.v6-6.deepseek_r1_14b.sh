#Thinking...
#Alright, I need to create a Bash completion script for the `ollama run` command. The goal is to provide model name suggestions when the user presses TAB after typing `run`.
#
#First, I should understand how Bash completions work. From what I know, Bash uses functions like `_complete` and variables like `COMP_WORDS`, `COMP_CWORD`, etc., to handle completions.
#
#The script must only activate when the command is `ollama run`, so I need to check that the first word is 'ollama' and the previous word is exactly 'run'. If those conditions aren't met, it shouldn't do anything.
#
#Next, I have to parse the output of `ollama list`. The output includes headers, so I must skip them. Each line after the header has a model name in the first column. Using `cut -d$'\t' -f1` should extract that. But I also need to handle cases where there are spaces or tabs in the names.
#
#I'll store these model names in an array. Then, when the user types something, I need to filter this array based on what they've typed so far. For example, if they type 'co', only models starting with 'co' should appear.
#
#The script must avoid suggesting filenames if no models match. So, after filtering, if there are no results, it shouldn't output anything.
#
#I also need to ensure that the suggestions don't have duplicates. So, I'll process the array to remove any duplicates before offering them as completions.
#
#Now, considering the Bash completion framework, I should use `_get_comp_words_by_ref` to get `cur` and `prev`. But since some environments might not have this function, I need a fallback that manually sets these variables from `COMP_WORDS` and `COMP_CWORD`.
#
#Putting it all together:
#
#1. Check if the command is `ollama run`.
#2. Use `_get_comp_words_by_ref` or fall back to manual setup.
#3. Get model names by running `ollama list`, parsing the output, skipping headers.
#4. Filter models based on the current input.
#5. Process the results to remove duplicates and set `COMPREPLY`.
#
#I need to make sure all this is done in a way that's compatible with Bash v2 completions and only uses standard tools like `cut` and `grep`.
#...done thinking.

# bash completion script for ollama run command

complete -F _ollama_run_completions ollama

_OllamaRunModels() {
    # Extract model names from ollama list output
    local models
    models=$(ollama list | tail -n +2 | cut -d$'\t' -f1)

    # Convert to array and remove duplicates
    local unique_models=($(printf "%s\n" "$models" | sort -u))

    # Filter based on current input
    local matches=()
    for model in "${unique_models[@]}"; do
        if [[ "$model" == "$1"* ]]; then
            matches+=("$model")
        fi
    done

    return 0
}

function _ollama_run_completions {
    # Check if command is ollama run
    local cmd=${COMP_WORDS[0]}
    local prev=${COMP_WORDS[$COMP_CWORD-1]}

    if [[ "$cmd" != "ollama" || "$prev" != "run" ]]; then
        return 2 # Not applicable
    fi

    # Get the current word being completed
    local cur
    _get_comp_words_by_ref -n _current_comp
    cur=${_current_comp:-${COMP_WORDS[COMP_CWORD]}}

    # Generate model suggestions
    local model_suggestions=$(_OllamaRunModels "$cur")

    # Set the completion results
    COMPREPLY=($(printf "%s\n" $model_suggestions))
}

# Example usage:
# When typing `ollama run co<TAB>`, only models starting with 'co' will appear

# bash-completion script for ollama run command

# Function to retrieve model names from ollama list output
_ollama_run_models() {
    # Get the list of models
    local models=$(ollama list | tail -n +2 | cut -d$'\t' -f1)

    # Convert to an array and remove duplicates
    local unique_models=($(printf "%s\n" "$models" | sort -u))

    # Return models as a space-separated string
    echo "${unique_models[*]}"
}

# Bash completion function for ollama run command
_ollama_run_completions() {
    # Check if the previous word is 'run' and first word is 'ollama'
    local cmd=${COMP_WORDS[0]}
    local prev=${COMP_WORDS[$COMP_CWORD-1]}

    if [[ "$cmd" != "ollama" || "$prev" != "run" ]]; then
        return 2 # Indicate no completion available
    fi

    # Get the current word and previous word
    _get_comp_words_by_ref -n cur -p prev || {
        cur=${COMP_WORDS[COMP_CWORD]}
        prev=${COMP_WORDS[$COMP_CWORD-1]}
    }

    # Get all models
    local models=$(_ollama_run_models)

    # Filter models based on current input
    local matches=($(printf "%s\n" "$models" | grep "^${cur}"))

    # Set the completion results
    COMPREPLY=( $(printf "%s\n" "${matches[@]}") )
}

# Register the completion function for ollama command
complete -F _ollama_run_completions ollama

