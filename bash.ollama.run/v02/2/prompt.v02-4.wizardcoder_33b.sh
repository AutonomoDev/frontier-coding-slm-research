# [[HUMAN COMMENTED-OUT]]
# Here's a bash completion script for `ollama run <model>`, as per your requirements:

# This is the function that will be invoked by BashCompletion when completing 'ollama run'.
_ollama() {
    local cur prev models
    COMPREPLY=()  # Array storing possible completions
    cur=${COMP_WORDS[COMP_CWORD]}  # The word currently being completed
    prev=${COMP_WORDS[COMP_CWORD-1]}  # The word preceding the current word

    # We only want to offer completions when the command is 'ollama run' and the user is completing after 'run'.
    if [ "${prev}" = "run" ]; then
        # Invoke 'ollama list', capture its full output into a variable, and prevent it from being parsed by the subshell.
        # DANGEROUS CODE FOUND!!
        echo "DANGEROUS CODE FOUND!!"
        # local models_raw=$(strace -f ollama list 2>&1) || return 0
        
        # We only keep lines with model names, discarding any error messages or other extraneous text.
        # while IFS= read -r line; do
        #     if echo "$line" | grep -q '^[a-zA-Z_]\+'; then
        #         models+=("$line")
        #     fi
        # done <<< "$models_raw"
        
        # Use compgen to get a list of model names that match the prefix ($cur), sorted alphabetically.
        # COMPREPLY=( $(compgen -W '${models[@]}' -- "$cur") )
    fi
}

# Wire the function to ollama using the '-F' option of bashcomplete.
# complete -F _ollama ollama

# [[HUMAN COMMENTED-OUT]]
# Save this script into a file, say `~/.bash_completion`, and add this line to your `~/.bashrc`:
# source ~/.bash_completion
# [[HUMAN COMMENTED-OUT]]
# After saving the above changes, you need to reload your shell by running:
# exec $SHELL
# [[HUMAN COMMENTED-OUT]]
# This will make sure that your current shell picks up the new bash-completion script.
