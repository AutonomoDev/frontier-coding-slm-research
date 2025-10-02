#Thinking...
#Okay, so I need to create a bash completion script for the `ollama run` command that dynamically completes model names. The models have colons in them, like `codellama:13b`, and I remember that bash splits on colons by default, which can mess up the completions.
#
#First, I should define a function named `_ollama_completions`. Inside this function, I need to check if the current command is `ollama` and the previous word is `run`. If not, I just return with an empty COMPREPLY because there's nothing to complete here.
#
#Next, handling colons is tricky. I recall that using `_get_comp_words_by_ref` with the `-n :` flag can help split words without breaking on colons. But some systems might not have bash-completion installed, so I need a fallback. So I'll use an if statement: if `_get_comp_words_by_ref -n : cur prev` fails, then set `cur` and `prev` using the standard COMP_WORDS array.
#
#Once I have `cur` and `prev`, I check if `prev` is "run". If it is, I need to get the list of models. I'll run `ollama list`, parse the output with awk to extract just the model names, skipping the header row.
#
#Then, I filter these model names to match what the user has typed so far (`$cur`). After that, I sort them and use `compgen -W` to generate the possible completions. But wait, I need to handle colons correctly in the output, so I call `__ltrim_colon_completions "$cur"` right after setting COMPREPLY.
#
#Finally, I register the completion function with `complete -F _ollama_completations ollama`. Also, I make sure to include comments explaining each step, especially the colon handling parts and why the trimming is necessary. Plus, I check for errors like if `ollama` isn't installed or if the list command fails.
#...done thinking.

# Bash completion script for ollama run command with dynamic model name completion

complete -F _ollama_completions ollama

function _ollama_completions {
    local cur prev
    # Check if this is an ollama command and previous word is "run"
    if [[ "${COMP_WORDS[0]}" != "ollama" || "${prev}" != "run" ]]; then
        return 0
    fi

    # Handle colon in word breaks properly
    if ! _get_comp_words_by_ref -n : cur prev; then
        # Fallback for systems without bash-completion
        local IFS="${IFS}:" # Preserve colons in word splitting
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # Get list of models
    local models=()
    if command -v ollama &> /dev/null; then
        ollama list 2>/dev/null | awk 'NR==1 {skip=1} skip{print $1}' > /tmp/ollama_models.$$ || exit $?
        while IFS= read -r line; do models+=("$line"); done < /tmp/ollama_models.$$
        rm /tmp/ollama_models.*
    fi

    # Generate completions
    local COMPREPLY=()
    if [[ "${prev}" == "run" ]]; then
        for model in "${models[@]}"; do
            if [[ "$model" == "$cur"* ]]; then
                COMPREPLY+=("$model")
            fi
        done
        # Sort matches and generate completions
        COMPREPLY=$(printf '%s\n' "${COMPREPLY[@]}" | sort)
        COMPREPLY="$(compgen -W "$COMPREPLY" -- "$cur")"
    fi

    __ltrim_colon_completions "$cur"

    return 0
}
