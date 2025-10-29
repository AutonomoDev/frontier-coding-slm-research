Here is the bash completion function:

```bash
_ollama_completions() {
    # Validate command
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }
    
    # Extract word info
    local cur prev
    _get_comp_words_by_ref -n : cur prev
    
    # Fetch models
    if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
    local models
    models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
    [[ -z "$models" ]] && { COMPREPLY=(); return; }
    
    # Generate completions
    COMPREPLY=($(compgen -W "$models" -- "$cur"))
    
    # Sort + trim
    COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
    __ltrim_colon_completions "$cur"
}
complete -F _ollama_completions ollama
```

This bash completion function works as follows:
- It first validates that the command is `ollama run`. If it's not, it returns immediately.
- Then it extracts the current and previous words from the input line with `_get_comp_words_by_ref -n :`.
- Next, it checks if the `ollama` command exists. If not, it returns. It fetches the list of models using `ollama list`, removes the first line (which is a header), and then only takes the first column with `awk '{print $1}'`. If there are no models, it returns.
- Then it generates completions using `compgen -W "$models" -- "$cur"`.
- After that, it sorts the completions with `printf "%s\n" "${COMPREPLY[@]}" | sort` and removes any colon prefixes with `__ltrim_colon_completions "$cur"`.
- Finally, it registers the completion function for the `ollama` command.

