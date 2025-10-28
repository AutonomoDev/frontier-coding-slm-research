Thinking...
Okay, I need to create a bash completion script for the `ollama run` command. Let me go through the problem step by step.

First, the goal is to make sure that when someone types `ollama run <TAB>`, it suggests available models correctly, including handling cases where model names have colons like `codellama:13b`.

Looking at the key bugs section, I see a few important points. The script should activate only when the command is exactly `ollama run`. So, I need to check that `COMP_WORDS[0]` is "ollama" and `COMP_WORDS[1]` is "run". Also, if the number of words isn't 2 (meaning it's not just `ollama run`), we should return early.

Next, handling colons. I remember that using `_get_comp_words_by_ref -n : cur prev` will handle the current and previous word correctly when there's a colon involved. After getting these, I have to call `__ltrim_colon_completions "$cur"` to properly manage completions after a colon.

For parsing the models, the script should execute `ollama list`, skip the header (since it's not needed), and extract the model names. Using `tail -n +2` skips the first line, which is the header. Then, using `awk '{print $1}'` gets just the first column, which is the model name.

I should store these model names in an array called `models`. It's important to sort them before generating completions so that they appear in a logical order when the user presses TAB multiple times.

The completion part uses `compgen -W "${models[*]}" -- "$cur"`, which is the correct way to get word completions based on the models list. This avoids manual loops and ensures proper handling.

Finally, after generating the COMPREPLY, I need to call `__ltrim_colon_completions` if it's available to ensure that any trailing colons are trimmed correctly for the current word.

I should also handle edge cases where `ollama` isn't installed or there are no models listed. In such cases, the script should just return without setting COMPREPLY.

Putting it all together, I'll structure the function `_ollama_completions()` with these checks and steps in order. Then, register it using `complete -F _ollama_completions ollama` so that bash recognizes it for completion.

Let me write this out step by step, making sure each part is handled correctly.
...done thinking.

```bash
# Bash completion script for `ollama run`

function _ollama_completions() {
    # Check if the command is `ollama run`
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && {
        COMPREPLY=()
        return 0
    }
    # Ensure we're completing after exactly two words (i.e., `ollama run`)
    [[ $COMP_CWORD -ne 2 ]] && return 0

    local cur prev
    # Get current and previous word, handling colons properly
    if type _get_comp_words_by_ref &>/dev/null; then
        _get_comp_words_by_ref -n : cur prev
    else
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    local models=()
    # Parse `ollama list` to extract model names
    if command -v ollama &>/dev/null; then
        models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
    fi

    # Sort the models alphabetically
    IFS=$'\n' models=($(sort <<<"${models[*]}")); unset IFS

    # Generate completions based on the sorted models
    COMPREPLY=( $(compgen -W "${models[*]}" -- "$cur") )

    # Handle colon completion for model names like `codellama:13b`
    if type __ltrim_colon_completions &>/dev/null; then
        __ltrim_colon_completions "$cur"
    fi
}

# Register the completion function with bash
complete -F _ollama_completions ollama
```

