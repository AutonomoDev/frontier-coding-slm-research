Below is a bash completion function for `ollama run <model>` which dynamically lists available models from the output of `ollama list`. The function tries to populate the COMPREPLY array with model names that match the current prefix. If `ollama list` fails, it will return without giving any completions.

```bash
_ollama_completions() {
    # Only attempt to autocomplete if ollama command exists
    type ollama >/dev/null 2>&1 || return
    
    local cur words cword list
    _init_completion -n :='run' || return

    # Use COMPREPLY array to get the autocompletion results, using 'ollama list' as source
    mapfile -t list < <(ollama list 2>/dev/null)
    
    # Iterate through model names and add them to the completion list if they start with cur
    for model in "${list[@]}"; do
        [[ $model == $cur* ]] && COMPREPLY+=("$model")
    done
}
complete -F _ollama_completions ollama
```

To use the script: 
1. Save it to a file, e.g., `/etc/bash_completion.d/ollama` (path can be different based on your system).
2. Then source the file in your current shell session with `source /etc/bash_completion.d/ollama` command or add it to your shell's configuration file to make the change permanent (like `~/.bashrc` for bash).
3. After that, start a new shell session or manually run `bind 'set show-all-if-ambiguous on'` and `source /etc/bash_completion` in current shell to take effect. 

