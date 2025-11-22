```
_ollama_completions() {
    local cur prev words cword subcommand models
    _get_comp_words_by_ref -n : cur prev words cword
    subcommand="${words[1]}"
    case "$subcommand" in
        show|run|stop|push|cp|rm)
            _get_model_completions
            ;;
        create)
            if [[ $cur == -* ]]; then
                COMPREPLY=($(compgen -W "--file -f --quantize -q" -- "$cur"))
            else
                _get_model_completions
            fi
            ;;
        pull)
            if [[ $cur != -* ]]; then
                _get_model_completions
            fi
            ;;
    esac
}
complete -F _ollama_completions ollama
```

