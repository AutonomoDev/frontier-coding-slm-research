# Bash completion for the 'ollama' command

_ollama_completions() {
    # Save the current positional arguments and redirect the completions to the
    # COMPREPLY array. The '-o default' option will make sure the default completion
    # routine (filename expansion) is used if no explicit completion method is found.
    local cur prev opts
    _get_comp_words_by_ref -n : cur prev
    COMPREPLY=()

    # Check that 'ollama' command exists
    type ollama > /dev/null 2>&1 || return 0

    # Check if the current word is 'run'
    if [ "$prev" != "run" ]; then
        return 0
    fi

    # Retrieve model names with 'ollama list', skipping the header line
    local models
    models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}')

    # If ollama list failed or returned no output, return early
    if [ -z "$models" ]; then
        return 0
    fi

    # Generate completions by matching the current word with model names
    local IFS=$'\n'
    COMPREPLY=( $(compgen -W "${models}" -- ${cur}) )

    # Properly handle colon-separated completions display
    __ltrim_colon_completions "$cur"
}

# Register the completion function for 'ollama' command
complete -F _ollama_completions ollama
