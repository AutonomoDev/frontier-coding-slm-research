#Thinking...
#Okay, I need to create a bash-completion function for the `ollama run` command that dynamically lists available models by parsing the output of `ollama list`. Let me think through how to approach this.
#
#First, I know that bash completion functions typically go into the `/etc/bash_completion.d/` directory or can be sourced directly. So my script will likely be a file in that directory.
#
#The main task is to parse the output of `ollama list`. From the sample output, each model name is on its own line and appears as the first word. For example, "codegemma:7b", "codellama:13b", etc. So I need to extract these names.
#
#I should capture the output of `ollama list` but redirect any errors to /dev/null to prevent issues if the command fails. Then, process each line to extract the model name.
#
#Using a while loop reading from a pipe would work. For each line in `ollama list`, I can split it into words and take the first word as the model name. But wait, what about the header? The first line is "NAME ID SIZE MODIFIED", which isn't a model. So I need to skip that.
#
#I'll start by reading the output line by line. The first line is the header, so I can ignore it. Then for each subsequent line, split into parts and take the first part as the model name.
#
#Alternatively, using `sed` to remove the header might be more efficient. For example, `ollama list 2>/dev/null | sed '1d'` would delete the first line.
#
#Once I have the list of models, I can complete the argument with these names. The completion function should take the current word being completed and suggest matching model names.
#
#Putting it all together, the function will be named `_ollama_run`, and it's triggered by the `OLLAMA_COMMAND` variable being set to 'run'. 
#
#I'll write a function that captures the output of `ollama list`, skips the first line, and for each remaining line, appends the model name to possible completions. Then, using `compgen -W "$models" -- "$cur"` will generate the completion options.
#
#Testing edge cases: what if `ollama list` returns nothing? The script should handle that gracefully without errors. Also, ensure that it's POSIX compliant and doesn't use any external dependencies beyond basic shell commands.
#
#Finally, I'll provide an installation snippet so the user can source the script or add it to their bash completion directory.
#...done thinking.

# Bash completion for ollama run command
_ollama_run() {
    local cur prev
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"

    # Get list of models from 'ollama list', skipping the header line and extracting first column
    local models=$(ollama list 2>/dev/null | sed -e '1d' -e 's/[[:space:]].*//')

    # Generate possible completions
    COMPREPLY=($(compgen -W "$models" -- "$cur"))

    return 0
}

# Register completion function
complete -F _ollama_run ollama run

# Installation:
# Save this script as /etc/bash_completion.d/ollama or source it directly in your .bashrc

# [[HUMAN COMMENTED-OUT]]
# This script provides tab-completion for `ollama run` commands by parsing the output of `ollama list`. It skips the header line, extracts model names from the first column, and uses them to generate completion suggestions. The solution is lightweight and POSIX-compliant.
