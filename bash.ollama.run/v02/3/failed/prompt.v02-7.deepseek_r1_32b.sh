# Thinking...
# Okay, I need to create a bash-completion function for the command 'ollama run <model>'. The goal is that when the user types 'ollama run' and presses tab, it should suggest available models. Let me go through each requirement step by step.
# 
# First, the trigger condition: the completion should only activate when the command is exactly 'ollama run'. So, in the completion function, I need to check if the second word (COMP_WORDS[1]) is 'run' and that we're completing after this, which would be at COMP_CWORD equal to 2.
# 
# Next, model retrieval. The instruction says not to pipe 'ollama list' directly into a while loop because it creates a subshell and loses the array data. So I should capture the output of 'ollama list' into a variable first. That way, I can process it safely without losing scope.
# 
# I'll run 'ollama list' in a way that if it fails or returns an error, we just exit silently. Using || exit is one approach to handle this gracefully.
# 
# Once I have the output, I need to split it into individual model names. Since the models are either one per line or separated by whitespace, I can replace newlines with spaces and then read each word into an array using read -ra.
# 
# Now, for prefix filtering. The current word being completed is in COMP_WORDS[COMP_CWORD]. I'll use compgen to filter the models that start with this word. Using -W for a list of possible candidates and -P to include the common prefix.
# 
# Sorting is required if there are multiple matches. So before assigning to COMPREPLY, I should sort the array alphabetically. The sort command can be used here.
# 
# I must ensure no external dependencies are used. Everything needs to be done with Bash built-ins. So, for splitting lines into words, using read -ra and manipulating strings with ${...} expansions.
# 
# Putting it all together: the function starts by checking if the first two commands are 'ollama' followed by 'run'. If so, it captures 'ollama list' output into a variable. Then splits this into an array. Uses compgen to filter based on the current word and sorts the results before assigning to COMPREPLY.
# 
# Finally, installation instructions: save the script in a file like ~/.bash_completions, source it in .bashrc, and then activate by sourcing or restarting the shell.
# ...done thinking.

# bash-completion function for ollama run
ollama_run_complete() {
    local cur prev words cword
    # Check if command is 'ollama run' and we're completing after 'run'
    if [[ $words[1] != "run" ]] || (( cword != 2 )); then
        return 0
    fi

    # Get available models by running ollama list
    local model_list=$(ollama list 2>/dev/null) || exit
    local -a models=()
    
    # Split output into an array (handles both line and space separated outputs)
    IFS=$'\n' read -ra models <<< "$model_list"
    for i in "${!models[@]}"; do
        if [[ ${models[$i]} =~ [[:space:]] ]]; then
            IFS=' ' read -ra submodels <<< "${models[$i]}"
            models=("${models[@]}" "${submodels[@]}")
            unset "models[$i]"
        fi
    done

    # Filter models by the current prefix
    local cur_word=${words[cword]}
    COMPREPLY=( $(compgen -W "${models[*]}" -- "$cur_word") )

    # Sort completions alphabetically if multiple matches
    if (( ${#COMPREPLY[@]} > 1 )); then
        IFS=$'\n' COMPREPLY=($(sort <<< "${COMPREPLY[*]}"))
        unset IFS
    fi
}

# Wire the completion function to 'ollama'
complete -F ollama_run_complete -o default ollama

# Installation instructions:
# 1. Save this script in your shell configuration directory (e.g., ~/.bash_completions)
# 2. Add the following line to your .bashrc:
#    source ~/.bash_completions
# 3. Activate immediately by running:
#    source ~/.bash_completions
