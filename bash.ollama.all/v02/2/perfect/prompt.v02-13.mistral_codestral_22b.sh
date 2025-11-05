# [[HUMAN COMMENTED-OUT]]
# Based on your requirements, here's a Bash completion script for the `ollama` command line tool:

# Define the main completion function
_ollama_completions() {
    local cur prev subcommand commands models

    # List of commands that require model name completion
    commands_model="show run stop push cp rm"

    # Get the current and previous words
    _get_comp_words_by_ref -n : cur prev

    # If the previous word is 'ollama', provide subcommand completion
    if [[ ${prev} == "ollama" ]]; then
        COMPREPLY=($(compgen -W "${commands_model} create serve pull signin signout list ps help" -- "$cur"))
        return 0
    fi

    # Extract the subcommand
    subcommand=${COMP_WORDS[1]}

    case ${subcommand} in
        create)
            COMPREPLY=($(compgen -W "--file -f --quantize -q" -- "$cur"))
            return 0
            ;;
        serve|pull|signin|signout|list|ps|help)
            # No argument completion for these commands
            return 0
            ;;
        *)
            # Fetch and display model names for other commands (Group 1)
            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            COMPREPLY=($(compgen -W "${models}" -- "$cur"))
            COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
            __ltrim_colon_completions "$cur"
            ;;
    esac
}

# Register the completion function for 'ollama' command
complete -F _ollama_completions ollama

# [[HUMAN COMMENTED-OUT]]
# This script defines a single function `_ollama_completions` that provides tab completion for various subcommands of the `ollama` tool. It uses a `case` statement to handle different types of completion based on the subcommand provided.
