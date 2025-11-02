```bash
_ollama() {
    local cur prev words cword
    # Get all command line arguments, current word, previous word, etc.
    _get_comp_words_by_ref -n : cur prev words cword

    # Only trigger completion when the first argument is 'run' and we're completing after it (second position)
    if [[ $prev == "ollama" && $words[2] == "run" ]]; then
        local models=()
        # Capture all output from ollama list into a variable, split by whitespace.
        IFS=$'\n' read -d '' -r -a models < <(ollama list 2>/dev/null)
        # Check if command failed (models array empty), return early
        [[ ${#models[@]} -eq 0 ]] && return

        # Generate completions that match the current word's prefix.
        COMPREPLY=( $(compgen -W "${models[*]}" -- "$cur") )
    fi
}

complete -F _ollama ollama
```

### Installation/Activation Instructions:
1. **Save the script**: Copy the above function into your `~/.bashrc` file (or a custom completion script like `~/.bash_completion.d/ollama`).
2. **Source it immediately** for current session:  
   ```bash
   source ~/.bashrc
   ```
3. **Persistent activation**: Ensure `~/.bashrc` is sourced in future sessions (typically already done by default).

