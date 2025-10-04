# ollama_run.bash

__ollama_models() {
    local cur prev words cword
    _init_completion -s || return

    if [[ "$prev" == "ollama" && ( "$cword" -eq 2 ) ]]; then
        COMPREPLY=($(compgen -W "$(ollama list | awk '{$1=$1};1' | cut -d' ' -f1)" -- "$cur"))
    fi
}

complete -F __ollama_models ollama

# [[HUMAN COMMENTED-OUT]]
# Installation snippet:
# To install the completion script, add the following line to your ~/.bashrc or equivalent
echo "source /path/to/your/ollama_run.bash" >> ~/.bashrc
# Then, reload your shell configuration
source ~/.bashrc
