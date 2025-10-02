# Bash completion for ollama command

# Check if ollama command exists before calling it
if ! type ollama > /dev/null 2>&1; then
    return
fi

# Function to handle completions for ollama command
_ollama_completions() {
    local cur prev words cword split
    _init_completion -n : || return

    # Check if the command is "ollama" and previous word is "run"
    if [[ $prev != "run" ]]; then
        return
    fi

    # Retrieve model names using `ollama list` and parse with awk to extract first column, skipping header
    local models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}') || return
    
    # Filter matches using pattern matching against "$cur"
    COMPREPLY=($(compgen -W "${models}" -- "${cur}"))

    # Call __ltrim_colon_completions to properly handle colon-separated completions display
    __ltrim_colon_completions "$cur"
} &&
# Register completion for ollama command
complete -F _ollama_completions ollama
