#!/bin/bash

_ollama_completions()
{
    local cur prev words cword
    _get_comp_words_by_ref -n : cur prev words cword

    local cmd="${words[1]}"

    if [[ -z "$cmd" ]]; then
        COMPREPLY=( $(compgen -W "show run stop push cp rm create pull serve start signin signout list ls ps help" -- "$cur") )
        __ltrim_colon_completions "$cur"
        return 0
    fi

    case "$cmd" in
        show)
            if [[ $cur == -* ]]; then
                COMPREPLY=( $(compgen -W "--license --modefile --parameters --system --template --verbose" -- "$cur") )
                __ltrim_colon_completions "$cur"
            else
                if ! command -v ollama &>/dev/null; then
                    COMPREPLY=()
                    return 0
                fi
                local models
                models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
                [[ -z "$models" ]] && { COMPREPLY=(); return 0; }
                COMPREPLY=( $(compgen -W "$models" -- "$cur") )
                COMPREPLY=( $(printf "%s\n" "${COMPREPLY[@]}" | sort) )
                __ltrim_colon_completions "$cur"
            fi
            ;;
        run)
            if [[ $cur == -* ]]; then
                COMPREPLY=( $(compgen -W "--format --hidethinking --insecure --keepalive --nowordwrap --think --verbose" -- "$cur") )
                __ltrim_colon_completions "$cur"
            else
                if ! command -v ollama &>/dev/null; then
                    COMPREPLY=()
                    return 0
                fi
                local models
                models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
                [[ -z "$models" ]] && { COMPREPLY=(); return 0; }
                COMPREPLY=( $(compgen -W "$models" -- "$cur") )
                COMPREPLY=( $(printf "%s\n" "${COMPREPLY[@]}" | sort) )
                __ltrim_colon_completions "$cur"
            fi
            ;;
        stop)
            if ! command -v ollama &>/dev/null; then
                COMPREPLY=()
                return 0
            fi
            local models
            models=$(ollama ps 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return 0; }
            COMPREPLY=( $(compgen -W "$models" -- "$cur") )
            COMPREPLY=( $(printf "%s\n" "${COMPREPLY[@]}" | sort) )
            __ltrim_colon_completions "$cur"
            ;;
        push)
            if ! command -v ollama &>/dev/null; then
                COMPREPLY=()
                return 0
            fi
            local models
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return 0; }
            COMPREPLY=( $(compgen -W "$models" -- "$cur") )
            COMPREPLY=( $(printf "%s\n" "${COMPREPLY[@]}" | sort) )
            __ltrim_colon_completions "$cur"
            ;;
        cp)
            if ! command -v ollama &>/dev/null; then
                COMPREPLY=()
                return 0
            fi
            local models
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return 0; }
            COMPREPLY=( $(compgen -W "$models" -- "$cur") )
            COMPREPLY=( $(printf "%s\n" "${COMPREPLY[@]}" | sort) )
            __ltrim_colon_completions "$cur"
            ;;
        rm)
            if ! command -v ollama &>/dev/null; then
                COMPREPLY=()
                return 0
            fi
            local models
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return 0; }
            COMPREPLY=( $(compgen -W "$models" -- "$cur") )
            COMPREPLY=( $(printf "%s\n" "${COMPREPLY[@]}" | sort) )
            __ltrim_colon_completions "$cur"
            ;;
        create)
            if [[ $cur == -* ]]; then
                COMPREPLY=( $(compgen -W "--file -f --quantize -q" -- "$cur") )
                __ltrim_colon_completions "$cur"
            else
                if ! command -v ollama &>/dev/null; then
                    COMPREPLY=()
                    return 0
                fi
                local models
                models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
                [[ -z "$models" ]] && { COMPREPLY=(); return 0; }
                COMPREPLY=( $(compgen -W "$models" -- "$cur") )
                COMPREPLY=( $(printf "%s\n" "${COMPREPLY[@]}" | sort) )
                __ltrim_colon_completions "$cur"
            fi
            ;;
        pull)
            if [[ $cur == -* ]]; then
                COMPREPLY=( $(compgen -W "--insecure" -- "$cur") )
                __ltrim_colon_completions "$cur"
            else
                COMPREPLY=()
            fi
            ;;
        serve)
            COMPREPLY=()
            ;;
        start)
            COMPREPLY=()
            ;;
        signin)
            COMPREPLY=()
            ;;
        signout)
            COMPREPLY=()
            ;;
        list)
            COMPREPLY=()
            ;;
        ls)
            COMPREPLY=()
            ;;
        ps)
            COMPREPLY=()
            ;;
        help)
            COMPREPLY=()
            ;;
        *)
            COMPREPLY=()
            ;;
    esac
}

complete -F _ollama_completions ollama
