 ```bash
# ollama run command completion script

_ollama_run_completions() {
    local cur prev words cword split
    _get_comp_words_by_ref -n :cur: -n :prev: -n :words: -n :cword: -n :split

    # Save the original COMP_WORDBREAKS
    local orig_comp_wordbreaks=$COMP_WORDBREAKS

    # Temporarily remove ':' from COMP_WORDBREAKS to allow colon-containing words
    COMP_WORDBREAKS="${COMP_WORDBREAKS//:/}"

    if [[ "${words[1]}" == "run" ]]; then
        local models=$(ollama list | tail -n +2 | awk '{print $1}')
        COMPREPLY=($(compgen -W "$models" -- "$cur"))
    else
        # If the command is not 'ollama run', return no completions
        COMPREPLY=()
    fi

    # Restore the original COMP_WORDBREAKS
    COMP_WORDBREAKS=$orig_comp_wordbreaks
}

complete -F _ollama_run_completions ollama
```

