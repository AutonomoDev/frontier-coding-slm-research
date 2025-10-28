Thinking...
Okay, I need to generate a Bash completion script for the `ollama run` command. Let me think through each step carefully based on the user's requirements.

First, the function needs to be named `_ollama_completions`. The user specified that it should only activate when the command is exactly `ollama run`, so I'll check `COMP_WORDS[0]` and `[1]` to ensure they are "ollama" and "run" respectively. If not, I'll clear `COMPREPLY` and return.

Next, handling colons is crucial. The user mentioned using `_get_comp_words_by_ref -n : cur prev` without any checks. So I'll set `cur` and `prev` this way. This helps in cases where the model name has a colon, like `codellama:13b`.

Parsing the models correctly is another key point. I need to get the list of models from `ollama list`. The output starts with headers, so I'll use `tail -n +2` to skip them. Using `awk '{print $1}'` extracts just the model names into a scalar variable `models`. If `ollama` isn't installed or there are no models, I should handle that by clearing `COMPREPLY` and returning early.

For completions, I'll use `compgen -W "$models" -- "$cur"` to generate possible matches. Wrapping this in `$(...)` ensures it's an array. Then, I need to sort the results using `printf "%s\n" "${COMPREPLY[@]}" | sort` and assign them back to `COMPREPLY`.

After sorting, trimming colons is necessary. The function `__ltrim_colon_completions "$cur"` will handle this by removing any colon prefix from each completion option.

Finally, I'll register the completion with `complete -F _ollama_completions ollama` so that it's available when the user types `ollama run`.

I should also include comments explaining critical sections for clarity. Let me make sure all edge cases are handled: no `ollama`, empty models, and correct colon handling. Each step must follow exactly as specified to avoid bugs.
...done thinking.

```bash
_ollama_completions() {
    # Check if command is "ollama run"
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

    local cur prev
    _get_comp_words_by_ref -n : cur prev  # Handle colon-separated completions

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

    # Sort completions alphabetically
    COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))

    # Trim colon prefix from completions
    __ltrim_colon_completions "$cur"
}

complete -F _ollama_completions ollama
```

