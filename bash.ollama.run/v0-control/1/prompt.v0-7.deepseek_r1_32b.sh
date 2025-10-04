#!/bin/bash

# Thinking...
# Okay, I need to create a bash-completion function for the command `ollama run <model>`. The goal is to dynamically list available models by parsing the output of `ollama list`. Let me think about how to approach this.
# 
# First, I should understand what the user expects. They want that when they type `ollama run` followed by a space and then start typing a model name, bash should provide a list of possible models from the output of `ollama list`.
# 
# So, the completion function needs to capture the output of `ollama list`, extract the model names, and present them as suggestions.
# 
# Looking at the sample output of `ollama list`:
# 
# 
# NAME ID SIZE MODIFIED
# codegemma:7b 0c96700aaada 5.0 GB 12 days ago
# codellama:13b 9f438cb9cd58 7.4 GB 12 days ago
# ...
# 
# 
# Each line after the header has the model name as the first field. So, I need to extract the first word from each non-header line.
# 
# I'll start by writing a function that runs `ollama list`, reads its output, and processes it.
# 
# But wait, what if `ollama list` isn't available or fails? The completion shouldn't break bash. So, I should handle errors gracefully, maybe by silencing any output from the command.
# 
# In bash completions, functions are typically defined in `/etc/bash_completion.d/` or similar directories. So, my script will create a function and then set it up for completion.
# 
# Here's how I can structure it:
# 
# 1. Define a function `ollama_run_model() { ... }`.
# 2. Inside the function, run `ollama list` and capture its output.
# 3. Use `awk` to process the output: skip the header line (starting with 'NAME'), then extract the first field of each remaining line.
# 4. The extracted model names will be the possible completions.
# 
# I should also consider that if `ollama list` fails, it shouldn't cause an error in bash. So, I'll redirect both stdout and stderr to `/dev/null` or just ignore errors.
# 
# Putting it together:
# 
# - Use `compgen -W "$( ... )" -- "$cur"` to generate the possible completions.
# - The command substitution inside `$()` will run `ollama list`, process it with `awk`, and get the model names.
# 
# Wait, but how does bash handle the output? Each line from `ollama list` after the first is processed by `awk '{print $1}'`.
# 
# So, the command becomes:
# 
# `compgen -W "$( ollama list 2>/dev/null | awk 'NR>1 {print $1}' )" -- "$cur"`
# 
# Then, I'll complete the current word with these options.
# 
# I also need to set up the completion for `run`, so that when the user types `ollama run ...`, it triggers this function.
# 
# Putting all together, the function will be added as a completion definition for `ollama` command's `run` subcommand.
# 
# Testing edge cases: what if there are no models? The list would be empty, and nothing would be suggested. That's acceptable.
# 
# What about case sensitivity? By default, bash completions are case-sensitive, which is fine unless the user wants case-insensitive, but that's beyond this scope.
# 
# I think this covers the requirements. Now, I'll write the script with these steps.
# ...done thinking.

# Bash completion for 'ollama run' command
_ollama_run() {
    local cur prev words cword
    _init_completion || return

    # Only trigger completion when the second argument is being entered (model name)
    if [[ $cword -ne 2 ]]; then
        return
    fi

    # Extract model names from 'ollama list' output, skipping header line and errors
    local models=$(ollama list 2>/dev/null | awk '$1 != "NAME" {print $1}')

    # Generate completions based on extracted models
    COMPREPLY=($(compgen -W "$models" -- "$cur"))
}

# Register the completion function for 'run' subcommand of 'ollama'
complete -F _ollama_run ollama run

# [[HUMAN COMMENTED-OUT]]
# Installation Instructions

# To use this completion, save it to a file (e.g., `~/.bash_completion`), then add:

# source ~/.bash_completion

# to your `~/.bashrc` or equivalent shell configuration file.
