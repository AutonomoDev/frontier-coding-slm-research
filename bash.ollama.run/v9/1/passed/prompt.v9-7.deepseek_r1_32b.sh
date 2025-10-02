#Thinking...
#Alright, let me break down how I approached creating the Bash completion script for the `ollama run` command.
#
#First, I recognized that the main challenge was handling model names with colons, which Bash treats as word separators. This means that when a user types something like `codellama:`, Bash splits it into two words, causing issues in determining the correct context for completion.
#
#I started by understanding the structure of Bash programmable completions. I knew that using `complete -F` allows me to define functions that generate completions dynamically. So, I needed a function `_ollama_completions` that would handle this logic.
#
#Next, I considered how to retrieve the model names. The `ollama list` command provides the necessary output, so I used `awk` to extract just the first column containing the model names. This gives me a dynamic list of models each time the completion is triggered.
#
#But the core issue was handling colons correctly. By default, Bash splits words on certain characters, including colons. To fix this, I needed to temporarily modify how Bash parses the command line. I found that saving `COMP_WORDBREAKS`, removing the colon from it, and then using `_get_comp_words_by_ref -n :` would allow me to re-parse the current and previous words without splitting on colons.
#
#After modifying `COMP_WORDBREAKS`, I used `_get_comp_words_by_ref` with `-n :` to correctly set `cur` (current word) and `prev` (previous word). This ensures that when a colon is part of a model name, it's treated as a single unit, so the context remains intact.
#
#Once the parsing was fixed, I checked if the previous word after `ollama run` was "run" to trigger the completion. Then, I used `compgen -W "$models"` with the current word to filter and generate the possible completions.
#
#Finally, I made sure to restore `COMP_WORDBREAKS` immediately after re-parsing to prevent any side effects on other parts of the shell session.
#
#I also included installation instructions as comments in the script so users know how to integrate it into their environment. This involved sourcing the completion file from `~/.bashrc`.
#
#Throughout this process, I focused on ensuring that each step was clear and commented properly, providing both functionality and understanding for anyone using or modifying the script.
#...done thinking.

# Simple static completion example
complete -F _example_cmd_completions example_cmd  # Registers completion function for 'example_cmd'

# Example of a simple completion function
_example_cmd_completions() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    COMPREPLY=($(compgen -W "option1 option2 option3" -- "$cur"))
}

# Dynamic completion with context-awareness
_complete_app() {
    local cur prev
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    if [[ ${prev} == "app" ]]; then
        COMPREPLY=($(compgen -W "run list pull" -- "$cur"))
    elif [[ ${prev} == "run" ]]; then
        COMPREPLY=($(compgen -W "model:small model:large" -- "$cur"))
    fi
}
complete -F _complete_app app

# Advanced completion for ollama command
_ollama_completions() {
    local cur prev
    # Get the current and previous words being typed
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    if [[ "$prev" == "run" ]]; then
        # Extract model names from 'ollama list' output
        local models=$(ollama list | awk 'NR>1 {print $1}')
        COMPREPLY=( $(compgen -W "$models" -- "$cur") )
    fi
}
complete -F _ollama_completions ollama

# Advanced completion handling colons correctly
_ollama_run_completion() {
    local cur prev
    # Save original word break characters and remove colon
    local old_wb="$COMP_WORDBREAKS"
    COMP_WORDBREAKS="${old_wb//:/}"
    
    # Reparse command line with updated word breaks
    _get_comp_words_by_ref -n : cur prev
    
    # Restore original word breaks
    COMP_WORDBREAKS="$old_wb"

    if [[ "$prev" == "run" ]]; then
        local models=$(ollama list | awk 'NR>1 {print $1}')
        COMPREPLY=( $(compgen -W "$models" -- "$cur") )
    fi
}
complete -F _ollama_run_completion ollama

# Installation instructions as code comments:
# Add this to your ~/.bashrc to automatically load completions from ~/.bash_completion.d/
# for f in ~/.bash_completion.d/*; do source "$f"; done
