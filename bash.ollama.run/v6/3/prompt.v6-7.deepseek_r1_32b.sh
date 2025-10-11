#!/usr/bin/env bash

# Thinking...
# Okay, so I need to create a Bash completion script for the `ollama run` command. The goal is to provide autocompletion suggestions for model names when a user types `ollama run ` and presses Tab. Let me break down what needs to be done.
# 
# First, I should understand how Bash completions work. They use functions that are triggered when certain commands are being completed. In this case, the function will be called `_ollama_run` and it should be bound to the `ollama` command with the `run` subcommand.
# 
# The core requirement is that the completion only activates for the word immediately following `run`. So, I need to check that the first word is `ollama` and the previous word is exactly `run`.
# 
# To get the list of models, I'll run `ollama list` and parse its output. The output has a header line starting with "NAME", followed by lines where each model's name is in the first column. So, I need to skip the header and extract only the names.
# 
# Using `cut -d$'\t' -f1` should get the first column correctly. But wait, sometimes models might have tabs or other issues? Probably not, since `ollama list` outputs a consistent format.
# 
# Next, I'll store these model names in an array. Then, when the user starts typing (like `llama run co<TAB>`), the script should filter this array to include only those starting with the current word (`cur`).
# 
# I must ensure that if there's no match, it doesn't suggest filenames. So, after filtering, I'll check if there are matches and set `COMPREPLY` accordingly.
# 
# Also, I need to handle cases where `_get_comp_words_by_ref` might not be available, so a fallback is necessary to set `cur` and `prev` manually from `COMP_WORDS` and `COMP_CWORD`.
# 
# Let me outline the steps:
# 
# 1. Check if the command starts with `ollama` and the previous word is `run`.
# 2. Run `ollama list`, parse it to get model names.
# 3. Extract only the first column, skipping the header.
# 4. Use these names as possible completions.
# 5. Filter them based on the current word being typed.
# 6. Ensure no duplicates by using `sort -u` if needed, but since `ollama list` shouldn't have duplicates, maybe it's not necessary here.
# 
# Wait, the user specified that the final suggestions must be unique, so perhaps I should include a step to remove duplicates just in case. So, after extracting the model names, I'll process them through `sort -u`.
# 
# Now, putting this into code:
# 
# - Start by checking if the command is correct.
# - Fetch the models with `ollama list`, cut the first column, skip the header using `tail -n +2`.
# - Read each line into an array.
# - If the current word is empty, suggest all models; else, filter them.
# 
# I should also make sure that the script doesn't cause any errors. For example, if `ollama list` fails, it shouldn't break the shell. So, perhaps wrap it in a command substitution and handle any exit codes gracefully.
# 
# Wait, but according to the requirements, I must parse the output of `ollama list`, so assuming it's reliable. But still, better to have error handling? Or just let it fail as per normal commands.
# 
# In terms of Bash syntax, using `_get_comp_words_by_ref` with a fallback is important. So, first try that function, then if it fails, set `cur` and `prev` manually.
# 
# Putting it all together, the script will:
# 
# - Check command structure.
# - Fetch models from `ollama list`.
# - Filter based on current input.
# - Set `COMPREPLY` with the filtered results or leave it empty.
# 
# Testing edge cases: when no models match, ensure nothing is suggested. When multiple matches exist, suggest all that fit.
# 
# I think I've covered all points. Now, translating this into the script.
# ...done thinking.

# This script provides Bash completion for the `ollama run` command.

# Define a function to handle completion specifically for 'run' subcommand
_ollama_run() {
    # Check if the previous word is exactly 'run'
    local cur prev words cword
    _get_comp_words_by_ref -n : cur prev words cword || \
        return 0

    # Only complete when the command starts with 'ollama run'
    if [[ ${words[0]} == ollama && ${prev} == "run" ]]; then
        # Fetch available models by running `ollama list`
        local models=$(ollama list 2>/dev/null | tail -n +2 | cut -d$'\t' -f1)

        # Read each model into an array
        COMPREPLY=()
        while IFS=$'\n' read -r model; do
            if [[ $model == ${cur}* ]]; then
                COMPREPLY+=("$model")
            fi
        done <<< "$models"

        # Sort and remove duplicates
        COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort -u))
    fi
}

# Bind the completion function to 'ollama run'
complete -o default -F _ollama_run ollama
