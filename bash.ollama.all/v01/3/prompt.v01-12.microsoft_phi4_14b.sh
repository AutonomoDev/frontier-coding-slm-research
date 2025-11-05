```bash
_ollama_completions() {
    # Validate that the command is 'ollama' followed by a specific subcommand
    [[ "${COMP_WORDS[0]}" != "ollama" || -z "${COMP_WORDS[1]}" ]] && { COMPREPLY=(); return; }
    
    local cur prev
    _get_comp_words_by_ref -n : cur prev

    # Check if 'ollama' command is available, exit if not found
    if ! command -v ollama &>/dev/null; then 
        COMPREPLY=()
        return
    fi

    # Fetch the list of models using `ollama list`
    local models
    models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
    
    # Return if no models are found
    [[ -z "$models" ]] && { COMPREPLY=(); return; }
    
    # Generate completions for the current word using compgen
    COMPREPLY=($(compgen -W "$models" -- "$cur"))
    
    # Sort and trim colon-completions, if necessary
    COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
    __ltrim_colon_completions "$cur"
}

complete -F _ollama_completions ollama
```

### Explanation:
- **Validation**: The function first checks that the command being completed starts with `ollama` followed by a subcommand. If not, it exits early.
  
- **Command Existence Check**: Before attempting to fetch models, it ensures that the `ollama` command is available on the system.

- **Model Fetching**: It uses `ollama list`, processes its output starting from the second line (using `tail -n +2`), and extracts model names using `awk`.

- **Completion Generation**: The function uses `compgen` to generate possible completions for the current word (`$cur`). These are based on the models retrieved.

- **Sorting and Trimming**: It sorts the completion options and applies a trimming function to handle colons, which is useful for models prefixed with something like `codellama:`.

This setup provides tab completion specifically for subcommands of `ollama` that involve model names.

