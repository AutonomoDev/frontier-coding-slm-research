#!/bin/bash

# Thinking...
# Okay, I need to create a bash-completion function for the `ollama run` command. The goal is to have it dynamically list available models by parsing the output of `ollama list`. Let me think through how to approach this.
# 
# First, I remember that bash completions use functions that populate the COMPREPLY array. So I'll start by defining a function, probably named `_ollama_run` since it's specific to the 'run' subcommand.
# 
# I need to check if the current command is `ollama run`. The COMP_WORDS array holds the command words, and COMP_CWORD tells me the index of the current word being completed. So I'll check if COMP_CWORD is 1, meaning we're completing after 'run'.
# 
# Next, I should capture the output of `ollama list`. But I have to be careful because if `ollama` isn't installed or fails, it could break the shell. I'll redirect both stdout and stderr to /dev/null using `2>/dev/null` to silence errors.
# 
# Once I get the models from `ollama list`, they might be separated by newlines or whitespace. So I can read them into an array with `readarray -t models < <(command)`. This will split on newlines, but if there are spaces, maybe another approach is needed. Alternatively, using `tr` to replace spaces with newlines and then process each line.
# 
# Wait, the user said models are one per line or separated by whitespace. So perhaps I can split the output into lines first, then handle any further splitting by spaces. But for simplicity, maybe just read all words as possible models. Hmm, but that might include extra stuff if the output has more information. The user's note says to assume `ollama list` prints model names one per line or whitespace-separated, so I can safely split into tokens.
# 
# So, after capturing the output, I'll split it into an array of models. Maybe using `tr ' ' '\n' | tr -s '\n'` to handle both cases.
# 
# Now, with the models in an array, I need to find those that match the current word prefix. The variable ${COMP_WORDS[COMP_CWORD]} gives the current word being completed. So I'll loop through each model and check if it starts with this prefix.
# 
# I should use a case-insensitive comparison because sometimes people type in different cases. Wait, but bash's string comparison is case-sensitive by default. To handle that, I can convert both the model and the prefix to lowercase before comparing. Alternatively, use `shopt -s nocasematch` temporarily if needed, but that might complicate things. Maybe just compare the lowercased versions.
# 
# Wait, no. Let me think: if the current word is 'll', and a model is 'llama2', I want it to match. So converting both to lowercase ensures case-insensitive matching. But in the output, the original casing should be preserved because models might have specific cases (like 'Llama2').
# 
# So, for each model in models:
# - Check if the current word prefix matches the start of the model name, case-insensitively.
# - If it does, add the model to COMPREPLY.
# 
# I'll loop through each model, check the condition, and collect the matching ones.
# 
# Putting this together:
# 
# 1. Define _ollama_run function.
# 2. Check if the command is 'ollama run' by verifying COMP_WORDS[0] is 'ollama' and COMP_CWORD is 1.
# 3. Get the output of `ollama list`, handle errors silently.
# 4. Split the output into an array of model names, handling both newlines and spaces.
# 5. Loop through each model, compare case-insensitively with the current prefix.
# 6. Collect matching models into COMPREPLY.
# 
# Wait, how to split the output? If `ollama list` outputs one per line, then reading with readarray -t is fine. But if it's space-separated, I need to split by spaces as well. So perhaps:
# 
# models=$(ollama list 2>/dev/null)
# if [ -z "$models" ]; then
#     return
# fi
# 
# # Split into an array, handling both cases
# readarray -t models <<< "$(echo $models | tr ' ' '\n')"
# 
# Alternatively, using tr to replace spaces with newlines and then read each line.
# 
# But perhaps a better approach is to split the output into words regardless of whether they're separated by spaces or newlines. So I can do something like:
# 
# models=$(ollama list 2>/dev/null | tr ' ' '\n' | tr -s '\n')
# 
# Then, read each line as a model. But that might include empty strings if there are multiple spaces or lines. So using readarray with a delimiter.
# 
# Alternatively, use:
# 
# mapfile -t models < <(ollama list 2>/dev/null | tr ' ' '\n' | grep -v '^$')
# 
# This way, any whitespace is converted to newlines, and then we filter out empty lines.
# 
# But perhaps it's simpler to read all the output into a string, split on any whitespace or newlines, and store as an array.
# 
# Wait, in bash, I can use:
# 
# models=( $(ollama list 2>/dev/null) )
# 
# This would automatically split the output into words based on whitespace, regardless of whether they were separated by spaces or newlines. So if `ollama list` outputs 'model1\nmodel2 model3', this will correctly create an array with 'model1', 'model2', 'model3'.
# 
# Yes, that seems efficient and handles both cases without needing tr.
# 
# So, in code:
# 
# models=( $(ollama list 2>/dev/null) )
# 
# But wait, what if `ollama list` outputs something like 'model1 model2\nmodel3'? The array would correctly be (model1 model2 model3).
# 
# Yes, that works.
# 
# Then, the current word is ${COMP_WORDS[COMP_CWORD]}.
# 
# For each model in models:
# 
# if [[ "$model" == "${prefix}"* ]]; then
# 
# But case-insensitive. So perhaps convert both to lowercase:
# 
# prefix_lower=$(echo "$prefix" | tr '[:upper:]' '[:lower:]')
# for model in "${models[@]}"; do
#     model_lower=$(echo "$model" | tr '[:upper:]' '[:lower:]')
#     if [[ "$model_lower" == "$prefix_lower"* ]]; then
#         COMPREPLY+=( "$model" )
#     fi
# done
# 
# Yes, that should handle case-insensitive matching.
# 
# Putting it all together:
# 
# function _ollama_run {
#     local prefix=${COMP_WORDS[COMP_CWORD]}
#     # Check if the current command is 'ollama run'
#     if [ "${COMP_WORDS[0]}" = "ollama" ] && [ "$COMP_CWORD" -eq 1 ]; then
#         # Get list of models, handle errors silently
#         models=( $(ollama list 2>/dev/null) )
#         if [ ${#models[@]} -eq 0 ]; then
#             return
#         fi
#         # Convert prefix to lowercase for case-insensitive comparison
#         local prefix_lower=$(echo "$prefix" | tr '[:upper:]' '[:lower:]')
#         COMPREPLY=()
#         for model in "${models[@]}"; do
#             local model_lower=$(echo "$model" | tr '[:upper:]' '[:lower:]')
#             if [[ "$model_lower" == "$prefix_lower"* ]]; then
#                 COMPREPLY+=( "$model" )
#             fi
#         done
#     fi
# }
# 
# Wait, but I should also check that the function is only triggered when the command is 'ollama run'. Because COMP_CWORD is 1 in that case.
# 
# But what if someone runs 'ollama run <TAB>', then COMP_WORDS would be ['ollama', 'run'], and COMP_CWORD is 2. Wait, no: in bash, when you type 'ollama run' and press tab after 'run ', the current word being completed is index 2, but since we're completing the arguments to 'run', which expects a model as the first argument.
# 
# Wait, perhaps I need to adjust the condition. Let me think about how bash handles command-line parsing.
# 
# When you type `ollama run <TAB>`, the COMP_WORDS would be ['ollama', 'run'], and COMP_CWORD is 2 (since it's zero-based), but wait no: in bash, the indices are from 0 to CWORD. So if you have 'ollama run' as two words, CWORD is 1 for 'run'. When you press tab after 'run ', the next word is being completed, so COMP_CWORD would be 2.
# 
# Wait, perhaps I'm misunderstanding. Let me check:
# 
# In bash, when completing after a command with subcommands, like `git commit`, the function needs to determine if it's the right context. For example, for `ollama run <model>`, when the user types 'ollama r' and hits tab, it completes 'run'. Then, when they type 'ollama run ' and hit tab, it should complete the model.
# 
# So in the completion function, we need to check if the previous word is 'run', i.e., COMP_WORDS[1] == 'run', and then suggest models as the next argument.
# 
# Wait, perhaps my initial approach was incorrect. Let me think again.
# 
# The current setup is:
# 
# if [ "${COMP_WORDS[0]}" = "ollama" ] && [ "$COMP_CWORD" -eq 1 ]; then
# 
# But when the user types 'ollama run <TAB>', COMP_CWORD would be 2, because the words are ['ollama', 'run'], and the next argument is being completed.
# 
# So perhaps I need to check if the command is 'ollama' followed by 'run', i.e., COMP_WORDS[0] == 'ollama' and (COMP_WORDS[1] == 'run' or COMP_CWORD is 1 when typing 'run').
# 
# Wait, maybe a better approach is:
# 
# We want to complete the model names only when the command starts with 'ollama run'.
# 
# So in the completion function, we can check if the current word being completed is after 'run'.
# 
# That is:
# 
# if [ "${COMP_WORDS[0]}" = "ollama" ] && [ "${COMP_WORDS[1]}" = "run" ]; then
# 
# But this would only trigger when the second word is 'run' and we're completing the third word.
# 
# Alternatively, perhaps a better way is to see if the command being run is 'ollama', and the current word is at position 2 (since COMP_CWORD starts from 0).
# 
# Wait, maybe I should consider all possible cases where 'run' is the subcommand, regardless of how many arguments have been provided.
# 
# Alternatively, perhaps a more robust way is to check that the command being run is 'ollama', and that the current word is the first argument after 'run'.
# 
# So, if COMP_CWORD == 2 (third word), then it's the model name. But what about when the user hasn't typed anything yet? For example, 'ollama run <TAB>'.
# 
# In that case, the words would be ['ollama', 'run'], and COMP_CWORD is 2 (the next word). So we need to trigger completion for models when the previous word is 'run'.
# 
# So in code:
# 
# if [ "${COMP_WORDS[0]}" = "ollama" ] && [ "${COMP_WORDS[1]}" = "run" ]; then
#     # get models and complete
# fi
# 
# But what if there are more words? For example, if someone types 'ollama run model1 arg', but that's beyond the scope since 'run' expects a single model.
# 
# So perhaps the condition should be:
# 
# if [ "${COMP_WORDS[0]}" = "ollama" ] && ( [ "$COMP_CWORD" -eq 2 ] || ([ "$COMP_CWORD" -ge 1 ] && [ "${COMP_WORDS[1]}" = "run" ]) ) ]
# 
# Hmm, maybe it's better to check if the current command is 'ollama run' regardless of the position. So:
# 
# if [[ ${COMP_WORDS[0]} == 'ollama' && ( ${COMP_CWORD} -eq 2 || (${COMP_CWORD} -ge 1 && ${COMP_WORDS[1]} == 'run') ) ]]; then
# 
# Wait, perhaps a simpler approach is to check that the first word is 'ollama', and either:
# 
# - The second word is 'run' and we're completing the third (model), or
# - We are in the process of completing the second word which is 'run'.
# 
# But this might complicate things. Alternatively, for simplicity, perhaps just capture all completions when the command starts with 'ollama run', regardless of position.
# 
# Wait, perhaps it's better to have the function trigger whenever the first word is 'ollama' and the current word being completed is after 'run'. So:
# 
# if [ "${COMP_WORDS[0]}" = "ollama" ] && [ "$COMP_CWORD" -ge 1 ]; then
#     if [ "${COMP_WORDS[1]}" = "run" ]; then
#         # complete model names
#     fi
# fi
# 
# But I'm not sure. Maybe the initial approach is sufficient, but perhaps I should adjust it to trigger when 'ollama run' is the command.
# 
# Alternatively, perhaps use a case statement:
# 
# case ${COMP_WORDS[0]} in
#     ollama)
#         if [ "$COMP_CWORD" -eq 1 ] && [ "${COMP_WORDS[1]}" = "run" ]; then
#             # complete models
#         fi
#         ;;
# esac
# 
# Wait, but this would only trigger when 'run' is the second word and we're completing after that. Hmm.
# 
# Alternatively, perhaps a better approach is to check if the command being completed starts with 'ollama run'.
# 
# So, in code:
# 
# if [ "${COMP_WORDS[0]}" = "ollama" ]; then
#     case ${COMP_CWORD} in
#         1)
#             # Completing 'run' itself
#             ;;
#         2)
#             # Completing after 'run', which is the model
#             # So get models and complete
#             ;;
#     esac
# fi
# 
# But perhaps that's overcomplicating. Maybe it's better to have a general approach where whenever 'ollama run' is the command, we trigger the completion.
# 
# Wait, perhaps I should look at examples of other bash completions. For example, `git` has a complex completion setup, but for our case, since it's a simple subcommand, perhaps the initial approach is sufficient.
# 
# Alternatively, perhaps using the following logic:
# 
# If the current command is 'ollama' and the previous word is 'run', then complete models.
# 
# So in code:
# 
# if [ "${COMP_WORDS[0]}" = "ollama" ] && [ "${COMP_WORDS[1]}" = "run" ]; then
#     # get models and complete
# fi
# 
# But this would only trigger when 'run' is the second word, which is correct because that's when we need to suggest models.
# 
# Wait, but what if the user hasn't typed anything after 'run'? For example, 'ollama run <TAB>'. Then, COMP_WORDS[2] doesn't exist yet. So in this case, the condition would still hold because COMP_CWORD is 2, and COMP_WORDS[1] is 'run'.
# 
# So perhaps the initial approach of checking if COMP_CWORD is 1 (which it isn't) is incorrect.
# 
# Wait, let me think again:
# 
# When the user types 'ollama run' and then presses tab, the words are ['ollama', 'run'], and COMP_CWORD is 2 because it's the next word to complete. So in this case, COMP_WORDS[1] is 'run', and we need to trigger the completion.
# 
# So the condition should be: if the first word is 'ollama' and the previous word (COMP_WORDS[1]) is 'run'.
# 
# Thus, in code:
# 
# if [ "${COMP_WORDS[0]}" = "ollama" ] && [ "${COMP_WORDS[1]}" = "run" ]; then
#     # get models and complete
# fi
# 
# This would correctly trigger when the user is completing after 'ollama run'.
# 
# But what if the user hasn't typed anything yet, like 'ollama <TAB>'. Then COMP_CWORD is 1, and the condition wouldn't hold. That's correct because we don't want to suggest models at that point.
# 
# So I think this condition is better.
# 
# Therefore, in the function:
# 
# function _ollama_run {
#     # Check if the current command starts with 'ollama run'
#     if [ "${COMP_WORDS[0]}" = "ollama" ] && [ "${COMP_WORDS[1]}" = "run" ]; then
#         local prefix=${COMP_WORDS[2]}
#         # Get list of models, handle errors silently
#         models=( $(ollama list 2>/dev/null) )
#         if [ ${#models[@]} -eq 0 ]; then
#             return
#         fi
#         # Convert prefix to lowercase for case-insensitive comparison
#         local prefix_lower=$(echo "$prefix" | tr '[:upper:]' '[:lower:]')
#         COMPREPLY=()
#         for model in "${models[@]}"; do
#             local model_lower=$(echo "$model" | tr '[:upper:]' '[:lower:]')
#             if [[ "$model_lower" == "$prefix_lower"* ]]; then
#                 COMPREPLY+=( "$model" )
#             fi
#         done
#     fi
# }
# 
# Wait, but what about when the user hasn't typed anything after 'run'? For example, 'ollama run <TAB>'. Then COMP_WORDS[2] doesn't exist, so prefix would be empty. In that case, we should list all models.
# 
# So perhaps I should handle that:
# 
# prefix=${COMP_WORDS[$COMP_CWORD]}
# if [ -z "$prefix" ]; then
#     # No prefix, suggest all models
# else
#     # Filter by prefix
# fi
# 
# Alternatively, in the code above, if COMP_CWORD is 2 and the word hasn't been typed yet, ${COMP_WORDS[2]} would be unset. So perhaps:
# 
# local prefix=${COMP_WORDS[$COMP_CWORD]:-''}
# 
# But in bash, accessing an array index that doesn't exist returns nothing, so we can set it to empty string.
# 
# So adjust the code:
# 
# function _ollama_run {
#     # Check if the current command starts with 'ollama run'
#     if [ "${COMP_WORDS[0]}" = "ollama" ] && [ "${COMP_WORDS[1]}" = "run" ]; then
#         local prefix=${COMP_WORDS[$COMP_CWORD]:-''}
#         # Get list of models, handle errors silently
#         models=( $(ollama list 2>/dev/null) )
#         if [ ${#models[@]} -eq 0 ]; then
#             return
#         fi
#         # Convert prefix to lowercase for case-insensitive comparison
#         local prefix_lower=$(echo "$prefix" | tr '[:upper:]' '[:lower:]')
#         COMPREPLY=()
#         for model in "${models[@]}"; do
#             local model_lower=$(echo "$model" | tr '[:upper:]' '[:lower:]')
#             if [[ "$model_lower" == "$prefix_lower"* ]]; then
#                 COMPREPLY+=( "$model" )
#             fi
#         done
#     fi
# }
# 
# This should handle both cases: when a prefix is provided and when it's empty.
# 
# Wait, but in the initial code I wrote earlier, I had 'ollama list 2>/dev/null' to avoid errors. But perhaps in some systems, 'ollama' doesn't have a 'list' command; maybe it's better to get the models via another method. Wait, no—assuming that 'ollama list' returns the available models.
# 
# But let me check: in the initial problem statement, the user didn't specify how to get the models, but perhaps for the purpose of this exercise, we can assume that 'ollama list' outputs the model names.
# 
# Thus, putting it all together:
# 
# - The function triggers when the first word is 'ollama' and the second word is 'run'.
# - It retrieves the prefix from the current word being completed.
# - Fetches the list of models via 'ollama list', ignoring any errors.
# - Converts both prefix and model names to lowercase for case-insensitive comparison.
# - Filters the models based on the prefix and sets COMPREPLY.
# 
# Thus, this should correctly provide the model completions after 'ollama run'.
# 
# But wait, I think I made a mistake earlier. The function is named _ollama_run, but in bash completion, functions are typically named _commandname, so perhaps it's better to name it _ollama or have a different approach.
# 
# Wait, actually, in the initial problem statement, the user provided a system message that seems to set up a chatbot for a specific task, not necessarily about writing a bash completion function. But perhaps I'm overcomplicating.
# 
# Alternatively, perhaps the initial code was correct but needed to be adjusted to handle the correct trigger condition.
# 
# So, integrating all this:
# 
# The final function should check if the command starts with 'ollama run' and then provide model completions based on the prefix.
# 
# Thus, the corrected function is as above.
# ...done thinking.

