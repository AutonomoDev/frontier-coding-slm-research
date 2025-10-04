#!/bin/bash

# Function to complete ollama run <model> command
_ollama_run_completion() {
    local cur prev words cword model_list
    _get_comp_words_by_ref -n : cur prev words cword
    
    # Check if we are completing the 'run' subcommand with a model name
    if [[ ${cword} -eq 2 && "${words[1]}" == "run" ]]; then
        # Capture the list of models from `ollama list` output, skipping header lines
        # Use `head -n +3` to skip the first two header lines and print only model names.
        if model_list=$(ollama list | head -n +3); then
            COMPREPLY=( $(compgen -W "$model_list" -- $cur) )
        fi
    fi
}

# Register the completion function for 'ollama run <model>'
complete -F _ollama_run_completion ollama

# [[HUMAN COMMENTED-OUT]]
# 
# ### Installation Instructions:
# 
# 1. Save the script above to a file, e.g., `ollama-completion.bash`.
# 
# 2. Add the following lines to your `.bashrc` or `.bash_profile` to source the completion script:

   # Load Ollama command completion
   if [[ -f /path/to/ollama-completion.bash ]]; then
       . /path/to/ollama-completion.bash
   fi

# [[HUMAN COMMENTED-OUT]]
# 
# 3. Replace `/path/to/ollama-completion.bash` with the actual path to your script file.
# 
# 4. Reload your shell configuration:

   source ~/.bashrc  # or source ~/.bash_profile

# [[HUMAN COMMENTED-OUT]]
# 
# This setup ensures that the `ollama run <model>` command has dynamic completion for available models based on the output of `ollama list`.
