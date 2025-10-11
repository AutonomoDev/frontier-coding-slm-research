#!/usr/bin/env bash

#Thinking...
#Okay, so I need to create a bash-completion function for the `ollama run` command that dynamically lists available models. The models are obtained by parsing the output of `ollama list`. 
#
#First, I should understand how `ollama list` works. The user provided a sample output which shows that each line starts with a model name, followed by an ID, size, and modified date. The model names are like "codegemma:7b", "codellama:13b", etc.
#
#The goal is to make the bash-completion script read this output and extract just the model names to suggest when the user types `ollama run`.
#
#I know that in bash completion, I need to write a function that gets called when the user presses tab. The function should print out possible completions based on some logic.
#
#So, the steps are:
#
#1. When the user types `ollama run` and hits tab, the shell calls the completion function.
#2. In this function, I'll execute `ollama list` to get the model information.
#3. Parse the output of `ollama list` to extract only the model names.
#4. Generate possible completions for the command line.
#
#Let me think about how to parse the output. The sample shows that each line starts with the model name, which is the first field. So, I can split each line into fields and take the first one as the model name.
#
#But wait, what if `ollama list` outputs in a different format? Well, according to the user's note, it prints model names one per line or separated by whitespace without any formatting flags, so we can assume that each line has at least the model name as the first word.
#
#So, in the bash function, I'll redirect the output of `ollama list` into a variable. Then, for each line in this variable, split into words and take the first word as the model.
#
#I should also handle any errors when running `ollama list`, but since we're just providing completions, it's better to fail silently so that the shell doesn't break. So, I'll redirect stderr to /dev/null.
#
#Putting it all together:
#
#- The completion function will be named `_ollama_run`.
#- It should check if the second argument (since `ollama run` is two parts: command and model) is being completed.
#- Run `ollama list` in a subshell, capture its output.
#- Split each line into words, take the first word as the model name.
#- Generate possible completions for the shell.
#
#I should also test if this function works correctly. For example, when I type `ollama run`, pressing tab should show all available models. If I type part of a model name, it should only show the matching ones.
#
#I need to make sure that the script is self-contained and doesn't use any external dependencies beyond what's in POSIX or bash. So, no jq or other tools—just using `awk` or string manipulation in bash.
#
#Wait, another approach: Instead of parsing each line as a word, maybe it's better to extract the first field from each line using `cut`. For example, `ollama list | cut -d ' ' -f 1`. But looking at the sample output, the model names have colons and numbers, so they might contain spaces if not properly quoted. Hmm, but in the sample, it's clear that the first field is the model name without spaces because each line starts with the model.
#
#Wait no, actually, looking at the sample output:
#
#The columns are NAME, ID, SIZE, MODIFIED. So each line is tab-separated? Or space-separated?
#
#In the user's sample, the first line after headers is "codegemma:7b 0c96700aaada 5.0 GB 12 days ago". So it seems like each field is separated by a space.
#
#But when parsing, taking the first word with `cut -d ' ' -f 1` would correctly get the model name in this case.
#
#Alternatively, using `awk '{print $1}'` to extract the first field. That might be more reliable because `cut` could have issues if fields are separated by multiple spaces or tabs.
#
#So perhaps using `ollama list | awk '{print $1}'` is better.
#
#Thus, the completion function would capture this output and generate the possible completions for the second argument of `ollama run`.
#
#Putting it all together in a bash script:
#
#The function `_ollama_run` will check if the number of words is sufficient and if the last word starts with 'run'. Then, it runs `ollama list`, extracts model names, and generates completions.
#
#I should also handle cases where the output isn't as expected, but since we're failing gracefully, any errors would be silent.
#
#So, the final script will define this function and source it in the shell.
#...done thinking.

# [[HUMAN COMMENTED-OUT]]
# To create a bash-completion function for `ollama run`, we'll parse `ollama list` to extract model names. Here's how the solution is structured:
# 
# 1. **Function Definition**: The `_ollama_run` function handles completion for the `run` command.
# 2. **Check Context**: It ensures the command context matches `ollama run`.
# 3. **Capture Models**: Runs `ollama list`, extracts the first field of each line as model names.
# 4. **Generate Completions**: Prints model names to enable tab-completion.

# bash completion script for ollama run <model>
complete -F _ollama_run ollama

_ollama_run()
{
    # Check if we're completing the second word (after 'run')
    if [[ ${#COMP_WORDS[@]} -le 1 ]]; then
        return
    fi

    local prev=${COMP_WORDS[0]}
    local cur=${COMP_WORDS[1]}

    # Only complete if the command is 'ollama' and the previous argument is 'run'
    if [[ "$prev" != "run" ]]; then
        return
    fi

    # Get models from ollama list, extract first field (model name) of each line
    local models=$(ollama list | awk '{print $1}')

    # Generate completions for the model part of 'ollama run <model>'
    COMPREPLY=( $(compgen -P "$cur" -- <<< "$models") )
}

# [[HUMAN COMMENTED-OUT]]
# **Installation**:
# To use this completion, add it to your shell initialization file (e.g., `.bashrc` or `.zshrc`):

complete -F _ollama_run ollama

# [[HUMAN COMMENTED-OUT]]
# This script ensures that after typing `ollama run`, pressing Tab will display available models from the output of `ollama list`.
