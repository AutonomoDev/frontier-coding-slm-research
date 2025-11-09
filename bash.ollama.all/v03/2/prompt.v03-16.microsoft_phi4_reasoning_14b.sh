#!/bin/bash
# ollama command completion
#
# This file provides bash completion for the "ollama" command.
# It supports subcommands and, for some commands (those in group 2),
# flag completions after the model name argument.
#
# Usage:
#   source /path/to/this/file or install via your favorite method.
#
# When invoking "ollama", you get a list of available subcommands.
# For certain commands (group 1), if no arguments are given,
# the second word is completed using the output of "ollama list"
# (or "ollama ps" for the stop command). For commands in group 2,
# after the model name argument, any following word will be
# completed against a set of flag options.
#
# Note: Adjust or add flag options as needed.

_ollama_completion() {
    # Get current and previous words from completion array
    local cur prev subcmd
    cur="${COMP_WORDS[COMP_CWORD]}"
    subcmd="${COMP_WORDS[1]}"

    # If only the command is typed, complete with all available subcommands.
    if [ $COMP_CWORD -eq 1 ]; then
        COMPREPLY=( $(compgen -W "create cp rm push stop run show pull serve start signin signout list ls ps help" -- "$cur") )
        return 0
    fi

    case "$subcmd" in
        create)
            # Group 2 command: after the model name, complete flags.
            if [ $COMP_CWORD -eq 2 ]; then
                # No automatic model completion for "create"
                COMPREPLY=()
            elif [ $COMP_CWORD -ge 3 ]; then
                _create_flags=(--file)
                COMPREPLY=( $(compgen -W "${_create_flags[*]}" -- "$cur") )
            fi
            ;;
        pull)
            # "pull" appears in both group 2 (flags after model) and group 3.
            # Here we assume that if a second word is provided, the user might be
            # passing an argument (with no automatic completion), but flags come later.
            if [ $COMP_CWORD -eq 2 ]; then
                COMPREPLY=()
            elif [ $COMP_CWORD -ge 3 ]; then
                _pull_flags=()  # Add pull-specific flag options here if needed.
                COMPREPLY=( $(compgen -W "${_pull_flags[*]}" -- "$cur") )
            fi
            ;;
        run|show)
            # Group 1 & group 2: first argument is a model name (using "ollama list").
            if [ $COMP_CWORD -eq 2 ]; then
                local models
                models=$(ollama list 2>/dev/null)
                COMPREPLY=( $(compgen -W "$models" -- "$cur") )
            elif [ $COMP_CWORD -ge 3 ]; then
                # Complete flags for these commands (if any are defined).
                case "$subcmd" in
                    run)
                        _run_flags=()  # Add "run" flag options here if desired.
                        COMPREPLY=( $(compgen -W "${_run_flags[*]}" -- "$cur") )
                        ;;
                    show)
                        _show_flags=()  # Add "show" flag options here if desired.
                        COMPREPLY=( $(compgen -W "${_show_flags[*]}" -- "$cur") )
                        ;;
                esac
            fi
            ;;
        stop)
            # For "stop", the second argument is a model name, but using "ollama ps"
            if [ $COMP_CWORD -eq 2 ]; then
                local models
                models=$(ollama ps 2>/dev/null)
                COMPREPLY=( $(compgen -W "$models" -- "$cur") )
            fi
            ;;
        push|cp|rm)
            # Group 1 commands: complete the model name using "ollama list"
            if [ $COMP_CWORD -eq 2 ]; then
                local models
                models=$(ollama list 2>/dev/null)
                COMPREPLY=( $(compgen -W "$models" -- "$cur") )
            fi
            ;;
        serve|start|signin|signout|list|ls|ps|help)
            # Group 3: no additional arguments to complete.
            COMPREPLY=()
            ;;
    esac

    return 0
}

# Register the completion function for the "ollama" command.
complete -F _ollama_completion ollama

# End of ollama bash completion script.
