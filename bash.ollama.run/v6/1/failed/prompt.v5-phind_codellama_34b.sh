# Bash completion for ollama CLI tool

_ollama_list() {
    # Get model names from 'ollama list' command, skip header line
    local models
    models="$(ollama list 2>/dev/null | sed -n '2,$p' | cut -d' ' -f1)"

    COMPREPLY=($(compgen -W "$models" -- "$cur"))
}

_ollama() {
    # Check whether the current word is not 'run', if so, return immediately
    [[ "${COMP_WORDS[COMP_CWORD]}" != "run" ]] && return

    # Obtain the previous word (subcommand) and first word (command group)
    local prev="${COMP_WORDS[COMP_CWORD-1]}"
    local first="${COMP_WORDS[1]}"

    # Targeted Triggering: Only activate for 'ollama run'
    if [[ "$prev" != "run" || "$first" != "ollama" ]]; then
        return
    fi

    _ollama_list
}

complete -F _ollama ollama

