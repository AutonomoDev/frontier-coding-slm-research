Thinking...
Alright, I need to generate a bash completion script for the `ollama run` command. Let me go through the requirements step by step.

First, the function needs to be named `_ollama_completions()`. That's straightforward.

Next, the check part: I have to ensure that the command being executed is exactly `ollama run`. So, I'll compare `COMP_WORDS[0]` to "ollama" and `COMP_WORDS[1]` to "run". If either doesn't match, I set `COMPREPLY` to an empty array and return. This ensures the completion only activates for `ollama run`.

Now, handling colons is crucial. The user mentioned that when someone types `codellama:<TAB>`, it should suggest the model sizes like "13b", "34b", etc. To handle this, I need to use `_get_comp_words_by_ref -n : cur prev`. This command splits the current word into parts using colons and sets `cur` to the part after the colon. Also, I must call `__ltrim_colon_completions "$cur"` after sorting to trim any leading colons from the completions.

Parsing models correctly is another important step. I need to check if the `ollama` command exists using `command -v ollama`. If it doesn't, set `COMPREPLY` and return. Then, fetch the list of models by running `ollama list`, ignoring any errors with `2>/dev/null`. Using `tail -n +2` skips the header line, and `awk '{print $1}'` extracts just the model names into a scalar variable `models`.

For completions, I use `compgen -W "$models" -- "$cur"` to generate possible matches. Wrapping this in an array assignment ensures that each completion is treated correctly.

Sorting comes next. I sort the `COMPREPLY` array by piping it through `printf "%s\n"` and then sorting line by line, which handles multi-word completions properly without breaking them into individual words.

Finally, after sorting, I call `__ltrim_colon_completions "$cur"` to ensure that any leading colons in the completions are removed, providing a clean output for the user.

I also need to make sure all edge cases are handled, like when there are no models or if `ollama` isn't installed. In those cases, I set `COMPREPLY` to an empty array and return early to avoid errors.

Putting it all together, the script should be robust, handle colons correctly, provide sorted suggestions, and only activate for the specific command. I'll structure each step carefully to meet all specified requirements.
...done thinking.

```bash
_ollama_completions() {
    # Check if command is "ollama run"
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { 
        COMPREPLY=(); 
        return; 
    }

    local cur prev
    _get_comp_words_by_ref -n : cur prev  # Handles colon-separated completions

    # Check if ollama command exists
    if ! command -v ollama &>/dev/null; then
        COMPREPLY=();
        return;
    fi

    # Get list of models from ollama
    local models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
    
    # If no models found, return early
    if [ -z "$models" ]; then
        COMPREPLY=();
        return;
    fi

    # Generate completions
    COMPREPLY=($(compgen -W "$models" -- "$cur"))

    # Sort completions
    COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))

    # Handle colon trimming for completion suggestions
    __ltrim_colon_completions "$cur"
}

# Register the completion function with bash
complete -F _ollama_completions ollama
```

