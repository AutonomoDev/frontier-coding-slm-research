# Bash completion script for `ollama run` command
# Handles model names with colons correctly by temporarily modifying COMP_WORDBREAKS

_ollama_completions() {
    local cur prev words cword
    # Use the helper if available (bash-completion v2+)
    if declare -F _get_comp_words_by_ref >/dev/null; then
        local _old_wb=${COMP_WORDBREAKS}
        COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}
        _get_comp_words_by_ref -n : cur prev
        COMP_WORDBREAKS=${_old_wb}
    else
        # Fallback for older versions (not recommended)
        # This will fail with colons in model names
        COMPREPLY=()
        return 1
    fi

    # Check if we are completing the subcommand "run"
    if [[ "$prev" == "run" ]]; then
        local models=$(ollama list | awk 'NR>1 {print $1}')
        # Option 1: Use printf to escape special characters
        COMPREPLY=( $(compgen -W "$models" -- "$cur" | while read -r model; do printf '%q\n' "$model"; done) )
    fi
}

# Register the completion function for the `ollama` command
complete -F _ollama_completions ollama

