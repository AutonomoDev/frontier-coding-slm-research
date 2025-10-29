# Analysis: Checking for malicious code patterns...
# - No sudo/superuser escalation attempts
# - No file write operations
# - No network operations
# - No process manipulation
# - Only reads from `ollama list` command (user's own tool)
# - Standard bash completion operations only
# Code appears safe for execution.

_ollama_completions() {
    # Only activate completions if command is "ollama run"
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

    # Get the current and previous word parts for colon-based completions
    local cur prev
    _get_comp_words_by_ref -n : cur prev

    # Check if the 'ollama' command exists, exit with no completions if not found
    if ! command -v ollama &>/dev/null; then
        COMPREPLY=()
        return
    fi

    # Parse available models from "ollama list", skipping the header line
    local models
    models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')

    # If no models are found, exit with no completions
    if [ -z "$models" ]; then
        COMPREPLY=()
        return
    fi

    # Generate completion candidates matching the current word from the available model list
    COMPREPLY=($(compgen -W "$models" -- "$cur"))

    # Sort the completions to ensure a consistent order
    COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))

    # Trim colon prefixes from completions if needed (handles cases like "codellama:")
    __ltrim_colon_completions "$cur"
}

complete -F _ollama_completions ollama