# [[HUMAN COMMENTED-OUT]]
# To solve this problem, we need to create a bash completion function that suggests available models when the user types `ollama run` followed by a space and presses the tab key. The function should fetch the list of models using the `ollama list` command and provide case-insensitive suggestions based on the prefix typed by the user.
# 
# ### Approach
# 1. **Trigger Condition**: The completion function should trigger only when the command starts with `ollama run`. This is checked by verifying that the first word is `ollama` and the second word is `run`.
# 2. **Retrieve Models**: Fetch the list of available models using the `ollama list` command, ignoring any errors.
# 3. **Case-Insensitive Comparison**: Convert both the prefix typed by the user and each model name to lowercase to ensure case-insensitive suggestions.
# 4. **Filter Models**: Filter the models based on the prefix and set the completions.
# 
# ### Solution Code

function _ollama_run {
    # Check if the command starts with 'ollama run'
    if [ "${COMP_WORDS[0]}" = "ollama" ] && [ "${COMP_WORDS[1]}" = "run" ]; then
        local prefix=${COMP_WORDS[$COMP_CWORD]:-''}
        # Fetch available models, ignoring errors
        local models=( $(ollama list 2>/dev/null) )
        if [ ${#models[@]} -eq 0 ]; then
            return
        fi
        # Convert prefix to lowercase for case-insensitive comparison
        local prefix_lower=$(echo "$prefix" | tr '[:upper:]' '[:lower:]')
        COMPREPLY=()
        for model in "${models[@]}"; do
            local model_lower=$(echo "$model" | tr '[:upper:]' '[:lower:]')
            if [[ "$model_lower" == "$prefix_lower"* ]]; then
                COMPREPLY+=( "$model" )
            fi
        done
    fi
}

# [[HUMAN COMMENTED-OUT]]
# ### Explanation
# 1. **Trigger Condition**: The function checks if the command being executed starts with `ollama run`. This ensures that model suggestions are only provided after typing `ollama run`.
# 2. **Retrieve Models**: The models are fetched using `ollama list`, and any errors during this process are ignored to prevent interruptions.
# 3. **Case-Insensitive Comparison**: Both the prefix (what the user has typed so far) and each model name are converted to lowercase to ensure that suggestions are case-insensitive.
# 4. **Filter Models**: The function filters the models based on the prefix and constructs the list of possible completions, which is then set using `COMPREPLY`.
# 
# This approach ensures that users receive accurate and case-insensitive suggestions for available models when working with the `ollama run` command.
