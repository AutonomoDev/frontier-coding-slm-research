```bash
_ollama_completions() {
    local cur prev words cword models
    _get_comp_words_by_ref -n : cur prev words cword
    
    if [[ ${#words[@]} -eq 2 && "$prev" == "ollama" ]]; then
        COMPREPLY=($(compgen -W 'show run stop push cp rm create pull serve start signin signout list ls ps help' -- "$cur"))
        return
    fi
    
    case "${words[1]}" in
        show|run|push|cp|rm)
            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            ;;
        stop)
            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
            models=$(ollama ps 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            ;;
        create)
            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            
            if [[ "$cur" == -* ]]; then
                flags="--file --quantize"
                COMPREPLY=($(compgen -W '$flags' -- "$cur"))
            else 
                COMPREPLY=($(compgen -W "$models" -- "$cur"))
            fi
            ;;
        pull)
            flags="--insecure"
            COMPREPLY=($(compgen -W '$flags' -- "$cur"))
            ;;
        run|show)
            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            
            if [[ "$cur" == -* ]]; then
                flags="--format --hidethinking --insecure --keepalive --nowordwrap --think --verbose"
                COMPREPLY=($(compgen -W '$flags' -- "$cur"))
            else 
                COMPREPLY=($(compgen -W "$models" -- "$cur"))
            fi
            ;;
        start|serve|signin|signout|list|ls|ps)
            return
            ;;
        help)
            if [[ "${#words[@]}" != 2 ]]; then
                COMPREPLY=($(compgen -W 'show run stop push cp rm create pull serve start signin signout list ls ps help' -- "$cur"))
            fi
            ;;
    esac
    
    [[ ${#COMPREPLY[@]} -eq 1 && ${COMPREPLY[0]} == "--" ]] && compopt -o nospace || compopt +o default
}
complete -F _ollama_completions ollama
```
This script will set up tab completion for your `ollama` command. The function `_ollama_completions` is the function that does all of the work, and it's registered with `complete -F _ollama_completions ollama`. 

