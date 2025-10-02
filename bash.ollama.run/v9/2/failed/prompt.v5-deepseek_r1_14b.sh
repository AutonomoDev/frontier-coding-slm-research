#Thinking...
#Alright, I need to create a Bash completion script for the `ollama run` command. The main issue is that model names like `codellama:13b` have colons, which Bash splits on by default, causing incorrect completions.
#
#First, I remember that the bash-completion framework has a function called `_get_comp_words_by_ref`. This function can reparse the words based on modified word break rules. So, the plan is to temporarily remove the colon from `COMP_WORDBREAKS` to prevent it from splitting the model names.
#
#I'll start by saving the original `COMP_WORDBREAKS` so I can restore it later. Then, I'll modify `COMP_WORDBREAKS` by removing any colons. Next, I'll use `_get_comp_words_by_ref -n :` to correctly parse `cur` and `prev`, ensuring that the colon in model names doesn't break them.
#
#After handling the word parsing, I need to check if the previous word is "run" because that's when we should offer completions. Then, I'll fetch the list of models using `ollama list | awk 'NR>1 {print $1}'` to extract just the model names.
#
#Finally, I'll generate completions using `compgen -W` with the fetched models and the current word. This way, when the user types `ollama run codellama:`, the completion script correctly recognizes that "run" is the previous command and provides the right model suggestions without splitting on the colon.
#
#I also need to make sure that the script only activates when the subcommand is `run` and doesn't interfere with other commands. So, I'll structure the function to check if the second word (after `ollama`) is `run` before proceeding with completions.
#...done thinking.

# Bash completion script for ollama run command
complete -F _ollama_completions ollama

_ollama_completions()
{
    # Save original word break characters and remove colon to prevent splitting on model colons
    local _old_wb=$COMP_WORDBREAKS
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}
    
    # Reparse words without treating colon as a word break
    _get_comp_words_by_ref -n : cur prev
    
    # Restore original word break characters to avoid side effects
    COMP_WORDBREAKS=$_old_wb

    # Only complete when the command is 'run'
    if [[ "$2" = "run" ]]; then
        local models=$(ollama list | awk 'NR>1 {print $1}')
        COMPREPLY=( $(compgen -W "$models" -- "$cur") )
    fi
}

