# bash completion for 'ollama run' command

_complete_models() {
    local cur prev words cword split colonprefixes
    _get_comp_words_by_ref -n =: cur prev words cword

    # Use a command substitution to populate the COMPREPLY array with models.
    # This prevents needing to manually handle colon splitting and empty lines.
    COMPREPLY=( $( compgen -W "$(ollama list | awk 'NR>1 && $0 {print $1}')" -- "$cur" ) )
    
    # Remove colons added by the completion engine
    __ltrim_colon_completions "$cur"
}

complete -F _complete_models ollama run
