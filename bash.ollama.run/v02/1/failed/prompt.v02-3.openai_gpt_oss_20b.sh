#!/usr/bin/env bash
#Thinking...
#We need to write a bash completion script.
#
#Goal: command "ollama run <model>"
#
#We need to parse output of "ollama list" into variable, then iterate to get models.
#
#We must filter by current word after "run". That is COMP_WORDS[COMP_CWORD] will hold the word being completed.
#
#We also need to trigger only when first word after 'run'.
#
#Command line: "ollama run <model>" -> COMP_WORDS[0] = ollama, [1] = run, [2] = <model> being completed (if not provided, it's empty). So we need to check if COMP_WORDS[1] == "run" and COMP_CWORD == 2? But user might be completing at the position after "run", so COMP_CWORD should be 2. Or maybe 2? Yes.
#
#Also, we need to call "ollama list" once and capture output into variable, e.g., output=$(ollama list 2>/dev/null) or similar. If fails (non-zero exit), we should return 0 without completions. Use if ! command returns >0; return 0; end.
#
#We then need to parse output into array of model names. The output can be multiple lines or whitespace separated. We can split into array via read -ra arr <<< "$output". read with -a will split on IFS default (space, tab, newline). That will produce array of words.
#
#Now we need to filter matches that start with "$cur". The variable $cur holds the word being completed: from COMP_WORDS[COMP_CWORD]. But we need to handle if COMP_CWORD is 2 or more.
#
#We can use compgen -W "${array[@]}" -- "$cur" to get matches? But we need to provide sorted alphabetically. compgen outputs sorted? compgen -W will return unsorted? According to bash, compgen sorts? I think compgen -W sorts alphabetically? I'm not sure. We can sort manually: we can generate array of matches, then sort with sort command? But we can't use external. Sorting without external: use builtin sort? There's no builtin sort. We can sort manually by using printf with sort? Not allowed. So we can rely on compgen sorting? It may output sorted. Let's test knowledge: compgen -W "a b c" returns "a b c" sorted? I think compgen will output in the order given. So if we pass array unsorted, it will output unsorted. But we can sort the array ourselves using a simple bubble sort? But that's overkill. But requirement 5 says "If there are multiple matches, sort them alphabetically before assigning to COMPREPLY." We can sort by using an array and then call compgen on that? Maybe compgen sorts. Let's assume compgen sorts alphabetically. But to be safe, we can use an array of matches then sort using the built-in Bash sort? There's no built-in sort. We can use 'printf "%s\n" "${matches[@]}" | sort' but that's external sort. Not allowed. So we need to sort ourselves.
#
#Implement simple insertion sort on matches array.
#
#Procedure: declare -a matches; then iterate over arr and if word startswith cur, add to matches array. After loop, sort matches alphabetically: we can use an approach: for i in 0..n-1; for j=i+1..n-1; if matches[j] < matches[i], swap. Use string comparison: [[ "${matches[j]}" < "${matches[i]}" ]]. That uses < for lexicographic comparison.
#
#After sorting, set COMPREPLY=( "${matches[@]}" ).
#
#Also, we need to return 0 if no matches.
#
#Also, we need to wire with complete -F functionName ollama.
#
#We should write the function: _ollama_run_completions().
#
#Implementation steps:
#
#function _ollama_run_completions() {
#    local cur prev words cword
#    _get_comp_words_by_ref -n : cur prev words cword
#? We might not use that helper. Instead we can get manually: cur="${COMP_WORDS[COMP_CWORD]}" prev="${COMP_WORDS[COMP_CWORD-1]}" etc.
#
#Check if words[1] != "run" or cword != 2: return 0.
#
#Then get list: local out; out=$(ollama list 2>/dev/null) || return 0; but if exit non-zero we should return 0. Use command substitution with $? check: out=$(ollama list 2>/dev/null); local ret=$?; if (( ret != 0 )); then return 0; fi
#
#Now parse: local -a models; read -ra models <<< "$out"
#
#Now filter:
#
#local -a matches; for m in "${models[@]}"; do if [[ "$m" == "$cur"* ]]; then matches+=("$m"); fi; done
#
#Now sort: Use simple bubble sort.
#
#for ((i=0; i<${#matches[@]}; i++)); do
#    for ((j=i+1; j<${#matches[@]}; j++)); do
#        if [[ "${matches[j]}" < "${matches[i]}" ]]; then
#            local tmp="${matches[i]}"; matches[i]="${matches[j]}"; matches[j]="$tmp";
#        fi
#    done
#done
#
#Now set COMPREPLY=( "${matches[@]}" ); return 0;
#
#Edge: If cur empty, we want to return all models? That will filter because "" matches all. Works.
#
#Now need to register: complete -F _ollama_run_completions ollama
#
#We also need to ensure only trigger when second word is "run". The above check ensures.
#
#Let's produce script with comments.
#
#Installation instructions: Add to ~/.bash_completion.d/ollama_completion.sh or just source.
#
#Let's produce final.
#...done thinking.

# Bash completion for `ollama run <model>`
# -----------------------------------------

_ollama_run_completions() {
    # The current word being completed and the word before it
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local prev="${COMP_WORDS[COMP_CWORD-1]}"

    # Trigger only for `ollama run <model>` (i.e., second word is "run")
    # COMP_WORDS[1] is the first argument after the command.
    if [[ "${COMP_WORDS[1]}" != "run" ]] || (( COMP_CWORD != 2 )); then
        return 0
    fi

    # Grab the list of models once.  Silently return if the command fails.
    local out
    out=$(ollama list 2>/dev/null)
    local status=$?
    if (( status != 0 )); then
        return 0
    fi

    # Split the output into an array – read -ra uses IFS to split on whitespace/newlines
    local -a models
    read -ra models <<< "$out"

    # Filter models that start with the current prefix
    local -a matches
    for m in "${models[@]}"; do
        if [[ "$m" == "$cur"* ]]; then
            matches+=("$m")
        fi
    done

    # Sort matches alphabetically (in‑place, no external tools)
    local i j tmp
    for ((i=0; i<${#matches[@]}; i++)); do
        for ((j=i+1; j<${#matches[@]}; j++)); do
            if [[ "${matches[j]}" < "${matches[i]}" ]]; then
                tmp="${matches[i]}"
                matches[i]="${matches[j]}"
                matches[j]="$tmp"
            fi
        done
    done

    COMPREPLY=( "${matches[@]}" )
    return 0
}

# Register the completion function for `ollama` command
complete -F _ollama_run_completions ollama

# --------------------------------------------------------------------
# Installation / activation:
#   1. Save this script to a file, e.g. ~/.bash_completion.d/ollama
#   2. Ensure the file is readable:  chmod +x ~/.bash_completion.d/ollama
#   3. Source it (or restart the shell):
#        . ~/.bash_completion.d/ollama
#   4. Completions will work immediately for `ollama run <TAB>`.
