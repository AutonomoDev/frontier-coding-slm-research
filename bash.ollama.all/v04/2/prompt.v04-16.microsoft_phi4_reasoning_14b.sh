#!/bin/bash
# This is an ollama completion function.
# It completes subcommands and flags.
#
# The overall logic:
#   • At top-level (i.e. if no subcommand yet), complete a list of subcommands.
#   • If a subcommand has been provided, then:
#       – For commands that accept flag completions (when cur starts with "-"),
#         complete only the allowed flags.
#       – Otherwise, complete model names from ollama list (or for "stop", use "ollama ps").
#
# For group 1 commands (show, stop, push, cp, rm) we use a strict algorithm:
#   A. If compopt is set with '-o nospace', then add a space after the completion.
#      (For simplicity this detail is not implemented here.)
#   B. If the command line begins with "ollama" but doesn't have a second token,
#      then complete all available model names from ollama list.
#   C. Otherwise, if the current token is empty, complete all model names that start
#      with cur.
#   D. Otherwise, if no models match, return an empty completion.
#
# For commands that accept flags (run, show, create), when cur starts with a "-",
# only flag options are completed.

_ollama_completion() {
    local cur prev sub
    cur="${COMP_WORDS[COMP_CWORD]}"
    if [ $COMP_CWORD -gt 0 ]; then
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    if [ $COMP_CWORD -eq 1 ]; then
        COMPREPLY=( $(compgen -W "show run stop push cp rm create pull serve start signin signout list ls ps help" -- "$cur") )
        return 0
    fi

    sub="${COMP_WORDS[1]}"

    case "$sub" in
        show)
            if [[ $cur == -* ]]; then
                COMPREPLY=( $(compgen -W "--license --modefile --parameters --system --template --verbose" -- "$cur") )
            else
                local models
                models=$(ollama list 2>/dev/null || true)
                if [ -n "$cur" ]; then
                    models=$(echo "$models" | grep "^${cur}" || true)
                fi
                COMPREPLY=( $(compgen -W "$models" -- "") )
            fi
            ;;
        run)
            if [[ $cur == -* ]]; then
                COMPREPLY=( $(compgen -W "--format --hidethinking --insecure --keepalive --nowordwrap --think --verbose" -- "$cur") )
            else
                local models
                models=$(ollama list 2>/dev/null || true)
                if [ -n "$cur" ]; then
                    models=$(echo "$models" | grep "^${cur}" || true)
                fi
                COMPREPLY=( $(compgen -W "$models" -- "") )
            fi
            ;;
        stop)
            if [[ $cur == -* ]]; then
                COMPREPLY=()
            else
                local models
                models=$(ollama ps 2>/dev/null || true)
                if [ -n "$cur" ]; then
                    models=$(echo "$models" | grep "^${cur}" || true)
                fi
                COMPREPLY=( $(compgen -W "$models" -- "") )
            fi
            ;;
        push|cp|rm)
            if [[ $cur == -* ]]; then
                COMPREPLY=()
            else
                local models
                models=$(ollama list 2>/dev/null || true)
                if [ -n "$cur" ]; then
                    models=$(echo "$models" | grep "^${cur}" || true)
                fi
                COMPREPLY=( $(compgen -W "$models" -- "") )
            fi
            ;;
        create)
            if [[ $cur == -* ]]; then
                COMPREPLY=( $(compgen -W "--file -f --quantize -q" -- "$cur") )
            else
                local models
                models=$(ollama list 2>/dev/null || true)
                if [ -n "$cur" ]; then
                    models=$(echo "$models" | grep "^${cur}" || true)
                fi
                COMPREPLY=( $(compgen -W "$models" -- "") )
            fi
            ;;
        pull|serve|start|signin|signout|list|ls|ps|help)
            COMPREPLY=()
            ;;
        *)
            COMPREPLY=()
            ;;
    esac

    return 0
}

complete -F _ollama_completion ollama
