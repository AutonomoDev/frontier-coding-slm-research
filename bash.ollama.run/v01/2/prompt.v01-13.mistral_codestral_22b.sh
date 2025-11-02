 ```bash
# Add this function to your ~/.bashrc or ~/.bash_profile
_ollama_run() {
    local current="${COMP_WORDS[COMP_CWORD]}"
    local models=($(ollama list 2>/dev/null)) || return 0
    COMPREPLY=( $(compgen -W "${models[@]}" -- "$current") )
}
complete -F _ollama_run ollama-run

# To activate immediately, use: source ~/.bashrc or . ~/.bash_profile
   ```

Installation: Add the `_ollama_run()` function to your shell initialization file (e.g., `~/.bashrc`, `~/.zshrc`) and then reload that file with either `source ~/.bashrc` or `. ~/.bashrc`. Alternatively, you can log out and log back in for the changes to take effect.

