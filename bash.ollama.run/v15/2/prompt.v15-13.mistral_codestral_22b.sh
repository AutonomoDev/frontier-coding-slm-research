 ```bash
# Bash completion for 'ollama run' command.
_ollama_run_completions() {
    local cur prev words cword
    _init_completion || return

    # Save the original COMP_WORDBREAKS and remove ':' from it to handle model names with colons.
    local wordbreaks="$COMP_WORDBREAKS"
    COMP_WORDBREAKS=${wordbreaks//:}
    _get_comp_words_by_ref -n : cur prev words cword

    # Restore the original COMP_WORDBREAKS.
    COMP_WORDBREAKS="$wordbreaks"

    if [[ "${COMP_WORDS[1]}" == "run" ]]; then
        local models="$(ollama list | awk 'NR>1 {print $1}')" # Extract model names from 'ollama list' output.
        COMPREPLY=($(compgen -W "$models" -- "$cur")) # Generate the final list of suggestions for completion.
    fi
}
complete -F _ollama_run_completions ollama # Register the function for 'ollama'.
```

