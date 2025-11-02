 ```bash
# Include this function in your ~/.bashrc or ~/.bash_profile to activate.
_ollama() {
    local cur prev words cword
    _init_completion || return

    if [[ "$prev" == "run" ]]; then
        COMPREPLY=()
        local -a models=($(ollama list 2>/dev/null)) # Get models and suppress errors.
        COMPREPLY=( $(compgen -W "${models[*]}" -- ${cur}) ) # Filter matching models.
    fi
}
complete -F _ollama ollama
```
To activate, add this script to your shell configuration (like `~/.bashrc` or `~/.bash_profile`) and then source the file:
```bash
$ source ~/.bashrc # or .bash_profile
```
Now, you can use tab completion for available models with `ollama run <Tab>`.

