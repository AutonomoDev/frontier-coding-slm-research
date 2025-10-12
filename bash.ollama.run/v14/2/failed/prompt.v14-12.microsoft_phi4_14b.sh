_ollama_completions() {
    # Check if the command is "ollama run"
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

    local cur prev words cword

    # Use _get_comp_words_by_ref to handle colons properly
    _get_comp_words_by_ref -n : cur prev words cword

    # Check if 'ollama' command is available
    if ! command -v ollama &>/dev/null; then
        COMPREPLY=()
        return
    fi

    # Run `ollama list` and capture the output
    local models_output
    models_output=$(ollama list 2>/dev/null)

    # Check if the output is empty or command failed
    [[ -z "$models_output" ]] && { COMPREPLY=(); return; }

    # Extract model names, skip header, and store in an array
    mapfile -t model_names < <(echo "$models_output" | tail -n +2 | awk '{print $1}')

    # Filter models matching the current word being completed
    local suggestions=("${model_names[@]/*$cur*/}")

    # Sort the suggestions alphabetically
    IFS=$'\n' suggestions=( "$(printf "%s\n" "${suggestions[@]}" | sort)" )

    # Generate completion suggestions using compgen
    COMPREPLY=($(compgen -W "${suggestions[*]}" -- "$cur"))

    # Ensure colon handling is correct
    __ltrim_colon_completions "$cur"
}

# Register the completion function for `ollama`
complete -F _ollama_completions ollama

# [[HUMAN COMMENTED-OUT]]
# This script defines a Bash completion handler `_ollama_completions` that activates only for the `ollama run` command. It ensures proper handling of model names containing colons, parses `ollama list` output correctly by skipping headers and extracting only the first column, checks for the existence of the `ollama` command, and manages edge cases like empty outputs or missing commands gracefully. The script ends with a necessary call to `__ltrim_colon_completions` to address colon handling in Bash completions, ensuring that models containing colons are suggested correctly.
