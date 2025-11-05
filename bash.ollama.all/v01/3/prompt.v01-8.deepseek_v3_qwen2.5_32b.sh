```bash
_ollama_completions() {
    # Validate that the command is ollama followed by the desired subcommand (e.g., list, serve)
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "{{COMMAND}}" ]] && { COMPREPLY=(); return; }

    local cur prev
    _get_comp_words_by_ref -n : cur prev

    # Ensure ollama command exists and fetch model list
    if ! command -v ollama &>/dev/null; then
        COMPREPLY=()
        return
    fi

    local models
    models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
    [[ -z "$models" ]] && { COMPREPLY=(); return; }

    # Generate completions based on current input and available models
    COMPREPLY=($(compgen -W "$models" -- "$cur"))
    
    # Sort completions lexographically and remove leading colons
    COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
    __ltrim_colon_completions "$cur"
}

# Bind completion function to ollama command
complete -F _ollama_completions ollama
```

### Explanation:
1. **Command Validation**: Ensures that the current command being completed is `ollama` followed by a specific subcommand (like `list`, `serve`, etc.). If not, it returns an empty completion.
2. **Current Input Handling**: Uses `_get_comp_words_by_ref` to extract the current word (`cur`) and previous words for context.
3. **Model Fetching**: Checks if `ollama` is installed. If so, retrieves a list of models by running `ollama list`, stripping headers, and extracting the first column (model names).
4. **Completion Generation**: Uses `compgen` to generate possible completions based on the current input (`cur`) against the fetched model list.
5. **Sorting & Trimming**: Sorts the completions lexographically for readability and trims leading colons from any matches, improving usability when completing partial words (e.g., after a colon in `codellama:tab`).
6. **Completion Binding**: Registers the completion function with `complete`, associating it specifically with the `ollama` command.

### Notes:
- The placeholder `{{COMMAND}}` should be replaced with the actual subcommand (like `list`, `serve`, etc.) when implementing specific completions.
- This setup handles cases where no models are available or the `ollama` command isn't found, ensuring graceful fallbacks.

