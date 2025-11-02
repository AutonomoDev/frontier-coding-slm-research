Below is a bash completion script for the command `ollama run <model>` as you requested. It dynamically lists available models by parsing the output of `ollama list` without using any external dependencies. 

```bash
_ollama() {
    # Only complete if the word before the cursor starts with 'run'
    [[ ${COMP_WORDS[COMP_CWORD-1]} != run ]] && return
    
    local cur opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    
    # Get a list of models by running 'ollama list' and filtering the output.
    local models=$(ollama list 2>/dev/null)  # Silence errors
    
    # If ollama command fails (e.g., not found), exit gracefully.
    [[ $? -ne 0 ]] && return
    
    # Convert the model string to an array, splitting by newlines or spaces.
    local -a models_array=(${models//[[:space:]]\n/ })
    
    # Generate matches for the current word prefix.
    COMPREPLY=( $(compgen -W "${models_array[*]}" -- "$cur") )
}
complete -F _ollama ollama
```
To install this, you should:
1. Save it to a file (e.g., `/etc/bash_completion.d/ollama` on Linux or `~/.bash_completion`).
2. Ensure that the directory containing your bash completions is in Bash's `BASH_COMPLETION_USER_DIR` variable, which defaults to `~/.bash_completion.d` for most distributions. If not, you will need to set it: `export BASH_COMPLETION_USER_DIR=/etc/bash_completion.d`.
3. Source the new file (or restart your shell) to activate the completion function. You can do this by typing `source /etc/bash_completion.d/ollama` or `source ~/.bash_completion`, or simply starting a new shell session. 

