```bash
_ollama_completions() {
    # Validate that the command is 'ollama run'
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

    # Extract current word for completion and previous word
    local cur prev
    _get_comp_words_by_ref -n : cur prev

    # Check if 'ollama' command exists, exit if not found
    if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi

    # Fetch models using 'ollama list', exclude header line
    local models
    models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
    
    # If no models are returned, exit gracefully
    [[ -z "$models" ]] && { COMPREPLY=(); return; }

    # Generate completion suggestions using compgen
    COMPREPLY=($(compgen -W "$models" -- "$cur"))

    # Sort the completion results and trim colons if present
    COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
    __ltrim_colon_completions "$cur"
}

# Associate the completion function with the 'ollama' command
complete -F _ollama_completions ollama
```

### Explanation:

1. **Function Definition**: The function `_ollama_completions` is defined to encapsulate logic for generating completions.

2. **Command Validation**: It checks if `COMP_WORDS[0]` is "ollama" and `COMP_WORDS[1]` is "run". If not, it exits early by setting `COMPREPLY=()` and returns.

3. **Word Extraction**: Uses `_get_comp_words_by_ref -n : cur prev` to get the current (`cur`) and previous (`prev`) words being completed.

4. **Command Existence Check**: Verifies if the `ollama` command is available on the system using `command -v`. If not, it exits by setting `COMPREPLY=()` and returns.

5. **Fetching Models**: Uses `ollama list`, pipes its output to `tail -n +2 | awk '{print $1}'` to extract model names while skipping the header line.

6. **Handling Empty Model List**: Checks if `$models` is empty, exits by setting `COMPREPLY=()` and returns early if true.

7. **Generating Completions**: Uses `compgen -W "$models" -- "$cur"` to generate completions based on the current input word and available models.

8. **Sorting and Trimming**: Sorts the completion results using `printf "%s\n" "${COMPREPLY[@]}" | sort`. Then, calls `__ltrim_colon_completions "$cur"` to handle any colon-based trimming if needed (e.g., for completions like `codellama:<TAB>`).

9. **Complete Command**: Associates the `_ollama_completions` function with the `ollama` command using `complete -F _ollama_completions ollama`, enabling tab completion when invoking `ollama run`.

This implementation ensures robust handling of various scenarios like missing commands or empty model lists, while providing a sorted list of completions.

