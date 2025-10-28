```bash
# Function to handle completions for `ollama run`
_ollama_completions() {
  # Check if the command is `ollama run` and the current word is the second argument
  [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return 0; }
  [[ $COMP_CWORD -ne 2 ]] && return 0;

  # Handle colons in the completion
  local cur prev
  if type _get_comp_words_by_ref &>/dev/null; then
    _get_comp_words_by_ref -n : cur prev
  else
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
  fi

  # Parse the list of models from `ollama list`
  local models=()
  if command -v ollama &>/dev/null; then
    models=($(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}'))
  fi

  # Sort the models to ensure consistent completion order
  IFS=$'\n' models=($(sort <<<"${models[*]}")); unset IFS

  # Generate completions using compgen
  COMPREPLY=( $(compgen -W "${models[*]}" -- "$cur") )

  # Fix colons in the completion results
  if type __ltrim_colon_completions &>/dev/null; then
    __ltrim_colon_completions "$cur"
  fi
}

# Register the completion function for `ollama`
complete -F _ollama_completions ollama
```

### Explanation:
1. **Index Check**: Ensures the script only activates for `ollama run`.
2. **COMP_CWORD Check**: Ensures the script only runs when the second argument is being completed.
3. **Colons Handling**: Uses `_get_comp_words_by_ref -n :` to handle colons correctly.
4. **Parsing Models**: Parses the output of `ollama list` using `tail` and `awk`.
5. **Sorting Models**: Sorts the models to ensure consistent completion order.
6. **Completions**: Uses `compgen -W` to generate completions without manual loops or filters.
7. **Fix Colons**: Calls `__ltrim_colon_completions` to handle colons correctly in the completion results.
8. **Registration**: Registers the completion function for `ollama`.

