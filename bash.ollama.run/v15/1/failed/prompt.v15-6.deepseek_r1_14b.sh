# Bash completion script for `ollama run` command
complete -F _ollama_run_completions ollama

function _ollama_run_completions {
    # Save original word break settings and disable colon breaking
    local old_word_breaks="${COMP_WORDBREAKS}"
    COMP_WORDBREAKS="${COMP_WORDBREAKS//:}"  # Remove colon from word breaks
    
    # Reparse words with new word break settings
    _get_comp_words_by_ref -n : cur prev
    
    # Restore original word break settings
    COMP_WORDBREAKS="${old_word_breaks}"
    
    # Check if the command is `run`
    if [[ "${COMP_WORDS[1]}" == "run" ]]; then
        # Get model names from ollama list
        local models=$(ollama list | tail -n +2 | awk '{print $1}')
        
        # Generate completions for the current word with model names
        COMPREPLY=( $(compgen -P "$cur" -W "${models}") )
    fi
}
