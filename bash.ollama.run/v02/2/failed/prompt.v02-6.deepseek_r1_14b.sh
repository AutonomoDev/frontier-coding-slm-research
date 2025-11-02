#!/bin/bash

# Thinking...
# Alright, I need to create a bash-completion script for the command `ollama run <model>`. The goal is to dynamically list available models by parsing the output of `ollama list`. Let me break down the requirements and figure out how to approach this.
#
# First, the trigger condition: the completion should only happen when the user is typing `ollama run` and is at the point where they're entering the model name. So, I'll need to check if the current command is `ollama` and the previous word is `run`. That means using `COMP_WORDS[1]` to see if it's `run`.
#
# Next, retrieving the models. The user specified that I shouldn't pipe `ollama list` directly into a loop because it creates a subshell and loses arrays. So, I'll capture the output of `ollama list` into a variable. But wait, how does `ollama list` format its output? It can either print model names one per line or separated by whitespace. Hmm, handling both cases might be tricky.
#
# If `ollama list` outputs each model on a new line, I can split the variable by newlines. If it's separated by whitespace (which could include spaces or tabs), I'll need to split on any whitespace, but that might cause issues if model names contain spaces. But perhaps for simplicity, we'll assume that models are either newline-separated or space-separated without special characters.
#
# So, in the script, after capturing the output into `models_output`, I can split it using `tr '\n' ' '` to handle newlines and then split by spaces. Alternatively, maybe just splitting on any whitespace with `read -rA` would work if we use a while loop. Wait, but the user said not to pipe directly into a while loop because of subshells. So storing it in a variable first is better.
#
# Once I have the models in an array, I need to filter them based on the current word being completed, which is `COMP_WORDS[COMP_CWORD-1]` (since we're completing after `run`). Let's call this `current_word`.
#
# I'll use `compgen -P "$current_word"` to generate possible completions that start with `current_word`. Alternatively, I can loop through the models and check if each starts with the current word.
#
# Then, if there are multiple matches, they need to be sorted alphabetically. So after filtering, I'll sort the array.
#
# If `ollama list` fails, the script should return without any completions. So I'll need to handle errors when capturing the output—check if `models_output` is empty or if `ollama list` returns a non-zero exit code.
#
# Putting it all together, here's how I can structure the function:
#
# 1. Check if the command starts with `ollama run`.
# 2. Capture the output of `ollama list` into a variable.
# 3. Split the variable into an array of models.
# 4. Filter the array to find models starting with the current word.
# 5. Sort the filtered array alphabetically.
# 6. Populate `COMPREPLY` with the sorted models or do nothing if there's an error.
#
# For splitting the output, I'll use `tr '\n' ' '` to replace newlines with spaces and then split on spaces using `read -rA`. But wait, what if a model name has a space? That could be problematic. However, assuming that model names don't contain spaces or are properly quoted, this might work. Alternatively, I could process each line individually by splitting on newlines first.
#
# Another approach is to read the output line by line and add each model to an array:
#
# ```
# models=()
# while IFS= read -r line; do
#     models+=("$line")
# done < <(ollama list)
# ```
#
# But this uses a process substitution, which might be considered a subshell. The user said not to pipe directly into loops because of subshells and array loss. So using a variable instead:
#
# Capture the output:
## models_output=$(ollama list 2>/dev/null)
# if [ $? -ne 0 ]; then
#     return
# fi
#
# # Split into models, assuming each model is on its own line or separated by whitespace.
# # This part might need adjustment if model names can have spaces.
# models=($(echo "$models_output" | tr '\n' ' '))
# ```
#
# But this would split both newlines and any whitespace, which isn't ideal. Maybe it's better to first check if the output is one per line or not.
#
# Alternatively, I can read each line as a model:
#
# ```
# models=()
# while IFS= read -r line; do
#     models+=("$line")
# done < <(printf '%s\n' "$models_output")
# ```
#
# This way, each model is treated correctly even if they have spaces. But again, the process substitution might be an issue.
#
# Wait, no—because we're capturing `models_output` as a variable first, and then processing it without external tools. So using a while loop after assigning to a variable should avoid subshells for the purpose of array handling.
#
# But in bash, when you use `read` in a loop like that, it's not a subshell; it's just reading from a string or file descriptor.
#
# So perhaps the code would be:
#
# ```
# models_output=$(ollama list 2>/dev/null)
# if [ $? -ne 0 ]; then
#     return
# fi
#
# models=()
# while IFS= read -r line; do
#     models+=("$line")
# done <<< "$models_output"
##
# That way, we're not using any external tools and correctly capturing each model.
#
# Then, filter the models based on `current_word`:
#
## filtered_models=()
# for model in "${models[@]}"; do
#     if [[ $model == "$current_word"* ]]; then
#         filtered_models+=("$model")
#     fi
# done
#
# # Sort the filtered models alphabetically
# if [ ${#filtered_models[@]} -gt 0 ]; then
#     IFS=$'\n' sorted_models=($(sort <<<"${filtered_models[*]}"))
#     unset IFS
#     COMPREPLY=("${sorted_models[@]}")
# fi
# ```
#
# Putting it all together, the function would look something like this:
#
# ```
# _ollama_run_complete() {
#     # Check if we're completing after 'run'
#     if [ "${COMP_WORDS[1]}" != "run" ]; then
#         return
#     fi
#
#     current_word=${COMP_WORDS[COMP_CWORD-1]}
#     models_output=$(ollama list 2>/dev/null)
#     if [ $? -ne 0 ]; then
#         return
#     fi
#
#     models=()
#     while IFS= read -r line; do
#         models+=("$line")
#     done <<< "$models_output"
#
#     filtered_models=()
#     for model in "${models[@]}"; do
#         if [[ $model == "$current_word"* ]]; then
#             filtered_models+=("$model")
#         fi
#     done
#
#     # Sort the models alphabetically
#     IFS=$'\n' sorted_models=($(sort <<<"${filtered_models[*]}"))
#     unset IFS
#
#     COMPREPLY=("${sorted_models[@]}")
# }
# complete -F _ollama_run_complete ollama
# ```
#
# Wait, but in the `complete` command, how is the function wired? It should be `-F` for a function. So yes, that's correct.
#
# I also need to handle cases where `ollama list` might output nothing or have errors, so returning early if it fails.
#
# Additionally, I should make sure that `current_word` is correctly set. Since we're completing after `run`, the word being completed is the model name, so `COMP_CWORD-1` would be the position of `run`, but wait, no—the words are like `ollama`, `run`, and then the next word is the model. So when completing, `COMP_CWORD` is 2 (0-based?), or maybe I'm mixing up zero and one-based indices.
#
# Wait, in bash, `COMP_CWORD` is the index of the current word being completed. For example, for the command `ollama run <cursor>`, the words are [0]=ollama, [1]=run, and [2] is the cursor position. So when completing, `COMP_CWORD` is 2, so the previous word is at 1, which is 'run'. But I think I need to get the current word being completed, which would be the model name. Wait, no—the command line is `ollama run <model>`, so when the user is typing after 'run', the words array up to now would be [0]=ollama, [1]=run, and the next word is [2]. So the current word being completed is at position 2.
#
# But in this case, we want to trigger completion only when the command starts with `ollama run`, regardless of how many words have been entered. Wait no—the function should only provide completions when the user is entering the model after 'run'. So perhaps checking if the previous word is 'run' would be better.
#
# So in the function, check if the second word (index 1) is 'run', and that the command starts with 'ollama'.
#
# Alternatively, using `if [[ ${COMP_WORDS[0]} = ollama && ${COMP_WORDS[1]} = run ]]` but wait, this might not account for cases where more words are present. For example, if the user types `ollama run m`, we need to complete models.
#
# Wait, perhaps a better approach is to check that the command starts with 'ollama run' and that the next word is being completed. So:
#
# If the previous word (at position COMP_CWORD -1) is 'run', then we provide completions for models.
#
# So in code:
#
# if [[ ${COMP_WORDS[COMP_CWORD-1]} == "run" ]]; then
#     # proceed to complete models
# else
#     return
# fi
#
# But wait, what if the user has already entered more words after 'run'? For example, `ollama run gpt model`. In that case, we shouldn't offer completions because they've already passed the model name.
#
# Hmm, perhaps I should only trigger when the word being completed is the first argument after 'run'. So the structure would be: if the command starts with 'ollama run' and the current position is right after 'run', then provide model completions.
#
# Alternatively, in the function, we can check that the previous word is 'run' and that it's not an option (since options come before arguments).
#
# But this might complicate things. For simplicity, perhaps just checking if the command starts with 'ollama run' and the current position is after 'run'.
#
# Wait, maybe using `if [[ ${COMP_WORDS[1]} == "run" ]]` would suffice because when you're completing after 'run', that's the second word.
#
# But I'm not entirely sure about the indices. Let me think: for the command `ollama run <cursor>`, COMP_WORDS is ["ollama", "run"], and COMP_CWORD is 2 (assuming zero-based, no—it might be one-based). Wait, in bash, COMP_CWORD is zero-based? Or is it the position where completion is happening. Let me check: when you're typing `ollama run m`, the words array would have ollama at index 0, run at 1, and m (incomplete) at 2. So COMP_CWORD is 2.
#
# So to trigger only when the command is 'ollama run', I need to make sure that the word being completed is after 'run'.
#
# Thus, in the function:
#
# if [[ ${COMP_WORDS[1]} == "run" ]]; then
#     # proceed
# fi
#
# But wait, this would also trigger if the user has more words after 'run'. For example, `ollama run gpt4 model`, which might not be intended. But perhaps that's acceptable because the user is trying to complete a model name.
#
# Alternatively, maybe it's better to check that the command starts with 'ollama run' and that the current position is immediately after 'run'.
#
# So, the function should only activate when the previous word is 'run', meaning the user has just typed 'ollama run' and is now entering the model name. So in code:
#
# if [[ ${COMP_WORDS[COMP_CWORD - 1]} == "run" ]]; then
#     # proceed to complete models
# fi
#
# Yes, that makes sense.
#
# So putting it all together, the function would be:
#
# _ollama_run_complete() {
#     # Check if we're completing after 'run'
#     if [[ ${COMP_WORDS[COMP_CWORD - 1]} != "run" ]]; then
#         return
#     fi
#
#     current_word=${COMP_WORDS[COMP_CWORD]}
#     models_output=$(ollama list 2>/dev/null)
#     if [ $? -ne 0 ]; then
#         return
#     fi
#
#     # Split the output into an array of model names
#     models=()
#     while IFS= read -r line; do
#         models+=("$line")
#     done <<< "$models_output"
#
#     # Filter models starting with current_word
#     filtered_models=()
#     for model in "${models[@]}"; do
#         if [[ $model == "$current_word"* ]]; then
#             filtered_models+=("$model")
#         fi
#     done
#
#     # Sort the filtered models alphabetically
#     IFS=$'\n' sorted_models=($(sort <<<"${filtered_models[*]}"))
#     unset IFS
#
#     COMPREPLY=("${sorted_models[@]}")
# }
#
# complete -F _ollama_run_complete ollama
#
# Wait, but in the `complete` command, how do we wire it to trigger only when completing after 'run'? Because by default, the function will be called for any completion on 'ollama', which isn't desired.
#
# Ah, right. So I need to make sure that the function is only triggered under specific conditions.
#
# Alternatively, perhaps using `complete -o default` or other options. But maybe a better approach is to have the function itself determine whether to provide completions based on the context.
#
# So in the function, we check if the previous word is 'run', and if not, return early.
#
# Yes, that's what I did earlier.
#
# Testing this script would be important to ensure it works correctly. For example:
#
# - When typing `ollama run m`, it should list all models starting with 'm'.
# - If `ollama list` fails, no completions are offered.
# - Models are sorted alphabetically when multiple matches exist.
#
# I think that covers all the requirements. Now, I'll write the final script as per the user's instructions.
# ...done thinking.

