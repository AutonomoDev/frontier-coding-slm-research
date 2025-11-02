# [[HUMAN COMMENTED-OUT]]
# Here is a bash-completion function for `ollama run <model>` that dynamically lists available models by parsing the output of `ollama list` without using any external dependencies:

_ollama() {
    local IFS=$'\n'
    COMPREPLY=($(ollama list 2>/dev/null | grep -i "^${COMP_WORDS[COMP_CWORD]}"))
}
complete -F _ollama ollama

# [[HUMAN COMMENTED-OUT]]
# To install and activate the completion function, add the above script to your bash startup file (e.g., `~/.bashrc`), then source it to apply the changes:
#
#source ~/.bashrc
#
# [[HUMAN COMMENTED-OUT]]
# Note: The completion function relies on the `ollama list` command printing model names one per line or separated by whitespace when run with no formatting flags. If your version of ollama uses a different output format, you may need to adjust the script accordingly.
