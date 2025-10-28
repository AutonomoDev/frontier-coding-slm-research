Here's a bash completion script for `ollama run`:

```bash
_ollama_completions() {
    # Check if we are in the correct mode
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return 0; }
    [[ $COMP_CWORD -ne 2 ]] && return 0

    # Handle colons
    local cur prev
    if type _get_comp_words_by_ref &>/dev/null; then
        _get_comp_words_by_ref -n : cur prev
    else
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # Parse models from 'ollama list'
    local models=()
    if command -v ollama &>/dev/null; then
        models=($(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}'))
    fi

    # Generate completions
    IFS=$'\n' COMPREPLY=( $(compgen -W "${models[*]}" -- "$cur") )
    if type __ltrim_colon_completions &>/dev/null; then
        __ltrim_colon_completions "$cur"
    fi
}
complete -F _ollama_completions ollama
```

This script should work as follows:
- Only activate for `ollama run`
- Handle colons in model names (e.g., `codellama:13b`)
- Parse the models from the output of `ollama list` correctly
- Complete only the `<model>` argument after `ollama run`

