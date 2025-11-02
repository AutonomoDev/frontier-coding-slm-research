# Bash completion script for `ollama run <model>`
# This script assumes that ollama is in your PATH and executable.

_ollama_run_completion() {
    local cur prev words cword
    _init_completion -s || return  # Initialize bash-completion defaults

    if [[ ${cword} -eq 2 && "${prev}" == "run" ]]; then
        # Capture the full output of `ollama list` and store it in a variable
        local models=$(ollama list 2>/dev/null)
        
        if [ $? -eq 0 ]; then
            # Use prefix filtering to match against the current word being completed
            COMPREPLY=($(compgen -W "${models}" -- ${cur}))
            
            # Sort the matches alphabetically
            compopt -o nospace
            local IFS=$'\n'
            COMPREPLY=( $(printf "%s\n" "${COMPREPLY[@]}" | sort) )
        else
            # If `ollama list` fails, return silently without completions
            COMPREPLY=()
        fi
    fi
}

complete -F _ollama_run_completion ollama

# [[HUMAN COMMENTED-OUT]]
# ### Installation Instructions:
# To use this completion script, save it somewhere and ensure it is executable. Then, add the following line to your `.bashrc` file:
# 
# source /path/to/your/script/ollama-completion.sh
# 
# Replace `/path/to/your/script/` with the actual path where you saved the script. After updating your `.bashrc`, reload it by running `source ~/.bashrc`.
