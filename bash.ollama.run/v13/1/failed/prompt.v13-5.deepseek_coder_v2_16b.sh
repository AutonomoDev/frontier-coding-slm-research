 _completion_script() {
    local cur prev words cword
    COMPREPLY=()
    COMP_WORDS=("$@")
    COMP_CWORD=$cword
    compgen -W "$(ollama list | tail -n +2 | awk '{print $1}')" -- "$cur"
}

complete -F _completion_script ollama


