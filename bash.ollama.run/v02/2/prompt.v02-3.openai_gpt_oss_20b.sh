# Thinking...
# We need to produce a bash completion function for `ollama run <model>`. The function should only trigger after "run" in the command line. So we need to check COMP_WORDS[COMP_CWORD-1] maybe? The typical pattern is: when COMP_CWORD == 2 and COMP_WORDS[1] == "run". Or for "ollama run <model>", after "run" there's the first argument. So we can trigger when COMP_WORDS[1] == "run" and COMP_CWORD == 2. But also handle scenario if user typed "ollama run" and then press Tab, we want to complete. Also maybe if they typed "ollama run foo" and then press Tab after a partial word. So we just need to provide completions for the next word after "run". So we check: [[ "${COMP_WORDS[1]}" == "run" ]] && (( COMP_CWORD == 2 ))? But if they are typing a prefix after "run", COMP_CWORD will be 2, but COMP_WORDS[1] is "run" and COMP_WORDS[2] is the partial word. Actually COMP_WORDS[COMP_CWORD] is the current word being completed. So if they are typing "ollama run <prefix>" and pressing Tab, COMP_CWORD will be 2 and COMP_WORDS[2] will be "<prefix>" maybe empty if they pressed Tab right after "run " with no characters. So we need to trigger completions if COMP_WORDS[1] == "run" and (( COMP_CWORD == 2 )). Good.
#
# Now we need to get ollama list output into variable. Use e.g., models=$(ollama list 2>/dev/null). But we need to capture output even if it's large. Use readarray? But we can't pipe into while read because that spawns subshell. Use a variable: out=$(ollama list 2>/dev/null) || return 0; Then we parse: Use read -ra arr <<<"$out" to split into words. That splits on IFS, but the requirement says "one per line or separated by whitespace". So splitting on whitespace will handle both. We can get array arr.
#
# Then we need to filter by prefix: current prefix is ${COMP_WORDS[COMP_CWORD]}. We need to match arr elements that start with prefix. Use for m in "${arr[@]}"; do if [[ $m == "$prefix"* ]]; then ...; fi; done. Add matches to an array matched. Then sort them alphabetically: Use IFS=$'\n' sorted=($(printf '%s\n' "${matched[@]}" | sort)) but we cannot call sort (external). But we can sort using builtin: The simplest is to use `sort` command, but that's external. We need to sort alphabetically using bash built-ins. We could use `mapfile -t sorted < <(printf '%s\n' "${matched[@]}" | sort)` but that's external sort. Can't. But we can sort in Bash using array sorting with `printf`? Not built-in. We can emulate sorting by using the `printf -v`? Actually Bash 4 has `sort` builtin? No. There's no built-in sort. We need to sort alphabetically manually. Could use `for ((i=0;i<${#matched[@]};i++))` and use nested loops to sort ascending by comparing string lexicographically. Simple selection sort. We can implement simple sorting algorithm in bash. That is allowed.
#
# Simpler: We can skip sorting? But requirement says sort them alphabetically. So we implement quick sort or simple insertion sort.
#
# Let's implement:
#
# sorted=()
# for m in "${matched[@]}"; do
#     sorted+=( "$m" )
# done
# # insertion sort
# for ((i=1;i<${#sorted[@]};i++)); do
#     key=${sorted[i]}
#     j=$((i-1))
#     while ((j>=0)) && [[ ${sorted[j]} > key ]]; do
#         sorted[j+1]=${sorted[j]}
#         j=$((j-1))
#     done
#     sorted[j+1]=$key
# done
#
# Then assign COMPREPLY=("${sorted[@]}").
#
# Return 0.
#
# Graceful failure: if ollama list fails or output empty, we just return 0.
#
# Need to set COMPLETE variable accordingly.
#
# Now we need to wire: complete -F _ollama_run_completion ollama
#
# The function name maybe _ollama_run_completion.
#
# Add comments.
#
# Installation instructions: Save script to e.g., ~/.bash_completion.d/ollama.sh or to /etc/bash_completion.d/ollama. Then source it or add to .bashrc: source /path/to/script.sh and reload.
#
# Let's produce final script.
#
# Check variable names: prefix=${COMP_WORDS[COMP_CWORD]}.
#
# Edge cases: When no prefix (empty), prefix empty matches all.
#
# Ok.
#
# Also we need to be careful to not create subshell: reading from variable. We use `read -ra arr <<<"$out"` which uses process substitution? No, it's built-in redirection. Good.
#
# Also we need to avoid interfering with other completions. The function should return 0 if not triggered.
#
# Add test: if [[ $1 != ollama ]]; return 0; but complete will pass only the command name.
#
# Implementation:
#
# _ollama_run_completion() {
#     local cur prev words cword
#     cur="${COMP_WORDS[COMP_CWORD]}"
#     prev="${COMP_WORDS[COMP_CWORD-1]}"
#     words=("${COMP_WORDS[@]}")
#     cword=$COMP_CWORD
#
#     # Trigger only when the command is "ollama" and the previous word is "run" and we are completing the model name
#     if [[ ${words[0]} != ollama || ${words[1]} != run || $cword -ne 2 ]]; then
#         return 0
#     fi
#
#     # Capture the output of ollama list once
#     local list_output
#     if ! list_output=$(ollama list 2>/dev/null); then
#         return 0
#     fi
#
#     # Split into words (models)
#     local models
#     read -ra models <<<"$list_output"
#
#     # Filter models by prefix
#     local match
#     local matches=()
#     for match in "${models[@]}"; do
#         if [[ $match == "$cur"* ]]; then
#             matches+=("$match")
#         fi
#     done
#
#     # If no matches, return
#     if (( ${#matches[@]} == 0 )); then
#         return 0
#     fi
#
#     # Sort alphabetically (insertion sort)
#     local sorted=("${matches[@]}")
#     local i j key
#     for ((i=1;i<${#sorted[@]};i++)); do
#         key=${sorted[i]}
#         j=$((i-1))
#         while ((j>=0)) && [[ ${sorted[j]} > key ]]; do
#             sorted[j+1]=${sorted[j]}
#             j=$((j-1))
#         done
#         sorted[j+1]=$key
#     done
#
#     COMPREPLY=("${sorted[@]}")
#     return 0
# }
#
# complete -F _ollama_run_completion ollama
#
# Now installation instructions: Save to e.g., ~/.bash_completion/ollama_completion.sh, then add to .bashrc: source ~/.bash_completion/ollama_completion.sh; or run complete -F ... manually.
#
# Also we can mention adding to /etc/bash_completion.d.
#
# Now produce final answer.
# ...done thinking.

