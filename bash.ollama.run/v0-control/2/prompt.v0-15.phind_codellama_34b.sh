# This is an example of a Bash completion function for `ollama run <model>`
# Make sure to place this file in /etc/bash_completion.d or source it in your shell's RC file

_ollama_run() {
    # Extract model names from `ollama list` output
    local models
    if models=$(ollama list 2>/dev/null); then
        models=$(echo "$models" | awk 'NR>1 {print $1}') # Ignore header, take first column (model name)
    else
        return 1 # ollama list failed, so just silently stop trying to complete
    fi

    # Provide completions based on current word
    COMPREPLY+=( $(compgen -W "$models" -- "${COMP_WORDS[COMP_CWORD]}") )
}
complete -F _ollama_run ollama

# [[HUMAN COMMENTED-OUT]]
# To use this script:
# 
# 1. Save it as a file, e.g., `ollama-completion.sh`. 
# 2. Add the following line to your `.bashrc` or `.bash_profile`:
#     source /path/to/ollama-completion.sh
# 3. Restart your terminal or run `source ~/.bashrc` (or `~/.bash_profile`) to apply the changes.
# 
# After these steps, you should have working completion for the `ollama run <model>` command.
