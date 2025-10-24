# [[HUMAN COMMENTED-OUT]]
#This task involves writing a robust and correct Bash completion script for the `ollama run` command. We'll use several standard features of Bash to accomplish this, such as process substitution (command substitutions), arrays, and variable expansions.

#!/bin/bash
# This function is called by bash when <TAB> is pressed after "ollama run"
_ollama_run() {
    # Check if the word being completed is 'run'
    if [[ ${COMP_WORDS[1]} == "run" ]]; then
        # Use process substitution to get the model names from ollama list command
        local models=($(ollama list | awk 'NR>1 {print $1}'))

        # Filter the models based on what the user has typed
        COMPREPLY=($(compgen -W "${models[*]}" -- "$2"))
    fi
}
# Associate our function with the ollama command
complete -F _ollama_run ollama

# [[HUMAN COMMENTED-OUT]]
#This script works by defining a Bash completion function that uses the `-F` option to specify a custom function. This function, `_ollama_run()`, is only activated when the user is typing after "ollama run", which it detects using `COMP_WORDS[1]`. It gets the list of models by running `ollama list` and processing its output with `awk 'NR>1 {print $1}'` to extract just the model names, skipping over the header line.
#
#Finally, it uses `compgen -W "${models[*]}" -- "$2"` to generate completion suggestions based on what the user has typed so far (`"$2"`). This is a built-in Bash function that generates possible completions from a list of words.
#
#It also associates this function with the `ollama` command using `complete -F _ollama_run ollama`, so it gets called automatically when you press `<TAB>` after typing "ollama run".

