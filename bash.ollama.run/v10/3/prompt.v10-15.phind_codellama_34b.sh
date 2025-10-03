# [[HUMAN COMMENTED-OUT]]
#Here's a sample Bash completion script for `ollama run`:

# Bash completion for "ollama" command

# _ollama_completions() - This function is called by bash-completion framework
# to generate possible completions for the "ollama" command.
_ollama_completions() {
    # Save original word breaks and remove colon from them
    local old_wordbreaks=$COMP_WORDBREAKS
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}
    
    # Re-parse current and previous words, considering colons as part of the word
    local cur prev
    _get_comp_words_by_ref -n : cur prev
    
    # Restore original word breaks
    COMP_WORDBREAKS=$old_wordbreaks

    # Check if we are completing the "run" subcommand.
    if [[ $prev == "run" ]]; then
        # Retrieve model names from "ollama list", excluding header and first column.
        local models=$(ollama list | awk 'NR>1 {print $1}')

        # Generate completions using compgen with the extracted model names.
        COMPREPLY=($(compgen -W "$models" -- "$cur"))
    fi
}

# Register completion function for "ollama" command
complete -F _ollama_completions ollama

# [[HUMAN COMMENTED-OUT]]
#This script ensures that when you type `ollama run <TAB>`, it will dynamically complete model names retrieved from the `ollama list` command, even if those names contain colons.

