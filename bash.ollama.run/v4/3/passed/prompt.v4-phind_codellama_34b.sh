# Bash completion for ollama run command
_ollama_run() 
{
    # Check if we are in correct context (second word must be 'run')
    if [ "${COMP_WORDS[1]}" != "run" ]; then
        return
    fi

    # Get the model names, skipping the header line using awk
    local models=$(ollama list | awk 'NR>1 {print $1}')
    
    # Filter based on current word being completed (last in COMP_WORDS)
    COMPREPLY=($(compgen -W "$models" -- "${COMP_WORDS[COMP_CWORD]}"))
}

# Register the completion function with the bash-completion system
complete -F _ollama_run ollama

