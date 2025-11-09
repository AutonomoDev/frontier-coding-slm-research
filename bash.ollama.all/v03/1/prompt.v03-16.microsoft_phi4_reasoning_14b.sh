#!/bin/bash
#
# ollama completion script for bash
#
# This file provides tab-completion support for the "ollama" command-line tool.
# It supports:
#   • Completion of subcommands when none or one word is typed.
#   • For commands that require a model name as a second argument (group1 and group2),
#     completion of available models via "ollama list".
#   • For some commands (like ollama run and ollama pull), flag completions are provided.
#
# Usage: place this file in /etc/bash_completion.d/ or source it from your .bashrc
#

_ollama_completion()
{
    # Get current word, previous words, etc.
    local cur prev words cword
    _get_comp_words_by_ref -n : cur prev words cword

    # If only "ollama" has been typed (or just beginning of the command),
    # then list available subcommands. We merge unique commands from all groups:
    #   Group1: show, run, stop, push, cp
    #   Group2: create, pull  (these expect a model name next)
    #   Group3: serve, start, signin, signout, list  (no additional args)
    if [[ ${#words[@]} -le 1 ]]; then
        local cmds="show run stop push cp create pull serve start signin signout list"
        COMPREPLY=( $(compgen -W "${cmds}" -- "$cur") )
        return 0
    fi

    # Get the first subcommand (COMP_WORDS[1])
    local cmd=${words[1]}

    # Determine which category this command belongs to.
    # We treat "show", "run", "stop", "push", "cp", "create" and "pull"
    # as commands that require a model name after the subcommand.
    case "$cmd" in
        show|run|stop|push|cp|create|pull)
            ;;
        serve|start|signin|signout|list)
            # These are no-argument commands; if they've been provided, we're done.
            return 0
            ;;
        *)
            # Unknown command: do nothing.
            return 0
            ;;
    esac

    # If only the subcommand has been typed (e.g. "ollama pull"), then offer model names.
    if [[ ${#words[@]} -eq 2 ]]; then
        local models
        # Use "ollama list" to get available models. Any errors are suppressed.
        models=$(ollama list 2>/dev/null || echo "")
        COMPREPLY=( $(compgen -W "$models" -- "$cur") )
        return 0
    fi

    # Otherwise, we assume that the user has typed at least:
    #   ollama <command> <model> <something>
    # For commands like "pull", "run" and similar, offer flag completions.
    local flags=""
    case "$cmd" in
        pull)
            flags="--insecure"
            ;;
        run|show)
            # The following are example flags supported by ollama run/show:
            # --format, --hidethinking, --insecure, --keepalive
            flags="--format --hidethinking --insecure --keepalive"
            ;;
        create)
            # Assume no additional flag completion is needed for "create".
            return 0
            ;;
        *)
            # For any other command in this group, do nothing.
            return 0
            ;;
    esac

    COMPREPLY=( $(compgen -W "$flags" -- "$cur") )
    return 0
}

# Standard helper to trim colons if needed (from bash-completion package)
__ltrim_colon_completions()
{
    local i tmp cur=${COMP_WORDS[COMP_CWORD]}
    for ((i=0; i<COMP_CWORD; i++)); do
        if [[ "${COMP_WORDS[i]}" == *:* ]]; then
            tmp=${COMP_WORDS[i]#*:}
            cur=$tmp$'\n'$cur
        fi
    done
    COMPREPLY=( $(compgen -W "$cur" -- ${cur}) )
}

# Tell bash about our completion function.
complete -F _ollama_completion ollama

# End of ollama completion script.
