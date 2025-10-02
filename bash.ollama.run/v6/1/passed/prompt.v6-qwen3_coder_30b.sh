# Bash completion script for `ollama run` command
# This script provides autocompletion for model names from `ollama list`

# Function to get current word and previous word
# Falls back to manual parsing if _get_comp_words_by_ref is not available
_get_words_by_ref() {
    if declare -f _get_comp_words_by_ref >/dev/null 2>&1; then
        _get_comp_words_by_ref -n : cur prev
    else
        # Manual fallback for cur and prev
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
    _get_words_by_ref

    # Only trigger completion for 'ollama run' command
    # Check that the first word is 'ollama' and previous word is 'run'
    if [[ "${COMP_WORDS[0]}" == "ollama" && "${prev}" == "run" ]]; then
        # Get list of models from ollama list
        # Use a temporary file to avoid issues with command substitution in some shells
        local tmpfile=$(mktemp)
        ollama list > "$tmpfile" 2>/dev/null

        # Check if ollama list command succeeded
        if [ $? -eq 0 ]; then
            # Extract model names from first column, skip header line
            # Use cut to parse the first column (NAME) and skip the header
            local models=$(cut -d' ' -f1 "$tmpfile" | grep -v "^NAME$")
            # Remove temporary file
            rm -f "$tmpfile"

            # Process models for completion
            local IFS=$'\n' # Set internal field separator to newline
            local completions=()
            for model in $models; do
                # Only add to completions if model name matches current input
                if [[ "$model" == "$cur"* ]]; then
                    completions+=("$model")
                fi
            done

            # Remove duplicates by converting to associative array and back
            local unique_completions=()
            declare -A seen
            for item in "${completions[@]}"; do
                if [[ -z "${seen[$item]}" ]]; then
                    seen[$item]=1
                    unique_completions+=("$item")
                fi
            done

            # Set COMPREPLY to the filtered and unique completions
            COMPREPLY=("${unique_completions[@]}")
        else
            # If ollama list fails, clean up and return empty completion
            rm -f "$tmpfile"
            COMPREPLY=()
        fi
    else
        # Not in the right context, no completion
        COMPREPLY=()
    fi
}

# Register the completion function for the 'ollama' command
complete -F _ollama_completion ollama

