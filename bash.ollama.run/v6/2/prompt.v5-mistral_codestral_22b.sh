# /etc/bash_completion.d/ollama

# If `_get_comp_words_by_ref` is missing, manually set `cur` and `prev`.
if declare -f _get_comp_words_by_ref > /dev/null; then
    _get_comp_words_by_ref cur prev words cword
else
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
fi

# Activate the completion logic only for the word immediately following the `run` subcommand.
if [ "${words[0]}" = "ollama" ] && [ "$prev" = "run" ]; then
    # Get a list of available model names and filter based on the user's input.
    COMPREPLY=( $(compgen -W "$(ollama list | tail -n +2 | cut -d ' ' -f 1 | grep "^$cur")" -- "$cur") )
fi

