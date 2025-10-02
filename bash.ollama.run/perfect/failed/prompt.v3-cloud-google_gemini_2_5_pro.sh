#!/usr/bin/env bash
#
# bash-completion script for ollama run <model>

_ollama_completion() {
    # Get current and previous words; provide a fallback for older bash versions.
    local cur prev
    if type _get_comp_words_by_ref &>/dev/null; then
        _get_comp_words_by_ref -n : -c cur -p prev
    else
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # Trigger completion only for the model argument after `ollama run`.
    # This check ensures we are at the right position, even with extra whitespace.
    if [[ "$prev" != "run" ]] || [[ "${COMP_WORDS[0]}" != "ollama" ]]; then
        return
    fi

    # Retrieve the list of available models exactly once.
    # Fail gracefully if `ollama` is not installed or `list` fails.
    local list_output
    list_output=$(ollama list 2>/dev/null)
    if [[ -z "$list_output" ]]; then
        return
    fi

    # Collect model names matching the current typed prefix.
    local models=()
    # Use a here-string to read the captured output line by line safely.
    while IFS= read -r line; do
        # Extract the model name (first column) and discard the rest.
        local model_name
        read -r model_name _ <<< "$line"

        # Skip the header row of `ollama list`.
        if [[ "$model_name" == "NAME" ]]; then
            continue
        fi

        # Add model to our list if it starts with the user's prefix.
        if [[ "$model_name" == "$cur"* ]]; then
            models+=("$model_name")
        fi
    done <<< "$list_output"

    # If no models matched the prefix, stop.
    if [[ ${#models[@]} -eq 0 ]]; then
        return
    fi

    # Sort the matching models alphabetically.
    local sorted_models
    readarray -t sorted_models < <(printf "%s\n" "${models[@]}" | sort)

    # Populate COMPREPLY with the sorted, filtered list of models.
    COMPREPLY=( "${sorted_models[@]}" )
}

# Register the completion function for the `ollama` command.
complete -F _ollama_completion ollama

### Installation & Activation ###
#
# 1. Save this script as a file, e.g., /etc/bash_completion.d/ollama
#
# 2. Add the following line to your ~/.bashrc file:
#    source /etc/bash_completion.d/ollama
#
# 3. To activate immediately in your current shell, run:
#    source /etc/bash_completion.d/ollama
#
#    (Adjust the path if you saved it elsewhere.)
