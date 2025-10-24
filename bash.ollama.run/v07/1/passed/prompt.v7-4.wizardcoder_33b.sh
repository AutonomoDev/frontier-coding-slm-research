# Here is a simple bash script that meets all the requirements:

#!/bin/bash

_ollama_run_completion() {
    local cur prev words cword run_index old_wb
    _get_comp_words_by_ref -n : cur prev words cword

    # Find index of 'run' in COMP_WORDS. If not found, return to avoid unnecessary processing.
    for (( run_index=0; run_index < ${#words[@]}; run_index++ )); do
        if [[ "${words[run_index]}" = "run" ]]; then
            break
        fi
    done
    # If current word position is not 'run' index + 1, return to avoid unnecessary processing.
    (( $cword != $run_index+1 )) && return

    # Remove colon from COMP_WORDBREAKS temporarily.
    old_wb=$COMP_WORDBREAKS
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}

    # Get list of models by parsing output of 'ollama list'.
    local model_list=($(ollama list 2>/dev/null | awk 'NR > 1 {print $1}'))

    # Generate completion matches with compgen and save to COMPREPLY.
    COMPREPLY=($(compgen -W "${model_list[*]}" -- "$cur"))

    # Restore original COMP_WORDBREAKS.
    COMP_WORDBREAKS=$old_wb
}

# Register the completion function for 'ollama' command.
complete -F _ollama_run_completion ollama

# This script works by:
#
# 1. Defining a Bash function that will generate completions for `ollama run` commands.
# 2. Finding the index of "run" in `COMP_WORDS` and checking if current word is immediately following it.
# 3. Temporarily removing colon from `COMP_WORDBREAKS` to prevent model names with colons being split into multiple tokens.
# 4. Using `ollama list` to get available model names and store them in an array.
# 5. Using `compgen -W "${model_list[*]}" -- "$cur"` to generate completion matches from the model name array, saving them to `COMPREPLY`.
# 6. Restoring original `COMP_WORDBREAKS` after completion has been generated.
# 7. Registering the function with bash-completion framework using `complete -F _ollama_run_completion ollama`. This command will automatically trigger the function for any `ollama run` commands entered in Bash shell, providing autocompletion suggestions based on available model names from `ollama list` output.
#
# This script assumes that the `ollama` command and its subcommands are already installed and set up correctly with bash-completion support. If the `ollama` command does not exist or is not set up properly, this script will have no effect.

