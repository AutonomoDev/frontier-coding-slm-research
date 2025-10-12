#!/bin/bash

# Thinking...
# Okay, I need to create a Bash completion script for the `ollama run` command. Let me start by understanding the requirements and potential pitfalls.
# 
# First, the function needs to activate only when the command is `ollama run`. So, I should check that `COMP_WORDS[0]` is "ollama" and `COMP_WORDS[1]` is "run". If not, return early without setting completions. That makes sense because we don't want this completion script interfering with other commands.
# 
# Next, handling model names with colons is crucial. Bash splits words on colons by default, which can cause issues when completing model names like `codellama:13b`. To fix this, I should use `_get_comp_words_by_ref -n :` to prevent splitting and set `cur` and `prev` correctly. If that function isn't available, perhaps in older versions of Bash, I'll need a fallback method, maybe manually extracting the current word from `COMP_WORDS`.
# 
# Parsing the output of `ollama list` properly is another key point. The raw output includes headers and extra columns, so I must skip the header line. Using `awk '{print $1}'` will extract just the model names from each line. Also, I should handle cases where there are no models or if the `ollama` command isn't installed.
# 
# Once I have the list of model names, I need to filter them based on the current word being completed (`cur`). Using `compgen` with the `-P` and `-S` options can help format the suggestions correctly. After generating the completions, calling `__ltrim_colon_completions "$cur"` ensures that the colon handling works as expected, preventing any display issues.
# 
# I should also make sure the script handles edge cases gracefully, like when no models are installed or if the `ollama` command isn't found. This way, the completion doesn't break and provides helpful messages when possible.
# 
# Putting it all together, I'll structure the function step by step: check the command, handle colons, parse the model list, generate completions, trim colons in completions, and then register the completion function with `complete`.
# 
# I think that covers all the critical points. Now, let me translate this into code, making sure each part is correctly implemented and commented for clarity.
# ...done thinking.

_ollama_completions() {
    # Check if command is "ollama run"
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

    local cur prev words cword

    # Handle colon in model names
    _get_comp_words_by_ref -n : cur prev 2>/dev/null \
        || { 
            # Fallback if _get_comp_words_by_ref is not available
            local i
            for ((i=0; i<${#COMP_WORDS[@]}; i++)); do
                [[ ${COMP_WORDS[i]} == "$cur" ]] && cword=$i && break
            done
            words=("${COMP_WORDS[@]}")
        }

    # Check if ollama command exists
    if ! command -v ollama &>/dev/null; then
        COMPREPLY=()
        return
    fi

    # Get list of models
    local models
    models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')

    if [[ -z "$models" ]]; then
        COMPREPLY=()
        return
    fi

    # Generate completions
    local completions
    completions=$(echo "$models" | grep -i "^$cur")

    # Sort and format completions
    COMPREPLY=( $(compgen -W "$completions" -- "$cur") )

    # Fix colon display in completions
    __ltrim_colon_completions "$cur"
}

# Register completion function
complete -F _ollama_completions ollama
