# Bash completion function for 'ollama run <model>'
_ollama_run_completion() {
    local cur prev words cword

    # Read current context of the shell input
    _get_comp_words_by_ref -n : cur prev words cword

    # Only complete after "run" subcommand, i.e., ollama run <Tab>
    if [[ ${#words[@]} -lt 3 || "${words[1]}" != "run" ]]; then
        return 0
    fi

    # Get the current prefix for completion
    local prefix="${cur}"

    # Fetch available models by calling 'ollama list' and handling errors gracefully
    local models=$(command ollama list 2>/dev/null)
    
    if [[ $? -ne 0 ]]; then
        return 0
    fi

    # Split the output into an array of model names, accounting for whitespace or newline separation
    mapfile -t model_array < <(printf '%s\n' "${models}" | tr ' ' '\n')

    # Populate COMPREPLY with matching models that start with the current prefix
    COMPREPLY=( $(compgen -W "${model_array[*]}" -- "$cur") )

    return 0
}

# Register the completion function for 'ollama run'
complete -F _ollama_run_completion ollama

# [[HUMAN COMMENTED-OUT]]
# ### Installation Instructions
# [[HUMAN COMMENTED-OUT]]
# 1. Save the above script to a file, e.g., `~/.bash_completion.d/ollama.bash`.
# [[HUMAN COMMENTED-OUT]]
# 2. Source this script in your `.bashrc` or equivalent shell configuration file:
# [[HUMAN COMMENTED-OUT]]
## [[HUMAN COMMENTED-OUT]]
#    # Add the following line to .bashrc if not already present
# [[HUMAN COMMENTED-OUT]]
#    for f in ~/.bash_completion.d/*.bash; do source "$f"; done
# [[HUMAN COMMENTED-OUT]]
#    ```
# [[HUMAN COMMENTED-OUT]]
# 3. Reload your shell configuration to activate completions immediately:
# [[HUMAN COMMENTED-OUT]]
#    ```bash
# [[HUMAN COMMENTED-OUT]]
#    source ~/.bashrc
# [[HUMAN COMMENTED-OUT]]
#    ```
# [[HUMAN COMMENTED-OUT]]
# This setup assumes you are using a typical Bash environment and that `.bash_completion` is properly configured to load scripts from `~/.bash_completion.d/`. Adjust the path as necessary for other setups.
