# Bash completion for `ollama run` command
# Handles model names with colons (e.g., codellama:13b) correctly
# by temporarily modifying COMP_WORDBREAKS to prevent colon splitting

_ollama_completions() {
    local cur prev words cword
    # Use _get_comp_words_by_ref if available (bash-completion v2+)
    if declare -f _get_comp_words_by_ref >/dev/null 2>&1; then
        # Save original word break characters to restore later
        local _old_wb=${COMP_WORDBREAKS}
        # Temporarily remove colon from word breaks to avoid splitting on ':'
        COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}
        # Re-parse words without treating ':' as a word separator
        _get_comp_words_by_ref -n : cur prev
        # Restore original word break characters immediately
        COMP_WORDBREAKS=${_old_wb}
    else
        # Fallback for older bash-completion versions
        # This is less robust but ensures compatibility
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # Only complete after 'ollama run'
    if [[ "$prev" == "run" ]]; then
        # Extract model names from ollama list output (skip header line)
        local models=$(ollama list | awk 'NR>1 {print $1}')
        # Generate completions using the model list
        COMPREPLY=( $(compgen -W "$models" -- "$cur") )
    fi
}

# Register completion for the ollama command
complete -F _ollama_completions ollama
