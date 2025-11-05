```bash
_ollama_completions() {
    # Validate that the command is 'ollama' followed by a valid subcommand
    [[ "${COMP_WORDS[0]}" != "ollama" || -z "${COMP_WORDS[1]}" ]] && { COMPREPLY=(); return; }

    local cur prev
    _get_comp_words_by_ref -n : cur prev

    # Check if 'ollama' command exists, and get the list of models if available
    if ! command -v ollama &>/dev/null; then 
        COMPREPLY=(); 
        return;
    fi
    
    local models
    # Fetch the list of model names from 'ollama list', skipping the header
    models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
    
    [[ -z "$models" ]] && { COMPREPLY=(); return; }
    
    # Generate possible completions for the current word based on available models
    COMPREPLY=($(compgen -W "$models" -- "$cur"))
    
    # Sort the completion list and handle colon trimming if needed
    COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
    __ltrim_colon_completions "$cur"
}

complete -F _ollama_completions ollama
```

### Explanation

1. **Command Validation**: The function first checks that the current command being completed starts with `ollama` and has at least one subcommand specified.

2. **Word Extraction**: Uses `_get_comp_words_by_ref -n :` to extract the current word (`cur`) and previous word (`prev`). This allows the completion script to understand what is currently being typed and provide relevant suggestions.

3. **Command Existence Check**: Ensures that `ollama` is a valid command on the system, exiting early if it isn't found.

4. **Model Retrieval**: Fetches available models using `ollama list`, processes the output to extract model names while skipping the header line. Handles cases where no models are returned by checking for an empty string.

5. **Completion Generation**: Uses `compgen` with a wordlist of available models to generate possible completions based on the current input (`$cur`).

6. **Sorting and Trimming**: The list of potential completions is sorted to maintain order, and then trimmed of any leading colons using `__ltrim_colon_completions`, ensuring that it handles inputs like `codellama:<TAB>` correctly.

This script provides robust tab completion for the `ollama` command by dynamically generating suggestions based on available models.

