```bash
# Define a new completion function
_ollama() {
    # Only offer completions when invoking 'ollama run'
    if [ "${COMP_WORDS[0]}" = "ollama" ] && [ "${COMP_WORDS[1]}" = "run" ]; then
        # Capture the output of `ollama list` into a variable.
        # The '2>/dev/null' silences any errors from ollama list.
        local models="$(ollama list 2>/dev/null)"
        
        if [ $? -eq 0 ]; then # If ollama list succeeds...
            # Store the current word being completed into a variable.
            local cur=${COMP_WORDS[COMP_CWORD]}
            
            # Filter model names that match the prefix, sort them, and store in an array.
            # The "-o nospace" is used to avoid adding a space after completion (if desired).
            COMPREPLY=( $(compgen -W "$models" -- "$cur") )  
        fi
    fi
}

# Register the new completion function for 'ollama' commands.
complete -F _ollama ollama

```
To install and activate this script:
1. Save it to a file, e.g., `/etc/bash_completion.d/ollama`.
2. Source the bash completion script in your shell startup script (e.g., add `source /etc/bash_completion.d/ollama` to your `.bashrc`).
3. Start a new shell session or reload your current one with: `exec $SHELL` 

