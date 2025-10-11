# [[HUMAN COMMENTED-OUT]]
#[SYS]  Here is a possible implementation of the bash completion script for the `ollama run` command:

#!/bin/bash

_ollama_completions() {
    # If the first argument is not "run", return early
    if [[ ${COMP_WORDS[1]} != "run" ]]; then
        return
    fi

    # Temporarily remove ':' from COMP_WORDBREAKS and re-parse the command line using _get_comp_words_by_ref with -n : to handle colons properly
    local prev_COMP_WORDBREAKS=$COMP_WORDS
    COMP_WORDBREAKS=${COMP_WORDS//:/}
    local cur prev
    _get_comp_words_by_ref -n : cur prev
    # Restore the original COMP_WORDBREAKS immediately after re-parsing
    COMP_WORDBREAKS=$prev_COMP_WORDBREAKS

    # If "run" is not in $prev, return early
    if [[ ${prev//:/} != *run* ]]; then
        return
    fi

    # Get the list of available models using ollama list
    local models=$(ollama list | awk 'NR>1 {print $1}' | xargs)

    # Generate completions for the current word ($cur) based on the retrieved model names
    compgen -W "$models" -- "$cur"
}

# Register the completion function
complete -F _ollama_completions ollama

# [[HUMAN COMMENTED-OUT]]
#This script defines a `_ollama_completions` function that handles completions for the `ollama run` command. It first checks if the first argument is "run", and returns early if it's not. Then, it temporarily removes ':' from COMP_WORDBREAKS and re-parses the command line using _get_comp_words_by_ref with -n : to handle colons properly. It then restores the original COMP_WORDBREAKS immediately after re-parsing.
#
#Next, it checks if "run" is in $prev, and returns early if it's not. Then, it gets the list of available models using `ollama list` and generates completions for the current word ($cur) based on the retrieved model names. Finally, it registers the completion function using `complete -F _ollama_completions ollama`.
#
#Note that this script assumes that `bash-completion` is loaded and `_get_comp_words_by_ref` is available.

