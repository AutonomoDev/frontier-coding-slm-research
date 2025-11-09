#!/usr/bin/bash
#
# ollama_completion.sh – Bash completion for the "ollama" CLI tool.
#
# This script implements completion for two groups of commands:
#   • Group 1 (no flags): show, run, stop, push, cp, rm – these complete
#     available models. For "stop", it uses "ollama ps" to list targets;
#     for the others, it uses "ollama list".
#
#   • Group 2 (with flags): create, pull, run and show – when a flag is being
#     typed, they complete a fixed set of options:
#       • create: --file -f --quantize -q 
#       • pull: --insecure 
#       • run: --format --hidethinking --insecure --keepalive --nowordwrap --think --verbose 
#       • show: --license --modefile --parameters --system --template --verbose
#
# Other commands (serve, start, signin, list, ls, ps, help) complete themselves.
#

__ollama_complete() {
    local cur prev opts base_opts subcommand flag models

    # Initialize an empty reply array
    COMPREPLY=()

    # Get the current word to be completed.
    cur="${COMP_WORDS[COMP_CWORD]}"

    #
    # If only the command name is provided (i.e. "ollama"), complete with all available subcommands.
    #
    if [ "${COMP_WORDS[1]}" = "ollama" ] && [ ${#COMP_WORDS[@]} -eq 2 ]; then
        COMPREPLY=( $(compgen -W "show run stop push cp rm create pull serve start signin list ls ps help" -- "$cur") )
        __ltrim_colon_completions "${COMPREPLY[@]}"
        return 0
    fi

    # If we have fewer than 3 words, complete the subcommands.
    if [ ${#COMP_WORDS[@]} -lt 3 ]; then
        COMPREPLY=( $(compgen -W "show run stop push cp rm create pull serve start signin list ls ps help" -- "$cur") )
        __ltrim_colon_completions "${COMPREPLY[@]}"
        return 0
    fi

    # The subcommand is the second word.
    subcommand="${COMP_WORDS[2]}"

    #
    # If only two words have been provided (i.e. command and subcommand), complete:
    # • For Group1 commands: list available models.
    # • For Group2 commands (create, pull, run, show): also list available models.
    # • For commands that don't expect additional arguments, complete the subcommand itself.
    #
    if [ ${#COMP_WORDS[@]} -eq 3 ]; then
        case "$subcommand" in
            show|run|push|cp|rm)
                if ! command -v ollama &>/dev/null; then 
                    return 0
                fi
                # For "stop", use "ollama ps"; otherwise, use "ollama list"
                if [ "$subcommand" = "stop" ]; then
                    models=$(ollama ps 2>/dev/null | tail -n +2 | awk '{print $1}')
                else
                    models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
                fi
                COMPREPLY=( $(compgen -W "$models" -- "$cur") )
                __ltrim_colon_completions "${COMPREPLY[@]}"
                return 0
                ;;
            create|pull|run|show)
                if ! command -v ollama &>/dev/null; then 
                    return 0
                fi
                models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
                COMPREPLY=( $(compgen -W "$models" -- "$cur") )
                __ltrim_colon_completions "${COMPREPLY[@]}"
                return 0
                ;;
            serve|start|signin|list|ls|ps|help)
                # These commands do not expect additional arguments.
                COMPREPLY=( $(compgen -W "$subcommand" -- "$cur") )
                __ltrim_colon_completions "${COMPREPLY[@]}"
                return 0
                ;;
            *)
                COMPREPLY=()
                ;;
        esac

    else
        #
        # More than three words: we are likely completing a flag for one of the Group2 commands.
        # The flag being completed is the fourth word (index 3).
        #
        flag="${COMP_WORDS[3]}"
        case "$subcommand" in
            create)
                opts="--file -f --quantize -q"
                ;;
            pull)
                opts="--insecure"
                ;;
            run)
                opts="--format --hidethinking --insecure --keepalive --nowordwrap --think --verbose"
                ;;
            show)
                opts="--license --modefile --parameters --system --template --verbose"
                ;;
            *)
                COMPREPLY=()
                return 0
                ;;
        esac
        COMPREPLY=( $(compgen -W "$opts" -- "$flag") )
        __ltrim_colon_completions "${COMPREPLY[@]}"
    fi
}

# Register the completion function for "ollama"
complete -F __ollama_complete ollama

# The __ltrim_colon_completions function is assumed to be provided by your environment.
# If not, you can define a basic version as follows:
if ! type __ltrim_colon_completions &>/dev/null; then
__ltrim_colon_completions() {
    local IFS=$'\n'
    # Remove colons from the beginning of each completion entry.
    for i in "$@"; do
        COMPREPLY=( "${COMPREPLY[@]}" "$(echo $i | sed -e 's/^:[^:]*://')" )
    done
}
fi

# End of ollama_completion.sh
