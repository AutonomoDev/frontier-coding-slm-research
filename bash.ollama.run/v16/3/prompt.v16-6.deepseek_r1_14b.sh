# [[HUMAN COMMENTED-OUT]]
#Thinking...
#Alright, so I need to create a Bash completion script for the command `ollama run`. The goal is to make sure that when someone types `ollama run` and then presses Tab, it suggests the available models correctly. But there are some bugs I need to avoid based on prior versions.
#
#First, I remember that one of the critical bugs was related to array indexing. The script must check if the command being completed starts with "ollama" followed by "run". So, I should verify that `COMP_WORDS[0]` is "ollama" and `COMP_WORDS[1]` is "run". If not, it shouldn't suggest anything.
#
#Next, there's a problem with colons. The default behavior splits on colons, which messes up model names like "codellama:13b". To fix this, I need to temporarily modify `COMP_WORDBREAKS` to remove the colon so that the word isn't split. After processing, I should restore the original word breaks.
#
#Then, I have to handle the case where `ollama` might not be installed or if there are no models listed. The script should check for these conditions and set `COMPREPLY` appropriately without crashing.
#
#The approach is to first check if we're completing after "ollama run". If not, return early with an empty reply. Then, handle the colon issue by modifying word breaks and reparsing. After that, extract model names using `ollama list` and process them with `awk` to skip the header.
#
#I also need to generate completions based on the current cursor position (`cur`). Using `compgen -W "$models" -- "$cur"` will provide the correct suggestions. Finally, I must call `__ltrim_colon_completions` to ensure that any colons in the model names are handled correctly.
#
#Putting it all together, the function `_ollama_completions` should do these steps: check the command indices, handle colons, extract models, generate completions, and set the reply. Then, register the completion with `complete`.
#
#I need to make sure that every possible edge case is handled, like missing `ollama`, no models, or incorrect command structure. This way, the script remains robust and reliable.
#...done thinking.

# Bash Completion Script for `ollama run`
function _ollama_completions() {
    # CRITICAL: Check if completing after "ollama run"
    [[ ${COMP_WORDS[0]} != "ollama" || ${COMP_WORDS[1]} != "run" ]] && { COMPREPLY=(); return 0; }

    # Handle colons: Temporarily remove ':' from word breaks to reparse correctly
    local _old_wb=${COMP_WORDBREAKS}
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}
    _get_comp_words_by_ref -n : cur prev
    COMP_WORDBREAKS=${_old_wb}

    # Check if ollama is available and extract models
    command -v ollama &>/dev/null || { COMPREPLY=(); return 0; }
    local models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}')

    # If no models, return empty
    [[ -z $models ]] && { COMPREPLY=(); return 0; }

    # Generate completions based on current cursor
    COMPREPLY=( $(compgen -W "$models" -- "$cur") )

    # Fix display for colon cases
    __ltrim_colon_completions "$cur"

    return 0
}

# Register completion function for ollama command
complete -F _ollama_completions ollama
