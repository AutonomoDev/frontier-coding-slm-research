# Bash completion for `ollama run <model>` that lists models via `ollama list`
# Place this file somewhere convenient, e.g. ~/.bash_completion/ollama.sh
# Then source it in your ~/.bashrc or ~/.profile:
#   . ~/.bash_completion/ollama.sh
#   complete -F _ollama_completion ollama
# Reload the shell or run `source ~/.bashrc` to activate.

# [[HUMAN COMMENTED-OUT]]
# Thinking...
# We need to produce a bash completion function for ollama run <model>. We need to parse output of ollama list. The function should check if the command is 'ollama run', i.e., COMP_WORDS[1] == "run". We want completions only when completing after run: that means when the last word is empty or after 'run' and we are completing the next argument.
# 
# We will store output of 'ollama list' in a variable. Use readarray -t or mapfile? But we cannot use mapfile? It's built-in in Bash 4+. Use readarray -t arr <<<"$output". That will preserve empty lines? readarray splits on IFS and newline. If output is whitespace separated, we need to split on whitespace, so IFS can be set to whitespace.
# 
# Simplest: local output=$(ollama list 2>/dev/null) || return 0; then read -a arr <<<"$output". Wait, 'read -a' splits on IFS; if we set IFS to newline? But list may separate by whitespace. We can set IFS=$' \t\n\r' which is default; then read -a arr <<<"$output" will parse words separated by whitespace.
# 
# So arr holds model names.
# 
# Then we filter by prefix: prefix=${COMP_WORDS[COMP_CWORD]}. We can use compgen -W "${arr[*]}" -- "$prefix". However arr[*] is space-separated; but if model names contain spaces, they'd break. But assumption is names are simple tokens. So compgen works. But we also need sorting: compgen sorts? I think compgen -W uses lexical order? It doesn't sort, I think it returns unsorted. But we can sort with sort.
# 
# Better: Build array matches; iterate over arr; if name starts with prefix, add to matches; then sort with sort -u; assign to COMPREPLY.
# 
# Need to sort alphabetically: matches sorted ascending.
# 
# Return 0.
# 
# Also we must guard for 'ollama list' failure: if command fails, return 0 (no completions). So we check local output=$(ollama list 2>/dev/null) || return 0.
# 
# Now function:
# 
# _ollama_run_models() {
#   local cur prev words cword
#   _get_comp_words_by_ref -n : cur prev words cword
# 
# But we don't have _get_comp_words_by_ref unless we source bash_completion library. But requirement: script should be dependency-free, so no external libs. So we need to use basic COMP_* variables.
# 
# We can get cur=${COMP_WORDS[COMP_CWORD]}.
# 
# Then check if COMP_WORDS[1] is "run" and COMP_CWORD==2? Actually run is second word (index 1). The next argument is index 2. So we check if [ "$COMP_CWORD" -eq 2 ] && [ "${COMP_WORDS[1]}" = "run" ]; then do completions. Also if more arguments? Might not need.
# 
# Implementation:
# 
# _ollama_completion() {
#   local cur=${COMP_WORDS[COMP_CWORD]}
#   if [ "$COMP_CWORD" -eq 2 ] && [ "${COMP_WORDS[1]}" = "run" ]; then
#     # fetch list
#     local list_output
#     list_output=$(ollama list 2>/dev/null) || return 0
#     # read into array
#     local models=()
#     # split on whitespace
#     read -ra models <<<"$list_output"
#     local matches=()
#     local i
#     for i in "${models[@]}"; do
#       [[ "$i" == "$cur"* ]] && matches+=("$i")
#     done
#     # sort alphabetically
#     if (( ${#matches[@]} )); then
#       IFS=$'\n' sorted=($(printf '%s\n' "${matches[@]}" | sort))
#       COMPREPLY=("${sorted[@]}")
#     fi
#   fi
# }
# 
# Then complete -F _ollama_completion ollama.
# 
# But we need to ensure we only trigger when first argument is 'run'. Also if more words after model? The script may only complete model, not other options.
# 
# Edge: if user typed 'ollama run' and then typed space and tab, cur would be empty string. Our logic will still compute matches with prefix empty, so all models.
# 
# We need to filter using prefix matching. Works.
# 
# Return 0 by default.
# 
# Add comments.
# 
# Installation: Save script as ~/.bash_completion/ollama_completion.sh or similar; source in .bashrc: source /path/to/script.
# 
# Also can register with complete -F _ollama_completion ollama.
# 
# Also if bash_completion library loaded, might conflict but fine.
# 
# Let's produce final output.
# 
# ...done thinking.

# --------------------------------------------
# Completion function
# --------------------------------------------
_ollama_completion() {
    # Current word being completed
    local cur=${COMP_WORDS[COMP_CWORD]}

    # Trigger only when the command is `ollama run`
    if [[ "${COMP_WORDS[1]}" == "run" && ${COMP_CWORD} -eq 2 ]]; then
        # Obtain the list of models once; ignore errors silently
        local list_output
        list_output=$(ollama list 2>/dev/null) || return 0

        # Split the output on whitespace into an array (no subshell)
        local models=()
        read -ra models <<<"$list_output"

        # Filter by prefix and collect matches
        local matches=()
        for model in "${models[@]}"; do
            [[ "$model" == "$cur"* ]] && matches+=("$model")
        done

        # If we have any matches, sort them alphabetically and set COMPREPLY
        if (( ${#matches[@]} )); then
            # Sort via printf + sort; result goes into COMPREPLY
            local sorted
            IFS=$'\n' sorted=($(printf '%s\n' "${matches[@]}" | sort))
            COMPREPLY=("${sorted[@]}")
        fi
    fi
    return 0
}

# Register the function with the `ollama` command
complete -F _ollama_completion ollama

# [[HUMAN COMMENTED-OUT]]
# **Installation / activation**
# 
# 1. Save the script to a file, e.g. `~/.bash_completion/ollama.sh`.
# 2. In your `~/.bashrc` (or `~/.profile`), add:
#    ```bash
#    . ~/.bash_completion/ollama.sh
#    ```
# 3. Reload the shell (`source ~/.bashrc`) or start a new terminal.  
#    The completion for `ollama run <model>` is now active.
