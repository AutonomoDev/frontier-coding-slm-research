Here's a single Bash function that provides tab completions for the `ollama` command line tool:

```bash
_ollama_completions() {
    local cur prev words cword
    _init_completion -n : || return

    case $prev in
        ollama) COMPREPLY=($(compgen -W "create show run stop push cp rm \
            create pull run stop push cp rm \
            serve start pull signin signout list ls ps help" -- "$cur")) ;;
        run|stop|push|cp|rm|show)
            _get_comp_words_by_ref -n : cur prev
            local models
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            __ltrim_colon_completions "$cur"
            COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort)) ;;
        create|pull)
            local flags
            if [[ $prev == "create" ]]; then
                flags="--file -f --quantize -q"
            elif [[ $prev == "pull" ]]; then
                flags="--insecure"
            fi
            COMPREPLY=($(compgen -W "$flags" -- "$cur")) ;;
        *) COMPREPLY=() ;;
    esac
}
complete -F _ollama_completions ollama
```

This function uses a `case` statement to handle different completion types based on the subcommand. For model name completion, it follows the exact steps provided in the prompt. It also handles special flag completions for `create`, `pull`, and `run` commands.