# ------------------------------------------------------------------
# Bash completion for `ollama run <model>`
# ------------------------------------------------------------------
# Trigger: when the command is `ollama` and the previous word is
#          `run` and we are completing the next (model) argument.
# The function captures the output of `ollama list` once,
# splits it on whitespace (handles lines or spaces),
# filters by the current prefix,
# sorts the matches alphabetically using a simple insertion sort,
# and assigns them to COMPREPLY.
# ------------------------------------------------------------------
_ollama_run_completion() {
    local cur prev words cword
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    words=("${COMP_WORDS[@]}")
    cword=$COMP_CWORD

    # Only complete after `ollama run`
    if [[ ${words[0]} != ollama || ${words[1]} != run || $cword -ne 2 ]]; then
        return 0
    fi

    # Capture the list of models once; ignore any error.
    local list_output
    if ! list_output=$(ollama list 2>/dev/null); then
        return 0
    fi

    # Split into words (handles newline or space separators)
    local models
    read -ra models <<<"$list_output"

    # Filter by the current prefix
    local match
    local matches=()
    for match in "${models[@]}"; do
        if [[ $match == "$cur"* ]]; then
            matches+=("$match")
        fi
    done

    # No matches? nothing to offer.
    if (( ${#matches[@]} == 0 )); then
        return 0
    fi

    # Sort matches alphabetically (insertion sort – no external tools)
    local sorted=("${matches[@]}")
    local i j key
    for ((i=1; i<${#sorted[@]}; i++)); do
        key=${sorted[i]}
        j=$((i-1))
        while ((j>=0)) && [[ ${sorted[j]} > key ]]; do
            sorted[j+1]=${sorted[j]}
            j=$((j-1))
        done
        sorted[j+1]=$key
    done

    COMPREPLY=("${sorted[@]}")
    return 0
}

# Wire the function to the `ollama` command
complete -F _ollama_run_completion ollama

# [[HUMAN COMMENTED-OUT]]
# **Installation / activation**
# 
# 1. Save the script to a file, e.g. `~/.bash_completion/ollama_completion.sh`.
# 2. In your `~/.bashrc` (or `/etc/bash_completion.d/` for system‑wide) add:
#    #    source ~/.bash_completion/ollama_completion.sh
#    ```
# 3. Reload the shell or run `source ~/.bashrc` to activate immediately.
