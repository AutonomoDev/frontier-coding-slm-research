```bash
# Bash completion for "ollama run <model>"
#
# This script depends only on built-in shell features and completes the `ollama run`
# command by dynamically listing available models from the output of `ollama list`.
#
# Installation & Activation:
# ----------------------------
# 1. Save this script as "ollama" in your bash_completion.d directory (e.g., /etc/bash_completion.d/).
# 2. Add the following line to your .bashrc or equivalent:
#    [ -f /path/to/bash_completion.d/ollama ] && source /path/to/bash_completion.d/ollama
# 3. Restart your terminal or run `source ~/.bashrc` (or equivalent) to activate.

_ollama_list_models() {
    # Store the output of 'ollama list' in a variable
    local models
    models=$(ollama list 2>/dev/null) || return 0  # Silently return on error

    # Populate COMPREPLY with filtered model names (by current word's prefix), sorted alphabetically
    COMPREPLY=($(compgen -W "$models" "${COMP_WORDS[COMP_CWORD]}"))
}

# Register the completion function for "ollama run"
complete -F _ollama_list_models ollama
```

