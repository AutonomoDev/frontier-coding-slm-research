# Define bash completion function for ollama run command
_ollama() {
    local current_word=${COMP_WORDS[COMP_CWORD]} # Get currently completed word

    if [[ ${current_word} == "run" ]]; then
        local models=($(ollama list 2>/dev/null || echo)) # Run ollama list and capture output
                                                           # Any errors are discarded (2>/dev/null) to prevent breaking shell

        COMPREPLY=( $(compgen -W "${models[*]}" -- $current_word) ) # Filter models with compgen using current word as prefix
    fi
}

# Wire bash completion function to ollama command
complete -F _ollama ollama

# [[HUMAN COMMENTED-OUT]]
# **Installation/Activation:** Save the script in a file (e.g., `~/.ollama-completion.bash`), then add the following line to your shell's initialization file (e.g., `~/.bashrc` or `~/.zshrc`):
# [[HUMAN COMMENTED-OUT]]
# source ~/.ollama-completion.bash
# [[HUMAN COMMENTED-OUT]]
# Finally, reload your shell (or open a new one) to activate the changes.
