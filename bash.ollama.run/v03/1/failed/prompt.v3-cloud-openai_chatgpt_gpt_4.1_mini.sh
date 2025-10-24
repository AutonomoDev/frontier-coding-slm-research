# Bash completion for `ollama run <model>`
_ollama_run_completion() {
    local cur prev
    # Try to use _get_comp_words_by_ref; fallback if missing
    if declare -F _get_comp_words_by_ref >/dev/null 2>&1; then
        _get_comp_words_by_ref -n : cur prev
    else
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # Activate only if prev word is 'run' and command is 'ollama'
    [[ "${COMP_WORDS[0]}" != "ollama" || "$prev" != "run" ]] && return 0

    # Capture output of `ollama list` once
    local output models=()
    if ! output=$(ollama list 2>/dev/null) || [[ -z "$output" ]]; then
        return 0
    fi

    # Extract model names from output (assume one per line)
    # Add only models starting with prefix $cur
    while IFS= read -r line; do
        # Trim whitespace
        line="${line%%*( )}"
        line="${line##*( )}"
        if [[ $line == "$cur"* ]]; then
            models+=("$line")
        fi
    done <<<"$output"

    # If no matches, return no completions
    [[ ${#models[@]} -eq 0 ]] && return 0

    # Sort models alphabetically
    IFS=$'\n' sorted=($(printf '%s\n' "${models[@]}" | sort))
    unset IFS

    # Generate completions
    COMPREPLY=($(compgen -W "${sorted[*]}" -- "$cur"))
}

# Attach completion function to `ollama`
complete -F _ollama_run_completion ollama

# Installation:
# Save this script as ~/.ollama_completion.sh
# Add to your ~/.bashrc:
#   source ~/.ollama_completion.sh
# Then reload with: source ~/.bashrc

