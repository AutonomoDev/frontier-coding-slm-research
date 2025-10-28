Thinking...
Alright, I need to generate a bash completion script for the `ollama run` command. Let me start by understanding the requirements.

First, the function should be called `_ollama_completions`. It must activate only when the command is exactly `ollama run`. So, I'll check if `COMP_WORDS[0]` is "ollama" and `COMP_WORDS[1]` is "run". If not, I set `COMPREPLY` to empty and return.

Next, handling colons. The user mentioned that for something like `codellama:`, the completion should suggest versions like "13b", "34b", etc. To manage this, I need to use `_get_comp_words_by_ref -n : cur prev`. This sets `cur` and `prev` correctly, especially when dealing with colons.

Now, parsing models. I'll check if the `ollama` command exists. If not, set `COMPREPLY` to empty and return. Then, I'll fetch the list of models using `ollama list`, ignoring any errors, and extract just the model names using `awk`. These models are stored in a scalar variable `$models`.

For completions, I use `compgen -W "$models" -- "$cur"` wrapped in an array assignment to `COMPREPLY`. This ensures that only valid models are suggested.

After generating the completions, I need to sort them. The correct method is to print each element on a new line, sort them, and then reassign `COMPREPLY` with the sorted list.

Finally, I must handle colons by trimming any leading colon from the completion results using `__ltrim_colon_completions "$cur"` after sorting.

Putting it all together, I structure the function step-by-step, ensuring each requirement is met without any unnecessary checks or loops. This should make the script robust and production-ready.
...done thinking.

```bash
# Bash completion script for `ollama run` command

complete -F _ollama_completions ollama

# Function to handle completions for `ollama run`
function _ollama_completions() {
    # Check if command is exactly "ollama run"
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && {
        COMPREPLY=()
        return
    }

    # Handle colon completion logic
    local cur prev
    _get_comp_words_by_ref -n : cur prev

    # Check if ollama command exists
    if ! command -v ollama &>/dev/null; then
        COMPREPLY=()
        return
    fi

    # Get list of available models
    local models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
    if [ -z "$models" ]; then
        COMPREPLY=()
        return
    fi

    # Generate completions based on current input
    COMPREPLY=($(compgen -W "$models" -- "$cur"))

    # Sort the completion results
    COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))

    # Trim colons from completion suggestions if necessary
    __ltrim_colon_completions "$cur"
}
```

