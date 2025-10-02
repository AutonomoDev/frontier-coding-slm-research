#!/bin/bash

_ollama_run() {
    local cur prev words cword
    _get_comp_words_by_ref -n := cword words

    # Default to the current word if it's not 'run'.
    if [ "${COMP_WORDS[1]}" != "run" ]; then return; fi

    # The current word being typed is in $cur.
    cur=${words[cword]}

    # Fetch list of models by running `ollama list`, filtering out the header line and extracting only model names.
    COMPREPLY=($(compgen -W "$(ollama list | awk 'NR>1 {print $1}')" -- $cur))
}

# Attach completion function to `ollama run` command.
complete -F _ollama_run ollama

# [[HUMAN COMMENTED-OUT]]
#This script works by defining a Bash completion function, `_ollama_run()`, and then attaching it to the `ollama` command with `complete -F _ollama_run ollama`. The key part is the `compgen` line inside `_ollama_run()`: this constructs a completion reply based on matching entries from the output of `ollama list | awk 'NR>1 {print $1}'` against the current word, effectively completing model names when they are entered after `ollama run`.
#
#The use of `compgen` ensures that completions are properly sorted and that any characters in the current word being typed (i.e., `$cur`) will be used to filter the completion options. The `-- $cur` ensures that filenames or other potential command arguments aren't mistaken for model names, since Bash completion logic only suggests completions of valid commands and does not attempt to offer filename suggestions.
#
#Additionally, a check at the start of `_ollama_run()` (`if [ "${COMP_WORDS[1]}" != "run" ]; then return; fi`) ensures that this completion function only activates when the second word is 'run'. This avoids offering suggestions for parts of the command line that are not model names, such as filenames or other potential command arguments.
#
#The script assumes `ollama list` produces a column-aligned output with the model names in the first column (as in your example). If this is not the case, the `awk 'NR>1 {print $1}'` portion of the script may need to be adjusted accordingly.

