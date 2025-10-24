# Simple Static Completion: The simplest form of completion using a static word list.
complete -W "option1 option2 option3" example_cmd

# Dynamic Completion with a Function:
# This function uses COMP_WORDS and COMP_CWORD to determine the current word being typed (`cur`).
# `compgen -W` filters the word list based on `cur`.
# The result is assigned to the COMPREPLY array.
# `complete -F _example_cmd_completions example_cmd` registers the function for `example_cmd`.

_example_cmd_completions() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local options="option1 option2 option3"
    COMPREPLY=( $(compgen -W "$options" -- "$cur") )
}
complete -F _example_cmd_completions example_cmd

# Context-Aware Completion:
# This function handles two levels of completion.
# Level 1: When the previous word is `app`, it completes subcommands "run list pull".
# Level 2: When the previous word is "run", it completes placeholder model names "model:small model:large".

_app_completions() {
    local cur prev
    _get_comp_words_by_ref -n : cur prev

    if [[ "$prev" == "app" ]]; then
        COMPREPLY=( $(compgen -W "run list pull" -- "$cur") )
    elif [[ "$prev" == "run" ]]; then
        COMPREPLY=( $(compgen -W "model:small model:large" -- "$cur") )
    fi
}
complete -F _app_completions app

# Advanced Completion for Non-Standard Word Breaks:
# This function dynamically completes model names by parsing the output of `ollama list`.
# It handles arguments containing colons correctly, ensuring completion works for models like "codellama:13b".
# The core logic saves COMP_WORDBREAKS, modifies it to remove the colon,
# uses `_get_comp_words_by_ref -n :` to correctly re-parse `cur` and `prev`, and then restores COMP_WORDBREAKS.

_ollama_completions() {
    # THE CORE PROBLEM: By default, Bash splits words on ':', so typing "codellama:"
    # makes the previous word "codellama" and the current word an empty string.
    # This breaks our context logic for completing model names.
    #
    # THE SOLUTION: We temporarily remove ':' from the word-breaking characters
    # and use a helper function to re-parse the command line with our new rule.

    local _old_wb=${COMP_WORDBREAKS}
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}
    _get_comp_words_by_ref -n : cur prev
    COMP_WORDBREAKS=${_old_wb}

    # Now, `cur` and `prev` are correct even when a colon is typed.
    # e.g., for `ollama run codellama:`, `prev` will be "run", not "codellama".
    if [[ "$prev" == "run" ]]; then
        local models=$(ollama list | awk 'NR>1 {print $1}')
        COMPREPLY=( $(compgen -W "$models" -- "$cur") )
    fi
}
complete -F _ollama_completions ollama

# Installation Instructions as Code Comments:
# To automatically source completion files from `~/.bash_completion.d/` within a user's `~/.bashrc`, add the following lines to your `.bashrc` file:

# if [ -d ~/.bash_completion.d ]; then
#     for f in ~/.bash_completion.d/*; do
#         source "$f"
#     done
# fi
