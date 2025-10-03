# Bash completion script for the `ollama run` command.
#
# Problem: Model names like "codellama:13b" have colons, which are treated as word breaks by default in Bash. This causes issues when trying to complete model names (e.g., after typing `ollama run codellama:`, the previous token is incorrectly parsed as "run", leading to incorrect completion logic).
#
# Solution:
# 1. Temporarily remove ':' from COMP_WORDBREAKS.
# 2. Use `_get_comp_words_by_ref` with `-n :` to re-parse the command line without considering ':' as a word break.
# 3. Immediately restore the original COMP_WORDBREAKS to avoid side effects.

_ollama_completions() {
    local cur prev words cword
    # Save the original COMP_WORDBREAKS.
    local _old_wb="${COMP_WORDBREAKS}"
    
    # Modify COMP_WORDBREAKS to remove colon, allowing us to handle it as part of a token.
    COMP_WORDBREAKS=${_old_wb//:/}
    
    # Re-parse the command line using our new word break rules.
    _get_comp_words_by_ref -n : cur prev words cword
    
    # Restore original COMP_WORDBREAKS immediately to prevent side effects in other completions.
    COMP_WORDBREAKS="${_old_wb}"
    
    # Check if the previous token is 'run' (the subcommand).
    case "$prev" in
        run)
            # Fetch list of models from `ollama list`, ignoring headers.
            local models=$(ollama list | awk 'NR>1 {print $1}')
            # Generate completions for model names based on the current token.
            COMPREPLY=( $(compgen -W "$models" -- "$cur") )
            ;;
    esac
}

# Register the completion function for `ollama`.
complete -F _ollama_completions ollama
