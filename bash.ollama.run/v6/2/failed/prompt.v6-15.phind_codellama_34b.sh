# Bash completion for 'ollama run' command

_ollama_run_completion() {
    local cur prev opts
    _get_comp_words_by_ref -n : cur prev

    # Targeted Triggering
    if [ "$prev" != "run" ]; then
        return 0
    fi

    # Getting the model names from 'ollama list' output
    opts=$(ollama list --quiet --no-trunc | awk 'NR>1 && $1 !~ /^<none>$/ {print $1}')
    
    # Precise Parsing and filtering models based on current word
    COMPREPLY=($(compgen -W "${opts}" -- "$cur"))

    return 0
}
complete -F _ollama_run_completion ollama

