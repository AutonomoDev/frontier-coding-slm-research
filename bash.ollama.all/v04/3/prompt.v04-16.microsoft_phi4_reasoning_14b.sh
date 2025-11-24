#!/usr/bin/env bash

_ollama_completions() {
    local cur prev words cword
    _get_comp_words_by_ref -n : cur prev words cword
    
    local subcommand="${words[1]}"
    
    # Top-level completion: if no subcommand yet, complete with all subcommands
    if [[ "$cword" -eq 1 ]]; then
        COMPREPLY=($(compgen -W "show run stop push cp rm create pull serve start signin signout list ls ps help" -- "$cur"))
        return 0
    fi
    
    case "$subcommand" in
        show)
            if [[ "$cur" == -* ]]; then
                COMPREPLY=($(compgen -W "--license --modefile --parameters --system --template --verbose" -- "$cur"))
            else
                if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
                local models
                models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
                [[ -z "$models" ]] && { COMPREPLY=(); return; }
                COMPREPLY=($(compgen -W "$models" -- "$cur"))
                COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
                __ltrim_colon_completions "$cur"
            fi
            return 0
            ;;
        run)
            if [[ "$cur" == -* ]]; then
                COMPREPLY=($(compgen -W "--format --hidethinking --insecure --keepalive --nowordwrap --think --verbose" -- "$cur"))
            else
                if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
                local models
                models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
                [[ -z "$models" ]] && { COMPREPLY=(); return; }
                COMPREPLY=($(compgen -W "$models" -- "$cur"))
                COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
                __ltrim_colon_completions "$cur"
            fi
            return 0
            ;;
        stop)
            if [[ "$cur" == -* ]]; then
                COMPREPLY=()
            else
                if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
                local models
                models=$(ollama ps 2>/dev/null | tail -n +2 | awk '{print $1}')
                [[ -z "$models" ]] && { COMPREPLY=(); return; }
                COMPREPLY=($(compgen -W "$models" -- "$cur"))
                COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
                __ltrim_colon_completions "$cur"
            fi
            return 0
            ;;
        push|cp|rm)
            if [[ "$cur" == -* ]]; then
                COMPREPLY=()
            else
                if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
                local models
                models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
                [[ -z "$models" ]] && { COMPREPLY=(); return; }
                COMPREPLY=($(compgen -W "$models" -- "$cur"))
                COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
                __ltrim_colon_completions "$cur"
            fi
            return 0
            ;;
        create)
            if [[ "$cur" == -* ]]; then
                COMPREPLY=($(compgen -W "--file -f --quantize -q" -- "$cur"))
            else
                if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
                local models
                models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
                [[ -z "$models" ]] && { COMPREPLY=(); return; }
                COMPREPLY=($(compgen -W "$models" -- "$cur"))
                COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
                __ltrim_colon_completions "$cur"
            fi
            return 0
            ;;
        pull)
            if [[ "$cur" == -* ]]; then
                COMPREPLY=($(compgen -W "--insecure" -- "$cur"))
            else
                COMPREPLY=()
            fi
            return 0
            ;;
        serve|start|signin|signout|list|ls|ps|help)
            COMPREPLY=()
            return 0
            ;;
        *)
            COMPREPLY=()
            return 0
            ;;
    esac
}

complete -F _ollama_completions ollama