_ollama_run_complete() {
    # Only complete if previous word is "run"
    if [[ ${COMP_WORDS[COMP_CWORD - 1]} != "run" ]]; then
        return
    fi

    current_word=$(_get_current_word)
    models_output=$(ollama list 2>/dev/null)

    # Check if ollama list failed or output was empty
    if [ $? -ne 0 ] || [ "${models_output}" == "" ]; then
        return
    fi

    # Split into individual model names, preserving spaces in model names
    models=()
    while IFS= read -r line; do
        models+=("$line")
    done <<< "$models_output"

    # Filter and sort the models
    filtered_models=()
    for model in "${models[@]}"; do
        if [[ $model == "$current_word"* ]]; then
            filtered_models+=("$model")
        fi
    done

    IFS=$'\n' sorted_models=($(sort <<<"${filtered_models[*]}"))
    unset IFS

    COMPREPLY=("${sorted_models[@]}")
}

# Function to safely get the current word being completed
_get_current_word() {
    # Using printf to handle empty words and word extraction correctly
    printf '%s\n' "${COMP_WORDS[COMP_CWORD]}" | sed 's/^\(.\)/&,/' | cut -d',' -f2
}

complete -F _ollama_run_complete ollama

# [[HUMAN COMMENTED-OUT]]
# To activate, save this script to your shell configuration file (e.g., .bashrc or .zshrc) and source it.
