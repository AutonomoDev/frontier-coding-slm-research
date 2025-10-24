#Thinking...
#We need to write a script for bash-completion v2.
#
#We need to define a completion function, probably named `_ollama_run`.
#
#Check COMP_WORDS[1] == 'run', else exit.
#
#We need to parse `ollama list` output. The first column after header.
#
#Command: `ollama list | tail -n +2 | awk '{print $1}'` should give names. We can store in array.
#
#We need to filter based on current word: COMP_WORDS[COMP_CWORD] is the word being completed. If it's the first word after `run`, i.e., position 2? Let's check: command: `ollama run <WORD>`. COMP_WORDS[0] = ollama; COMP_WORDS[1] = run; COMP_WORDS[2] = <WORD> ; COMP_CWORD=2. So we want to complete at index 2.
#
#We must produce completions for that word only.
#
#We must not fallback to filenames; to avoid fallback we should set `COMPREPLY=()` only with filtered matches; do not set `-o default`. Usually, if COMPREPLY is empty, completion engine will not show anything.
#
#We must ensure uniqueness; array of names unique.
#
#Implementation: function:
#
#_ollama_run() {
#    local cur prev words cword
#    cur="${COMP_WORDS[COMP_CWORD]}"
#    prev="${COMP_WORDS[COMP_CWORD-1]}"
#    words=("${COMP_WORDS[@]}")
#    cword=$COMP_CWORD
#
#    # Only trigger after 'run'
#    if [[ ${words[1]} != "run" ]]; then
#        return
#    fi
#
#    # only complete when completing the first argument after run
#    if [[ $cword -ne 2 ]]; then
#        return
#    fi
#
#    # get models
#    local models
#    IFS=$'\n' read -r -d '' -a models < <(ollama list | tail -n +2 | awk '{print $1}' | tr '\n' '\0')
#    # filter
#    local IFS=$' '
#    COMPREPLY=()
#    for m in "${models[@]}"; do
#        if [[ $m == $cur* ]]; then
#            COMPREPLY+=("$m")
#        fi
#    done
#    # no fallback
#    __bashcomp_line_completion
#}
#
#But we need to not use __bashcomp_line_completion.
#
#Simpler: just rely on COMPREPLY.
#
#Better: Use `compgen -W "${models[*]}" -- "$cur"` maybe? But we must filter.
#
#Simpler: `COMPREPLY=($(compgen -W "${models[*]}" -- "$cur"))`
#
#But compgen will output matches; duplicates may appear? The list is unique. Good.
#
#We must avoid fallback; we can set `COMPREPLY=()` by default.
#
#Also we should maybe set `local IFS=$' '` before.
#
#Ok, script: define function, then register with `complete -F _ollama_run ollama`.
#
#Also we need to check that `COMP_WORDS[1]` equals run. And only apply for subcommand run.
#
#Also we must not use external functions.
#
#Edge cases: If ollama command not found or list fails? We may ignore.
#
#Return status.
#
#Implementation final script:
#
#```
##!/usr/bin/env bash
## Bash completion for ollama run
## Provides model names completion after 'ollama run'
#
#_ollama_run() {
#    # Only trigger for 'run' subcommand
#    if [[ ${COMP_WORDS[1]} != "run" ]]; then
#        return
#    fi
#
#    # Only complete the first argument after run
#    if [[ ${COMP_CWORD} -ne 2 ]]; then
#        return
#    fi
#
#    local cur="${COMP_WORDS[COMP_CWORD]}"
#    # Fetch model names, skip header
#    local model_list
#    model_list=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
#    if [[ -z $model_list ]]; then
#        return
#    fi
#
#    # Generate completions filtered by current word
#    COMPREPLY=($(compgen -W "$model_list" -- "$cur"))
#
#    # Ensure no filename fallback
#    return
#}
#
## Register the completion
#complete -F _ollama_run ollama
#```
#
#But need to avoid compgen default fallback? If no matches, COMPREPLY will be empty. That should be fine.
#
#Ensure no duplicate; compgen will dedupe? It doesn't duplicate as input is unique.
#
#We should also set `local IFS=$'\n'` maybe? But compgen expects space separated list; our model_list contains newline separated. But passing as a string with newlines will treat them as separate words because compgen splits on whitespace including newline. So fine.
#
#We can also use `printf '%s\n' "$model_list"`? No.
#
#Better: use array:
#
#```
#IFS=$'\n' read -d '' -r -a models < <(ollama list | tail -n +2 | awk '{print $1}' | tr '\n' '\0')
#COMPREPLY=($(compgen -W "${models[*]}" -- "$cur"))
#```
#
#This ensures uniqueness.
#
#Ok.
#
#Also we need to guard for no `ollama` command. If `ollama list` fails, return.
#
#Let's produce final script with comments.
#...done thinking.

#!/usr/bin/env bash
# -----------------------------------------
# Bash completion script for `ollama run`
# Provides model‑name suggestions after the `run` subcommand.
# -----------------------------------------

# Completion function
_ollama_run() {
    # Only trigger for the `run` subcommand
    if [[ ${COMP_WORDS[1]} != "run" ]]; then
        return
    fi

    # Only complete the first argument after `run`
    if [[ ${COMP_CWORD} -ne 2 ]]; then
        return
    fi

    local cur="${COMP_WORDS[COMP_CWORD]}"

    # Grab the list of local models (first column only, skip header)
    # Fail silently if `ollama` is unavailable or the command errors
    local model_list
    if ! model_list=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}'); then
        return
    fi

    # Turn the newline‑separated list into an array
    IFS=$'\n' read -r -d '' -a models < <(printf '%s\n' "$model_list" | tr '\n' '\0')

    # Generate completions that match the current word
    COMPREPLY=($(compgen -W "${models[*]}" -- "$cur"))

    # No filename fallback: if COMPREPLY is empty nothing will be shown
    return
}

# Register the completion function for the `ollama` command
complete -F _ollama_run ollama

