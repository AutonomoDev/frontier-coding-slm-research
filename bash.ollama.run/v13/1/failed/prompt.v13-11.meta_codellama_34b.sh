# [[HUMAN COMMENTED-OUT]]
#Here is a corrected version of the Bash completion script for the `ollama` command, with only the condition check changed:

_ollama() {
    local cur=${COMP_WORDS[2]}
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && return 0
    COMPREPLY=($(compgen -W "$(ollama list --output-format="%NAME %ID %SIZE %MODIFIED")" -- $cur))
}
complete -F _ollama ollama

