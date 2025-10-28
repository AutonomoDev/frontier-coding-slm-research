Thinking...
Okay, so I need to write a bash completion script for the `ollama run` command. Let's break down what needs to be done based on the requirements.

First, the function name should be `_ollama_completions`. That's straightforward.

The first check is crucial: it must only activate when the command is exactly `ollama run`. The provided code snippet checks if COMP_WORDS[0] and [1] are "ollama" and "run", respectively. If not, it sets COMPREPLY to empty and returns. So I'll include that condition at the beginning of the function.

Next, handling colons. The script should use `_get_comp_words_by_ref -n : cur prev` without any checks or fallbacks. This means setting `cur` and `prev` variables correctly, even if there's a colon in the command. So I'll add that line after the initial check.

Parsing models is next. I need to ensure that the ollama command exists; otherwise, we return early with an empty COMPREPLY. Then, using `ollama list`, I capture the output starting from the second line (skipping headers) and extract the first column, which are the model names. This is done by assigning it to a scalar variable `models`. I have to make sure this works even if there's no ollama command or if it doesn't return any models.

For completions, I use `compgen -W "$models" -- "$cur"` and assign it to COMPREPLY as an array. This ensures that the suggestions are based on the available models.

Sorting is important too. The script sorts COMPREPLY using `printf` and `sort`, which handles each element correctly without creating a single string, thus avoiding sorting issues.

After sorting, I need to trim any colons from the completions using `__ltrim_colon_completions "$cur"`. This function will adjust the suggestions so that if the current word ends with a colon (like `codellama:`), it trims it before suggesting the next part.

Finally, the script registers itself as the completion function for ollama. This ensures that when someone types `ollama run`, the completions kick in.

I also need to make sure all edge cases are handled, like when there are no models installed or when ollama isn't available. In those cases, the script should just return with an empty COMPREPLY array.

Putting it all together, I structure the function step by step, ensuring each part meets the specified requirements and avoids any unnecessary checks or complications.
...done thinking.

```bash
# Bash completion for `ollama run` command

complete -F _ollama_completions ollama

function _ollama_completions {
    # Check if command is exactly "ollama run"
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && {
        COMPREPLY=()
        return
    }

    # Handle colon completion cases
    local cur prev
    _get_comp_words_by_ref -n : cur prev

    # Ensure ollama command exists and parse models
    if ! command -v ollama &>/dev/null; then
        COMPREPLY=()
        return
    fi
    local models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
    if [ -z "$models" ]; then
        COMPREPLY=()
        return
    fi

    # Generate completions from model names
    COMPREPLY=($(compgen -W "$models" -- "$cur"))

    # Sort the completion results
    COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))

    # Trim colons from completion suggestions if needed
    __ltrim_colon_completions "$cur"
}
```

This script fulfills all requirements:

- It activates only for `ollama run`
- Handles colon-based completions properly
- Uses correct parsing and sorting methods
- Includes proper error handling for missing ollama command or empty model list
- Uses `_get_comp_words_by_ref -n :` without type checks
- Calls `__ltrim_colon_completions` after sorting

The script ensures that:
1. The completion only triggers for the exact command "ollama run"
2. Colon-based completions are handled correctly
3. Model names are parsed from ollama list output
4. Suggestions are sorted and formatted properly
5. Edge cases are gracefully handled

