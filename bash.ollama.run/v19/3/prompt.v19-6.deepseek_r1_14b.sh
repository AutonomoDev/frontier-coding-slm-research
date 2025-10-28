# Bash completion script for ollama run command

#Thinking...
#Alright, I need to create a bash completion script for the `ollama run` command. Let me go through the requirements step by step.
#
#First, the function name should be `_ollama_completions`. That's clear.
#
#Next, I have to check if the command is exactly "ollama run". The condition given is `[[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]`. If this is true, set `COMPREPLY` to empty and return. So I'll include that at the beginning of the function.
#
#Then, handling colons: I need to get the current word (`cur`) and previous word (`prev`). Using `_get_comp_words_by_ref -n : cur prev` without any checks. This is important because it might set `cur` to something like "codellama:" if a colon is present.
#
#Parsing models comes next. I have to check if the `ollama` command exists. If not, set `COMPREPLY` to empty and return. Then, get the models using `ollama list`, skipping the first line (hence `tail -n +2`), and extract the first column with `awk '{print $1}'`. The output is stored in a scalar variable `$models`.
#
#For completions, I use `compgen -W "$models" -- "$cur"` wrapped in an array assignment to `COMPREPLY`. This ensures that each model is treated as a separate completion.
#
#Sorting the results is crucial. I print each element of `COMPREPLY` with `printf`, sort them, and assign back to `COMPREPLY`.
#
#After sorting, I call `__ltrim_colon_completions "$cur"` to handle any leading colons in the completions.
#
#Finally, I register the completion function with `complete -F _ollama_completions ollama`.
#
#I should make sure that all edge cases are handled, like when there are no models or when `ollama` isn't installed. Also, ensure that the script works correctly when a colon is present in the command.
#
#Putting it all together, I write the function with these steps, adding comments where necessary for clarity.
#...done thinking.

complete -F _ollama_completions ollama

function _ollama_completions {
    # Check if command is "ollama run"
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && {
        COMPREPLY=()
        return
    }

    local cur prev
    _get_comp_words_by_ref -n : cur prev

    # Check if ollama command exists and parse models
    if ! command -v ollama &>/dev/null; then
        COMPREPLY=()
        return
    fi

    local models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
    if [ -z "$models" ]; then
        COMPREPLY=()
        return
    fi

    # Generate completions from models
    COMPREPLY=($(compgen -W "$models" -- "$cur"))

    # Sort the completions
    COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))

    # Handle colon trimming for model suggestions
    __ltrim_colon_completions "$cur"
}
