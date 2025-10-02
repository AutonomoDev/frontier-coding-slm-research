# Simple Static Completion
complete -W "option1 option2 option3" example_cmd

# Dynamic Completion with a Function (Step 2)
_example_cmd_completions() {
    # Get the current word being completed and previous word
    local cur prev words cword
    _get_comp_words_by_ref -n : cur prev words cword
    
    # Static list of completions
    local options="option1 option2 option3"
    
    # Use compgen to filter based on $cur and set COMPREPLY
    COMPREPLY=( $(compgen -W "$options" -- "$cur") )
}
complete -F _example_cmd_completions example_cmd

# Context-Aware Completion (Step 3)
_app_completions() {
    local cur prev cmd
    _get_comp_words_by_ref -n : cur prev
    
    # Handle first level: subcommands after 'app'
    if [[ $cword -eq 1 ]]; then
        COMPREPLY=( $(compgen -W "run list pull" -- "$cur") )
        return
    fi
    
    # Handle second level: models after 'app run'
    cmd="${words[0]}"
    if [[ "$prev" == "$cmd run" || ( "$cword" -eq 2 && "${words[cword-1]}" == "run" ) ]]; then
        local models="model:small model:large"
        COMPREPLY=( $(compgen -W "$models" -- "$cur") )
    fi
}
complete -F _app_completions app

# Advanced Completion for Non-Standard Word Breaks (Step 4)
_ollama_completions() {
    local cur prev words cword model_list IFS=$'\n' # Preserve newlines in output
    
    # Use helper function to parse current command line, ensuring colons are not word breaks
    if [[ -z "$cur" ]]; then
        _get_comp_words_by_ref -n : cur prev
    else
        local old_wb=$COMP_WORDBREAKS
        COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}
        _get_comp_words_by_ref -n : cur prev words cword
        COMP_WORDBREAKS=$old_wb
    fi
    
    # Extract model names from 'ollama list' (skip header)
    model_list=($(ollama list | awk 'NR>1 {print $1}'))
    
    # Complete models after 'run'
    if [[ "$prev" == "run" ]]; then
        COMPREPLY=( $(compgen -W "${model_list[*]}" -- "$cur") )
    fi
}
complete -F _ollama_completions ollama

# Installation Instructions (Step 5)
# Add the following lines to your ~/.bashrc to automatically load completions from ~/.bash_completion.d/
if [[ -d ~/.bash_completion.d ]]; then
    for f in ~/.bash_completion.d/*.sh; do
        source "$f"
    done
fi

# Save this file as ollama-completion.sh, place it under ~/.bash_completion.d/, and ensure your shell reloads the .bashrc.
