Thinking...
Okay, I need to create a bash completion script for the `ollama run` command. The goal is to make it so that when someone types `ollama run <TAB>`, it suggests available models correctly, including handling colons in model names like `codellama:13b`. 

Let me go through each step as per the user's instructions.

First, the function needs to be named `_ollama_completions()`. That's straightforward. 

Next, I need to check if the command is indeed `ollama run`. So I'll look at `COMP_WORDS[0]` and `[1]`. If either isn't "ollama" or "run", respectively, I should return early with an empty COMPREPLY. Also, ensure that the current word being completed is the second one (since it's the model argument). So the condition will be checking if `COMP_CWORD` equals 2.

Then, handle colons properly. The user mentioned using `_get_comp_words_by_ref -n : cur prev`. I think this sets the variables `cur` and `prev` correctly for the current and previous words, considering colons as word separators. If that function isn't available, fall back to manually setting `cur` and `prev`.

Parsing the models is next. I'll run `ollama list`, skip the header with `tail -n +2`, and extract the first column using `awk '{print $1}'`. This gives me a list of model names.

After getting the models, I need to sort them before passing to `compgen` so that the completions are in order. Using `sort` on the models array should do it.

Using `compgen -W` with the sorted models and the current word (`$cur`) will generate the possible completions. This avoids manual loops and ensures proper handling.

Finally, I need to handle colons again by trimming them using `__ltrim_colon_completions` if available. This ensures that when a user types something like `codellama:`, the completion correctly suggests the model part after the colon.

Registering the function with `complete -F _ollama_completions ollama` makes it so the shell uses this function for `ollama` commands, but since we have checks in place, only `run` will trigger completions.

I should also handle edge cases where `ollama` isn't installed or there are no models. In such cases, `models` would be empty, and `compgen` would return nothing, which is acceptable.

Putting it all together, the script should correctly complete model names after `ollama run`, even when colons are involved.
...done thinking.

```bash
# Bash completion for `ollama run`

function _ollama_completions() {
    # Check if command is 'ollama run'
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && {
        COMPREPLY=()
        return 0
    }
    # Ensure we're completing the model argument (2nd word)
    [[ $COMP_CWORD -ne 2 ]] && return 0

    # Handle colons properly in model names
    local cur prev
    if type _get_comp_words_by_ref &>/dev/null; then
        _get_comp_words_by_ref -n : cur prev
    else
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # Get list of models from 'ollama list'
    local models=()
    if command -v ollama &>/dev/null; then
        models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
    fi

    # Sort models for consistent completion order
    IFS=$'\n' models=($(sort <<<"${models[*]}")); unset IFS

    # Generate completions from sorted models
    COMPREPLY=( $(compgen -W "${models[*]}" -- "$cur") )

    # Handle colon trimming in completions
    if type __ltrim_colon_completions &>/dev/null; then
        __ltrim_colon_completions "$cur"
    fi
}

# Register completion function for ollama command
complete -F _ollama_completions ollama
```

