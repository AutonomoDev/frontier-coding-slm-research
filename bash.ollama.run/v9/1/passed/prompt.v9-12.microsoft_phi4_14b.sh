# 1. Simple Static Completion: Provide a static word list for the `example_cmd` command.
complete -W "option1 option2 option3" example_cmd

# 2. Dynamic Completion with a Function: Define `_example_cmd_completions` to dynamically filter completions.
_example_cmd_completions() {
    # Get the current word being typed using COMP_WORDS and COMP_CWORD.
    local cur="${COMP_WORDS[COMP_CWORD]}"
    # Generate potential matches for `cur` from a static list of options.
    COMPREPLY=( $(compgen -W "option1 option2 option3" -- "$cur") )
}
complete -F _example_cmd_completions example_cmd

# 3. Context-Aware Completion: Define `_app_completions` to provide context-aware suggestions for `app`.
_app_completions() {
    local prev="${COMP_WORDS[COMP_CWORD-1]}"
    case "${prev}" in
        app)
            # Level 1 completion when previous word is 'app'.
            COMPREPLY=( $(compgen -W "run list pull" -- "${COMP_WORDS[COMP_CWORD]}") )
            ;;
        run)
            # Level 2 completion for the subcommand `run`.
            COMPREPLY=( $(compgen -W "model:small model:large" -- "${COMP_WORDS[COMP_CWORD]}") )
            ;;
    esac
}
complete -F _app_completions app

# 4. Advanced Completion for Non-Standard Word Breaks: Handle colon-containing words in `ollama run`.
_ollama_completions() {
    # Save original word break characters and remove ':' to avoid incorrect parsing.
    local _old_wb=${COMP_WORDBREAKS}
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}

    # Re-parse the command line with modified word breaks.
    _get_comp_words_by_ref -n : cur prev
    COMP_WORDBREAKS=${_old_wb}

    # Restore original `prev` and `cur` after modification.
    if [[ "$prev" == "run" ]]; then
        # Dynamically get model names from `ollama list`.
        local models=$(ollama list | awk 'NR>1 {print $1}')
        COMPREPLY=( $(compgen -W "$models" -- "$cur") )
    fi
}
complete -F _ollama_completions ollama

# 5. Installation Instructions as Code Comments: Source completion scripts from `~/.bash_completion.d/`.
# Add the following lines to your ~/.bashrc file:
#
# if [[ -d ~/.bash_completion.d ]]; then
#     for compfile in ~/.bash_completion.d/*; do
#         # Check if file is readable and source it.
#         [ -r "$compfile" ] && . "$compfile"
#     done
# fi
```

