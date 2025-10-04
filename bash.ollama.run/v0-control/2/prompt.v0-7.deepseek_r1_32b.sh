#!/bin/bash

# [[HUMAN COMMENTED-OUT]]
# Thinking...
# Alright, I need to create a bash-completion function for the `ollama run` command that dynamically lists available models by parsing the output of `ollama list`. The user specified that I shouldn't use any external dependencies beyond what's typical in a POSIX/bash environment. So, no jq or other tools.
# 
# First, I should understand how `ollama list` outputs the model names. From the sample provided, it looks like each line starts with the model name, followed by ID, size, and modified date. The first row is a header: NAME ID SIZE MODIFIED. So, the actual model lines are from the second line onwards.
# 
# My goal is to extract just the model names from this output. Each model is separated into columns, so I can split each line into fields. The model name should be in the first field of each non-header line.
# 
# I'll need to write a bash function that captures the output of `ollama list`, processes it to extract the model names, and then provides them as completions when the user types `ollama run <TAB>`.
# 
# Here's how I can approach it:
# 
# 1. **Capture Output**: Run `ollama list` and capture its output. But I need to handle cases where the command might fail. So, I'll redirect stderr to /dev/null and check the exit status. If it fails, I won't proceed with completion.
# 
# 2. **Parse Lines**: Skip the header line (the first one). For each subsequent line, extract the first column which is the model name.
# 
# 3. **Completion Function**: Use bash's `compgen` to generate possible completions from the extracted model names and pass them back to the shell.
# 
# 4. **Installation Snippet**: Provide a way for the user to install this completion function, typically by adding it to their `.bashrc` or similar files.
# 
# Let me think about potential edge cases:
# 
# - If `ollama list` returns no models, the completion should do nothing.
# - Lines might have varying numbers of fields, but as long as the first field is the model name, it should work.
# - The output parsing needs to be robust against changes in the number of columns or additional information.
# 
# Testing this function would involve checking various scenarios: when `ollama list` is successful, when it fails, and ensuring that all model names are correctly captured and offered as completions.
# 
# I'll structure the script as follows:
# 
# - Define a function `_complete_ollama_run()` that handles the completion logic.
# - Use `local models` to store the parsed model names.
# - Use `sed` and `awk` to process the output, but ensure that these commands are available in a typical POSIX environment.
# 
# Wait, using `awk` might be more efficient. Alternatively, I can use `cut -d' ' -f1` to get the first field after skipping the header.
# 
# But since the output is tabular and may have spaces within fields (like model names), perhaps `awk` is better because it can handle any whitespace as field separators by default.
# 
# So, the processing steps would be:
# 
# - Run `ollama list`, capture stdout.
# - Check if the command was successful. If not, do nothing.
# - For each line after the first, extract the first field (model name).
# 
# Putting this into code:
# 
# Capture output and check exit status:
# bash
# if ! ollama list 2>/dev/null | { ... }; then return; fi
# 
# 
# Extract model names:
# bash
# models=$(ollama list 2>/dev/null | sed '1d' | awk '{print $1}')
# 
# Here, `sed '1d'` deletes the first line (header), and `awk '{print $1}'` prints the first field of each remaining line.
# 
# Then, use `compgen -W "$models" -- "$cur"` to generate completions based on the current word being typed (`$cur`).
# 
# I need to ensure that variables like `cur` are properly set in the completion function. In bash, when defining a completion function, it's standard to have access to `$cur`, which is the word being completed.
# 
# Putting it all together:
# 
# The function `_complete_ollama_run()` will check if there's a current word (`$cur`). If not, return early. Then extract models as described. Finally, generate completions using `compgen`.
# 
# Testing this script would involve:
# 
# 1. Running `ollama run <TAB>` and seeing all model names listed.
# 2. Typing part of a model name and pressing tab to see only matching models.
# 3. Ensuring that if `ollama list` fails, no completion is attempted.
# 
# I think this approach covers the requirements without relying on external dependencies beyond what's standard in bash environments. Now, I'll structure the script accordingly, including comments for clarity, and provide the installation snippet so users can easily add it to their shells.
# ...done thinking.

# Bash completion function for 'ollama run <model>'
# Lists available models by parsing output of `ollama list`
# Usage: Add this script to your bash completions directory or source it in .bashrc

_ollama_run() {
    local cur prev words cword
    if ! compgen -C "ollama" > /dev/null 2>&1; then
        return
    fi

    # Only complete model names for the 'run' command
    words=("${COMP_WORDS[@]}")
    cword=$COMP_CWORD
    local command=${words[1]}

    if [[ "$command" != "run" ]]; then
        return
    fi

    # Extract models from ollama list output, skipping headers and empty lines
    local models=$(ollama list 2>/dev/null | sed -n '1d;/^$/d;s/ .*//p')

    if [[ $? -ne 0 || -z "$models" ]]; then
        return
    fi

    # Generate possible completions
    compgen -W "$models" -- "${COMP_WORDS[$cword]}"
}

# Register completion function for 'ollama' command
complete -F _ollama_run ollama

# Installation snippet:
# Add the following lines to your .bashrc or source this script directly:

# To install, copy and paste these lines into your terminal:
# echo "source $(realpath $0)" >> ~/.bashrc && source ~/.bashrc
