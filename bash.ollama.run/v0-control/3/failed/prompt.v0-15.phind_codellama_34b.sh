# [[HUMAN COMMENTED-OUT]]
# Here's a sample solution as a self-contained bash script for your problem. This script should be saved in a file, and you can source it in your shell to enable the `ollama run` completion functionality:

_ollama_run_completion() {
    local IFS=$'\n' # Split on newlines
    local response=($(_ollama_list_models))
    if [ $? -ne 0 ]; then
        return 1 # Return with error if _ollama_list_models failed.
    fi
    COMPREPLY=( $(compgen -W "${response[*]}" -- "$2") ) # Populate completions for the current word.
}

_ollama_list_models() {
    # Silence any errors from 'ollama list' and redirect stdout to a pipe.
    ollama list 2>/dev/null | while IFS= read -r line; do
        echo "${line##* }" # Extract the model name, assuming it's the last field on each line.
    done
}
complete -F _ollama_run_completion ollama run

# [[HUMAN COMMENTED-OUT]]
# To install this completion script, add the following to your `~/.bashrc` file:
# [[HUMAN COMMENTED-OUT]]
# source /path/to/your/script.sh
# [[HUMAN COMMENTED-OUT]]
# After adding this line and saving the `.bashrc`, remember to restart your terminal or run `source ~/.bashrc` in your current terminal for the changes to take effect.
