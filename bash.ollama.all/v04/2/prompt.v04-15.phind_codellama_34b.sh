Here is the bash completion function for `ollama`:

```bash
_ollama_completions() {
    local cur prev words cword
    _get_comp_words_by_ref -n : cur prev words cword

    local subcmd="${words[1]}"
    case "$subcmd" in
        show|run|stop|push|cp|rm)
            # Step A
            _get_comp_words_by_ref -n : cur prev
            
            # Step B
            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
            local models
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            
            # Step C
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            
            # Step D
            COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
            __ltrim_colon_completions "$cur"
            ;;
        create)
            # Step A
            _get_comp_words_by_ref -n : cur prev
            
            # Step B
            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
            local models
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            
            # Step C
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            
            # Step D
            COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
            __ltrim_colon_completions "$cur"
            
            # Add flags for create
            _command_offset 1
            ;;
        pull)
            # Step A
            _get_comp_words_by_ref -n : cur prev
            
            # Add flags for pull
            _command_offset 1
            ;;
        stop)
            # Step A
            _get_comp_words_by_ref -n : cur prev
            
            # Step B
            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
            local models
            models=$(ollama ps 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            
            # Step C
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            
            # Step D
            COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
            __ltrim_colon_completions "$cur"
            ;;
        serve|start|signin|signout|list|ls|ps|help)
            # Step A
            _get_comp_words_by_ref -n : cur prev
            
            COMPREPLY=()
            ;;
    esac
}
complete -F _ollama_completions ollama
```

