# Bash completion script for `ollama run` command
# This script provides autocompletion for model names from `ollama list`
# It only activates when completing the word after `ollama run`

# Function to get current word and previous word
# Falls back to manual parsing if _get_comp_words_by_ref is not available
_get_cur_prev() {
    if declare -f _get_comp_words_by_ref >/dev/null 2>&1; then
        _get_comp_words_by_ref -n : cur prev
    else
        # Manual fallback
        cur="${COMP_WORDS[COMP_CWORD]}"
        if [ $COMP_CWORD -gt 0 ]; then
            prev="${COMP_WORDS[COMP_CWORD-1]}"
        else
            prev=""
        fi
    fi
}

# Main completion function for ollama
_ollama_completion() {
    local cur prev words cword
    _get_cur_prev

    # Only activate for `ollama run` subcommand
    # Check that we're completing the word after `run`
    if [[ "${COMP_WORDS[1]}" == "run" ]]; then
        # Get the current word being completed
        local current_word="${cur}"

        # Get list of models from ollama list, skip header, extract first column
        local models
        models=$(ollama list 2>/dev/null | tail -n +2 | cut -d' ' -f1 | sort | uniq)

        # Filter models based on current input
        local filtered_models
        if [[ -n "$current_word" ]]; then
            filtered_models=$(echo "$models" | grep "^$current_word")
        else
            filtered_models="$models"
        fi

        # Set completions if we have any
        if [[ -n "$filtered_models" ]]; then
            COMPREPLY=($(echo "$filtered_models" | xargs))
        else
            # No matching models, leave COMPREPLY empty
            COMPREPLY=()
        fi
    fi
}

# Register the completion function for ollama
complete -F _ollama_completion ollama

