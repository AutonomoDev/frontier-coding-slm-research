```bash
_ollama_completions() {
    [[ "${COMP_WORDS[0]}" != "ollama" ]] && { COMPREPLY=(); return; }
    local cur prev
    _get_comp_words_by_ref -n : cur

    # Handle ollama commands
    case "${COMP_WORDS[1]}" in
        serve)  ;;
        create|show|run|stop|pull|push|signin|signout|list|ps|cp|rm|help)
            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
            local models
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
            __ltrim_colon_completions "$cur"
        ;;
        *)  
            return 1
        ;;
    esac
}
complete -F _ollama_completions ollama
```
Please note that the script assumes:
- The `list` command is available and it returns a list of models.
- You are using a recent version of Bash which supports arrays. 

