_ollama_run_completions() {
    local prev cur words cword split
    _get_comp_words_by_ref -n : cur prev words cword split

    # Only run completion for the 'run' subcommand.
    if [[ "$cur" == "run" ]]; then
        COMPREPLY=( )

        # Modify word splitting to handle model names with colons.
        local orig_COMP_WORDBREAKS="${COMP_WORDBREAKS}"
        COMP_WORDBREAKS=${orig_COMP_WORDBREAKS//:/}

        # Get the list of models from 'ollama list'.
        local model_list="$(ollama list)"
        local model_names=("${model_list//$'\n'/ }")

        # Generate suggestions.
        for name in "${model_names[@]}"; do
            COMPREPLY+=( "$name" )
        done

        # Restore the original word splitting.
        COMP_WORDBREAKS="$orig_COMP_WORDBREAKS"
    fi
}
complete -F _ollama_run_completions ollama

