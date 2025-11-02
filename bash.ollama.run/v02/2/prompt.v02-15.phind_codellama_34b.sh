# [[HUMAN COMMENTED-OUT]]
# Below is a script that satisfies all requirements:

_ollama_completion() {
    # Check if we are completing for `ollama run`
    if [ "$2" != "run" ]; then
        return
    fi

    # Invoke ollama list and store output in a variable, handling errors gracefully
    models=$(ollama list 2>/dev/null) || return

    # Get the current word being completed and strip trailing spaces (for prefix filtering)
    cur_word=${COMP_WORDS[COMP_CWORD]}

    # Generate completions using compgen based on current word, with filtered model names
    compreply=( $(compgen -W "${models}" -- "$cur_word") )

    # Sort and assign to COMPREPLY (built-in Bash completion variable)
    COMPREPLY=($(for w in "${compreply[@]}"; do echo "$w"; done | sort))
}
complete -F _ollama_completion ollama

# Installation/activation instructions:
# 1. Save the above script to a file, e.g., ~/.ollama_completion.sh
# 2. Add the following line to your .bashrc or equivalent:
#    source ~/.ollama_completion.sh
# 3. Reload your shell:
#    source ~/.bashrc

# [[HUMAN COMMENTED-OUT]]
# In this script, `_ollama_completion` is our bash-completion function for `ollama`. It first checks if we are completing for `ollama run`, then it runs `ollama list` and captures its output (handling errors gracefully). The current word being completed (`$2`) is used to filter the model names with `compgen -W`. Finally, the sorted completions are assigned to `COMPREPLY`.
# 
# To install the script:
# 1. Save it to a file in your home directory, e.g., `.ollama_completion.sh`.
# 2. Add `source ~/.ollama_completion.sh` to your `.bashrc` or equivalent.
# 3. Reload your shell with `source ~/.bashrc` or by opening a new terminal window.
