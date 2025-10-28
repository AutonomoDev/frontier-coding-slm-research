# Thinking...
# The user wants Bash code for completion of `ollama run <model>`. Provide function `_ollama_completions` following the steps. Must check COMP_WORDS[0] etc. Should handle colon trimming, parse models from `ollama list` output. They want only Bash code output, no extraneous text. Include inline comments for key parts. Edge handling: no `ollama` binary, no models, return. Ensure sorting.
# 
# Thus final answer: Provide Bash script. Let's craft it.
# 
# Use `complete -F _ollama_completions ollama`.
# 
# Implementation: function with local variables, etc.
# 
# Be careful about IFS sorting.
# 
# Return 0.
# 
# Also if no ollama binary, set COMPREPLY=() and return 0.
# 
# Ok. Provide code.
# ...done thinking.

# Bash completion for `ollama run <model>`

_ollama_completions() {
    # Only trigger for `ollama run`
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return 0; }

    # Ensure we are completing the second argument (the model name)
    [[ $COMP_CWORD -ne 2 ]] && return 0

    # Get current word and previous word, handling colons
    local cur prev
    if type _get_comp_words_by_ref &>/dev/null; then
        _get_comp_words_by_ref -n : cur prev
    else
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # Retrieve the list of models from `ollama list`
    local models=()
    if command -v ollama &>/dev/null; then
        models=($(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}'))
    fi

    # Sort the model names to provide deterministic ordering
    IFS=$'\n' sorted_models=($(sort <<<"${models[*]}"))
    unset IFS
    models=("${sorted_models[@]}")

    # Generate the completions for the current word
    COMPREPLY=( $(compgen -W "${models[*]}" -- "$cur") )

    # Trim the colon prefix if the user typed something like "codellama:"
    if type __ltrim_colon_completions &>/dev/null; then
        __ltrim_colon_completions "$cur"
    fi
}

# Register the completion function for the `ollama` command
complete -F _ollama_completions ollama
