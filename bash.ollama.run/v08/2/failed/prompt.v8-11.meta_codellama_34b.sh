# [[HUMAN COMMENTED-OUT]]
#Here is a sample bash completion script for the `ollama run` command:

#!/bin/bash

# Bash completion for ollama run command

_get_comp_words_by_ref() {
    local exclude=_get_comp_words_by_ref
    local cur prev words cword
    if [[ $(type -t compopt) = "builtin" ]]; then
        _get_comp_words_by_ref() {
            local exclude=_get_comp_words_by_ref
            local IFS=$'\n'
            compgen -A file -X "$exclude" -- $1
        }
    else
        _get_comp_words_by_ref() {
            local exclude=_get_comp_words_by_ref
            local IFS=$'\n'
            compgen -P "${COMP_WORDS[*]}" -S "$1" -- $2
        }
    fi
}

_ollama_run_completion() {
    local cur prev words cword
    _get_comp_words_by_ref -n = cur prev words cword

    # Handle colon in model names
    local old_wb="$COMP_WORDBREAKS"
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}  # Remove colon

    # Find the exact position of "run" in $COMP_WORDS array
    run_index=$((${#COMP_WORDS[@]} - ${#prev}))

    if [ "$cur" = "" ]; then
        # Trigger completion when no input is provided
        COMPREPLY=($(compgen -W "$(ollama list 2>/dev/null | awk 'NR>1 {print $1}')"))
    elif [[ "$cur" == *: ]]; then
        # Trigger completion for models with colon in name
        COMPREPLY=($(compgen -P "${COMP_WORDS[*]}" -S ":${cur##*:}"))
    else
        # Normal completion for other cases
        COMPREPLY=()
    fi

    # Restore $COMP_WORDBREAKS
    COMP_WORDBREAKS="$old_wb"
}

# Register the completion function with bash-completion framework v2
if [[ "$(type -t complete)" = "builtin" ]]; then
    complete -F _ollama_run_completion ollama
else
    # Fallback for older versions of bash-completion framework
    complete -F _ollama_run_completion -o default ollama
fi

# [[HUMAN COMMENTED-OUT]]
#This script defines the `_get_comp_words_by_ref` function to safely handle colon in model names, and the `_ollama_run_completion` function to provide completion for the `ollama run` command. The script then registers the completion function with the bash-completion framework v2 using the `complete` builtin command.
#
#Note that this script assumes that the `ollama` command is available and that it provides the expected output when called with the `list` subcommand. Additionally, the script assumes that the bash-completion framework v2 is available on your system. If you're using an older version of bash-completion, you may need to modify the script accordingly.

