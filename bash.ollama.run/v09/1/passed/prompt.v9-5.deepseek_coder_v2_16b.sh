# Simple Static Completion
complete -F _example_cmd_completions example_cmd -o default -W "option1 option2 option3"

# Dynamic Completion with a Function
_example_cmd_completions() {
    local cur prev words cword
    _get_comp_words_by_ref -n :cur:prev:words:cword
    COMPREPLY=($(compgen -W "option1 option2 option3" -- "$cur"))
}
complete -F _example_cmd_completions example_cmd

# Context-Aware Completion
_app_completions() {
    local cur prev words cword
    _get_comp_words_by_ref -n :cur:prev:words:cword
    COMPREPLY=()
    if [[ "$prev" == "app" ]]; then
        compopt -o default
        COMPREPLY=( $(compgen -W "run list pull" -- "$cur") )
    elif [[ "$prev" == "run" ]]; then
        local models=$(ollama list | awk 'NR>1 {print $1}')
        COMPREPLY=($(compgen -W "$models" -- "$cur"))
    fi
}
complete -F _app_completions app

# Advanced Completion for Non-Standard Word Breaks
_ollama_completions() {
    local cur prev words cword
    # Save the original word break characters.
    local _old_wb=${COMP_WORDBREAKS}
    # Modify COMP_WORDBREAKS to remove the colon.
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}
    # Use the helper to re-parse and correctly set `cur` and `prev`.
    _get_comp_words_by_ref -n : cur prev
    # Restore the original word breaks immediately.
    COMP_WORDBREAKS=${_old_wb}
    COMPREPLY=()
    if [[ "$prev" == "run" ]]; then
        local models=$(ollama list | awk 'NR>1 {print $1}')
        COMPREPLY=( $(compgen -W "$models" -- "$cur") )
    fi
}
complete -F _ollama_completions ollama

# Installation Instructions as Code Comments
# Ensure this script is sourced from ~/.bash_completion.d/
# Add the following line to your ~/.bashrc:
# source /path/to/your/script/with/complete/ollama/commands.sh

