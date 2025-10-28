# Thinking...
# Okay, I need to create a bash completion script for the `ollama run` command. The goal is to make it so that when someone types `ollama run <TAB>`, they get suggestions of available models.
# 
# First, I should figure out how bash completions work. From what I remember, bash uses functions called by the complete command. So I'll need to write a function and then register it with `complete -F`.
# 
# The task says the script should only activate when the user types `ollama run`, so I need to check that the first word is `ollama` and the second is `run`. Also, since we're completing the third argument (the model), I have to make sure that `$COMP_CWORD` is 2 because bash counts from zero.
# 
# Next, handling colons in model names like `codellama:13b` is important. I've heard about `_get_comp_words_by_ref` which can split words by a delimiter, here colon. This will help correctly handle cases where the user has already typed part after a colon.
# 
# Parsing the models from `ollama list` is another step. The output of `ollama list` includes headers, so using `tail -n +2` skips the first line. Then, using `awk '{print $1}'` extracts just the model names.
# 
# I should also make sure to sort the models before generating completions because compgen doesn't sort by default, and users expect a sorted list.
# 
# Edge cases include when `ollama` isn't installed or there are no models listed. The script should handle these gracefully without errors.
# 
# Putting it all together, I'll write a function `_ollama_completions()` that does these checks and parsing, then generate the completions using compgen. Finally, I'll register this function with the complete command for `ollama`.
# 
# I think I've covered all the points: checking the command structure, handling colons correctly, parsing model names, sorting them, and ensuring edge cases are handled. Now I'll translate these steps into bash code.
# ...done thinking.

_ollama_completions() {
    # Check if current command is 'ollama run'
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return 0; }
    # Only complete the third argument (model)
    [[ $COMP_CWORD -ne 2 ]] && return 0

    local cur prev
    # Handle colon completion
    if type _get_comp_words_by_ref &>/dev/null; then
        _get_comp_words_by_ref -n : cur prev
    else
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    local models=()
    # Parse model names from 'ollama list'
    if command -v ollama &>/dev/null; then
        models=($(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}'))
    fi

    # Sort models alphabetically
    IFS=$'\n' models=($(sort <<<"${models[*]}")) && unset IFS

    # Generate completions
    COMPREPLY=( $(compgen -W "${models[*]}" -- "$cur") )

    # Handle colon in completions
    if type __ltrim_colon_completions &>/dev/null; then
        __ltrim_colon_completions "$cur"
    fi
}

# Register completion function for 'ollama'
complete -F _ollama_completions ollama
