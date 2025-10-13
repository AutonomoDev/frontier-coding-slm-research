#!/usr/bin/env bash

# Thinking...
# Okay, so I need to create a Bash completion script for the `ollama run` command. The main goal is to make sure that when someone types `ollama run <TAB>`, it suggests the available models correctly, even if those model names have colons in them, like `codellama:13b`.
# 
# First, I remember that by default, Bash uses certain characters as word breaks, and one of them is a colon. This means that when someone types something with a colon, Bash might not complete it properly because it stops at the colon. So to handle this, I need to adjust the `COMP_WORDBREAKS` variable temporarily.
# 
# The script needs to be a function, let's call it `_ollama_run_completions`, and it should register itself as the completion handler for the `ollama` command. The registration is done with `complete -F _ollama_run_completions ollama`.
# 
# Now, the tricky part is making sure that this completion only activates when the subcommand is `run`. So I need to check if the second word in the command line (since the first word is `ollama`) is exactly "run". That's why I'll use `[[ "${COMP_WORDS[1]}" == "run" ]]`.
# 
# But before doing any checks, I have to handle the colons. The plan is:
# 
# 1. Save the original `COMP_WORDBREAKS` so I can restore it later.
# 2. Remove the colon from `COMP_WORDBREAKS`.
# 3. Use `_get_comp_words_by_ref -n : cur prev` to re-parse the current and previous words, which will allow Bash to recognize colons as part of the word.
# 4. Restore the original `COMP_WORDBREAKS` right after this.
# 
# Next, I need to fetch the list of models from `ollama list`. The output includes a header line, so I have to skip that. I'll pipe the output through `awk` to extract just the first column starting from the second line. That gives me all the model names.
# 
# Then, using `compgen`, I generate possible completions based on these model names and assign them to `COMPREPLY`.
# 
# Putting it all together, the function will:
# 
# - Check if the subcommand is `run`.
# - Fetch the models.
# - Generate completions.
# - Return with the appropriate exit code.
# 
# I also need to make sure that the script is self-contained and doesn't have any extra text outside of the comments. So I'll structure everything neatly within the function and ensure it's properly registered.
# 
# Finally, I'll test this script in my mind: when I type `ollama run codellam<TAB>`, it should correctly suggest `codellama:13b` without stopping at the colon. The temporary modification of `COMP_WORDBREAKS` ensures that the colon is treated as part of the word, allowing for correct completion.
# ...done thinking.

_ollama_run_completions() {
    # Save original word breaks and remove colon from them
    local saved_wordbreaks="$COMP_WORDBREAKS"
    COMP_WORDBREAKS=${COMP_WORDBREAKS/":"/}
    
    # Reparse the current and previous words with updated word breaks
    _get_comp_words_by_ref -n : cur prev
    
    # Restore original word breaks immediately after re-parsing
    COMP_WORDBREAKS="$saved_wordbreaks"
    
    # Only trigger completion for 'run' subcommand
    if [[ "${COMP_WORDS[1]}" != "run" ]]; then
        return 0
    fi
    
    # Fetch and parse model names from ollama list
    local models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}')
    
    # Generate completions using compgen
    COMPREPLY=( $(compgen -W "$models" -- "$cur") )
}

# Register the completion function with bash
complete -F _ollama_run_completions ollama
