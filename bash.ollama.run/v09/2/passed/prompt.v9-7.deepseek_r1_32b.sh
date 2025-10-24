#Thinking...
#Okay, I need to create a Bash completion script for the `ollama run` command. The main goal is to dynamically complete model names from `ollama list`, especially handling those with colons like "codellama:13b".
#
#First, I remember that by default, Bash uses certain characters as word breakers, and colon is one of them. This causes issues because when a user types something like "codellama:", the shell splits it into two words, making completion tricky.
#
#So, the plan is to temporarily remove the colon from the word-breaking characters. I'll need to save the original `COMP_WORDBREAKS`, modify it by removing colons, then use `_get_comp_words_by_ref` with `-n :` to correctly parse the current and previous words without splitting on colons.
#
#I should extract model names using `ollama list | awk 'NR>1 {print $1}'`. This skips the header and grabs the first column, which contains the model names.
#
#In the completion function, I'll check if the previous word is "run" to ensure we're only completing after that subcommand. Then, generate possible completions using `compgen -W` with the models list.
#
#Finally, I need to restore `COMP_WORDBREAKS` right after parsing to prevent side effects elsewhere. The script should be registered with `complete -F _ollama_completions ollama`.
#
#I'll structure the code with comments explaining each step, ensuring clarity for anyone reading it later.
#...done thinking.

# Bash completion script for ollama run command model name completion

_ollama_completions() {
    # Save original word break characters
    local _old_wb=${COMP_WORDBREAKS}
    
    # Temporarily remove colon from word breaks to handle names like codellama:13b
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}
    
    # Re-parse command line with updated word break settings
    _get_comp_words_by_ref -n : cur prev
    
    # Restore original word break characters immediately
    COMP_WORDBREAKS=$_old_wb
    
    # Check if previous word is 'run' to trigger model name completion
    if [[ "$prev" == "run" ]]; then
        # Extract list of available models from ollama list output
        local models=$(ollama list | awk 'NR>1 {print $1}')
        
        # Generate completions based on current input
        COMPREPLY=( $(compgen -W "$models" -- "$cur") )
    fi
}

# Register the completion function for ollama command
complete -F _ollama_completions ollama
