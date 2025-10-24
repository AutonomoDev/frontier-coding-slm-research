#Thinking...
#Okay, I need to write a Bash completion script for the command 'ollama run' that dynamically completes model names. Let me break down what needs to be done based on the user's requirements and the provided context.
#
#First, the script must activate exclusively after typing 'ollama run'. So, I'll start by checking if the first two words are 'ollama' and 'run'. If not, it should return without suggesting anything.
#
#Next, handling colons correctly is crucial. The default behavior splits on colons, which messes up model names like 'codellama:13b'. To fix this, I need to temporarily modify COMP_WORDBREAKS by removing the colon so that the shell doesn't split the input. After reparsing with _get_comp_words_by_ref, I'll restore the original word breaks.
#
#I also need to ensure that if the user is typing something like 'codellama:...', the completion works correctly. So after handling the colons, I should ltrim them from the completions so that only the suffix (like '13b') appears.
#
#Then, checking if 'ollama' is installed is necessary. If it's not available, there's nothing to complete, so set COMPREPLY to empty and return.
#
#To get the list of models, I'll run 'ollama list' and extract the model names using awk, skipping the header line. This will give me all the model names in a variable called models.
#
#If there are no models, again, set COMPREPLY to empty.
#
#Now, generating completions involves using compgen with the models list and matching against the current cursor position. I'll use the -W option for word completion. After setting COMPREPLY, I must call __ltrim_colon_completions to ensure that any colons in the model names are handled correctly during display.
#
#Finally, register the function so that it's used when completing 'ollama' commands. The complete command with -F sets the function for ollama.
#
#I need to make sure all edge cases are covered: missing ollama, no models available, and correct handling before and after colons. Also, setting COMPREPLY in every possible branch where there's nothing to suggest is important to prevent default completions like files or directories.
#...done thinking.

_ollama_completions() {
    # CRITICAL: Check if completing after "ollama run"
    [[ ${COMP_WORDS[0]} != "ollama" || ${COMP_WORDS[1]} != "run" ]] && { COMPREPLY=(); return 0; }

    # Handle colons: Temporarily remove ':' from word breaks to reparse correctly
    local _old_wb=${COMP_WORDBREAKS}
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}
    _get_comp_words_by_ref -n : cur prev
    COMP_WORDBREAKS=${_old_wb}

    # Check if ollama available
    command -v ollama &>/dev/null || { COMPREPLY=(); return 0; }

    # Extract models robustly (skip header, get names only)
    local models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}')

    # If no models, empty reply
    [[ -z $models ]] && { COMPREPLY=(); return 0; }

    # Filter and set completions
    COMPREPLY=( $(compgen -W "$models" -- "$cur") )

    # MANDATORY: Fix display after colons
    __ltrim_colon_completions "$cur"

    return 0
}

# Register completion function for ollama
complete -F _ollama_completions ollama
