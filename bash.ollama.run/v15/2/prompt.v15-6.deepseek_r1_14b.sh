#Thinking...
#Okay, I need to create a Bash completion script for the `ollama run` command. Let me think through how to approach this.
#
#First, the goal is to provide completions when the user types `ollama run` followed by part of a model name, especially handling those with colons like `codellama:13b`. 
#
#The main problem is that Bash splits words on colons by default. So when someone types `ollama run codellama:` and presses Tab, it won't work correctly because the colon breaks the word. I remember that modifying `COMP_WORDBREAKS` can help with this.
#
#I should start by writing a function called `_ollama_run_completions`. This function needs to be registered so that it's used when completing `ollama`. The registration command is `complete -F _ollama_run_completions ollama`, which I'll include at the end of my script.
#
#Next, the completion should only trigger for the `run` subcommand. So inside the function, I need to check if the second word in `COMP_WORDS` is exactly "run". That would be `[[ "${COMP_WORDS[1]}" == "run" ]]`. This ensures that we're completing after `ollama run`.
#
#Now, handling colons correctly is crucial. The steps are: save the original `COMP_WORDBREAKS`, remove the colon from it, re-parse the words with `_get_comp_words_by_ref`, and then restore `COMP_WORDBREAKS`. This has to happen before checking for the subcommand because otherwise, the word parsing might be incorrect.
#
#So in code terms, I'll save the original word breaks into a variable. Then set `COMP_WORDBREAKS` without colon. Re-parse `cur` and `prev` using `_get_comp_words_by_ref -n : cur prev`. After that, restore the original word breaks.
#
#After handling the colons, I need to get the list of models. The user mentioned that `ollama list` outputs model names in the first column. So I'll run `ollama list`, skip the header line, and extract the model names. For each line after the header, I can process it by cutting the first column.
#
#Then, using compgen, I'll generate the possible completions based on the parsed `cur` variable. The models should be passed as options to `compgen -P ' '` since they follow a space in the command line.
#
#Putting it all together: inside the function, handle word breaks, check for run subcommand, fetch model names dynamically, and generate completions with compgen.
#
#I also need to make sure that the script only completes when it's supposed to. So after extracting models, if the second word is not "run", return nothing.
#
#Wait, no. The structure should be: modify COMP_WORDBREAKS first, then check for subcommand, and proceed accordingly.
#
#Let me outline the steps:
#
#1. Check if the current command being completed is `ollama`. Probably always true because of the registration, but better to make sure.
#2. Get the words array with `read -A COMPREPLY`. Wait, no—I think I should parse the command line using `_get_comp_words_by_ref`.
#3. Save original word breaks.
#4. Remove colon from word breaks.
#5. Re-parse words with `-n :` because of colons in model names.
#6. Restore word breaks.
#
#Wait, perhaps I should use `_get_comp_words_by_ref -n cur prev` after modifying `COMP_WORDBREAKS`. But the way to do this is:
#
#- Save original COMP_WORDBREAKS.
#- Remove colon from it.
#- Run `_get_comp_words_by_ref -n : cur prev`.
#- Then proceed.
#
#Wait, perhaps I should capture the words correctly. The function is called when the user is trying to complete `ollama run <model>`. So inside `_ollama_run_completions`, after modifying word breaks, we can get the current and previous words properly.
#
#So in code:
#
#function _ollama_run_completions {
#    # Check if this is a completion for 'run'
#    # only trigger when second word is 'run'
#    # So first, need to parse the command correctly.
#    
#    # Save original word breaks
#    local saved_word_breaks=$COMP_WORDBREAKS
#    
#    # Remove colon from word breaks to handle model names with colons
#    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}
#    
#    # Reparse words without splitting on colon
#    _get_comp_words_by_ref -n : cur prev
#    
#    # Restore original word breaks
#    COMP_WORDBREAKS=$saved_word_breaks
#    
#    # Check if the second word is 'run'
#    if [[ "${COMP_WORDS[1]}" != "run" ]]; then
#        return 0
#    fi
#    
#    # Now, get model names from ollama list
#    local models=$(ollama list | tail -n +2 | cut -d$'\t' -f1)
#    
#    # Generate completions for each model that matches the current word
#    compgen -P ' ' -S '' -W "$models" -- $cur
#}
#
#Wait, but in the `_get_comp_words_by_ref` command, what does `-n :` do? It specifies that words are split only on spaces, not colons. So after modifying `COMP_WORDBREAKS`, this should correctly parse `codellama:13b` as a single word.
#
#Wait no, in the function, we first save the original word breaks, then remove colon, so now word breaks are without colon. Then, using `_get_comp_words_by_ref -n : cur prev` to get the words again, which should split only on spaces and not colons.
#
#But I think it's better to run `_get_comp_words_by_ref` after modifying `COMP_WORDBREAKS`, so that the current word (`cur`) is parsed correctly without splitting on colons.
#
#Then, if the second word is "run", proceed to get models.
#
#Next, extract model names. The output of `ollama list` has a header line, which we need to skip. So using `tail -n +2` skips the first line. Then, `cut -d$'\t' -f1` gets the first column, which is the model name.
#
#Finally, use `compgen` to generate possible completions based on the current word (`cur`). The `-P ' '` adds a space before each match, which is correct because after `run`, we have a space and then the model name. So `compgen -P ' ' ...`.
#
#I think that's all. Now, I need to write this as a function and register it.
#...done thinking.

# Bash completion script for ollama run command
complete -F _ollama_run_completions ollama

function _ollama_run_completions {
    # Save the original word break configuration
    local saved_word_breaks=$COMP_WORDBREAKS
    
    # Temporarily remove colon from word breaks to handle model names with colons
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}
    
    # Reparse words without splitting on colons
    _get_comp_words_by_ref -n : cur prev
    
    # Restore the original word break configuration
    COMP_WORDBREAKS=$saved_word_breaks
    
    # Only activate completion if the second word is exactly "run"
    if [[ "${COMP_WORDS[1]}" != "run" ]]; then
        return 0
    fi
    
    # Get list of models from ollama list command, skipping header line
    local models=$(ollama list | tail -n +2 | cut -d$'\t' -f1)
    
    # Generate possible completions for model names matching current word
    compgen -P ' ' -S '' -W "$models" -- $cur
}
