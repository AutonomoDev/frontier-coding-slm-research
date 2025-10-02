#Thinking...
#We need to write a Bash completion script for ollama run. Use bash-completion framework v2. Should only activate when ${COMP_WORDS[1]} is "run". Provide completions for model names from ollama list.
#
#Parsing: use awk prohibited, so we need to use e.g., cut -d' ' -f1 but there can be spaces in the first column? The output is left-justified with variable spacing. The first column may be variable length but no spaces inside model name; separated by whitespace. We can use `cut -d' ' -f1` but multiple spaces might produce empty fields; better to use `awk` but not allowed. Could use `cut -f1` but default delimiter is TAB, not space. We can use `sed -e 's/  */ /g' -e 's/^[ ]*//' to normalize spaces, then cut -d' ' -f1. But still we need to skip header.
#
#Better: use `while read -r line; do` then use `[[ $line == NAME* ]] && continue`. Then extract first word: `model=${line%% *}`. That uses pattern removal to get first field. Works even if multiple spaces.
#
#We need to store in array variable. Use `mapfile -t models <<< "$(ollama list | ... )"` but we need to parse. Use `while read -r line; do ... done < <(ollama list)`.
#
#We also need to avoid duplicates: use a associative array to track seen names.
#
#We must use only bash built-ins and coreutils. Use `compgen`? We can just filter ourselves.
#
#Implement completion function:
#
#```
#_ollama_run_completion() {
#    local cur prev
#    cur="${COMP_WORDS[COMP_CWORD]}"
#    prev="${COMP_WORDS[COMP_CWORD-1]}"
#
#    # Only for 'run'
#    if [[ ${COMP_WORDS[1]} != run ]]; then
#        return
#    fi
#
#    # Get models
#    local models=()
#    local seen=()
#    while IFS= read -r line; do
#        [[ $line == NAME* ]] && continue
#        local name=${line%% *}
#        [[ -z $name ]] && continue
#        if [[ -z ${seen[$name]} ]]; then
#            seen[$name]=1
#            models+=("$name")
#        fi
#    done < <(ollama list 2>/dev/null)
#
#    # Filter by prefix
#    local IFS=$'\n'
#    local opts
#    opts=()
#    for m in "${models[@]}"; do
#        [[ $m == $cur* ]] && opts+=("$m")
#    done
#
#    COMPREPLY=("${opts[@]}")
#    return 0
#}
#```
#
#Need to declare associative array `declare -A seen`. Ensure bash version supports associative arrays (bash 4+). But many systems have bash 5. Good.
#
#We also need fallback for `_get_comp_words_by_ref` not used.
#
#Also need to register completion: `complete -F _ollama_run_completion ollama`
#
#Add comments.
#
#Also we need to consider that the user might type `ollama run --something`? Not required.
#
#The script should be sourced. Provide comments.
#
#We need to include `# shellcheck disable=SC2034` maybe.
#
#Edge: if no models, COMPREPLY empty.
#
#Also need to avoid file completion: if no matches, we should not call default completion. By setting COMPREPLY empty we should avoid fallback. In bash-completion, if COMPREPLY empty, no fallback. So fine.
#
#Let's produce final script.
#
#We should also check that `ollama list` command may produce errors; we redirect stderr to /dev/null.
#
#Ensure use of `local` inside function.
#
#We might also want to add a `readonly` for COMP_WORDS etc but not necessary.
#
#Wrap in a function `_ollama_run_completion` and then register with complete.
#
#Add comments.
#
#Also we need to ensure that the script uses standard bash syntax. Provide `#!/usr/bin/env bash`? Not necessary as it is sourced, but good to include. But script might not be executable; but fine.
#
#Add `# shellcheck disable=SC2009` if we used pipe but we don't.
#
#Ok produce script.
#
#...done thinking.

#!/usr/bin/env bash
#
# Bash completion for `ollama run`
# --------------------------------
#
# Provides autocompletion of local Ollama model names only when the second
# word of the command is `run`.  Model names are extracted from the output of
# `ollama list` and filtered to match the current word being typed.  No
# filename fallback is offered; an empty completion list is returned if no
# models match.
#
# Usage:
#   source /path/to/this/script.sh
#   (or install it in your completion directory)
#
# The script uses only Bash built‑ins and GNU coreutils.  Awk and other
# non‑standard utilities are deliberately avoided.

# ----------------------------------------------------------------------
# Helper: Completion function for `ollama run`
# ----------------------------------------------------------------------
_ollama_run_completion() {
    # Grab the current word being completed and the previous word
    local cur prev
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    # Only activate when the second word is exactly `run`
    if [[ ${COMP_WORDS[1]} != run ]]; then
        return
    fi

    # ------------------------------------------------------------------
    # Retrieve and parse the list of available models
    # ------------------------------------------------------------------
    local models=()
    # Associative array to avoid duplicate entries
    declare -A seen

    # Execute `ollama list` once and process each line
    while IFS= read -r line; do
        # Skip the header line that starts with "NAME"
        [[ $line == NAME* ]] && continue

        # Extract the first whitespace‑separated field (the model name)
        local name=${line%% *}
        [[ -z $name ]] && continue  # guard against empty lines

        # Store each unique model name
        if [[ -z ${seen[$name]} ]]; then
            seen[$name]=1
            models+=("$name")
        fi
    done < <(ollama list 2>/dev/null)   # suppress any errors from ollama

    # ------------------------------------------------------------------
    # Filter models by the current prefix (case‑sensitive)
    # ------------------------------------------------------------------
    local IFS=$'\n'
    local opts=()
    for m in "${models[@]}"; do
        [[ $m == $cur* ]] && opts+=("$m")
    done

    # ------------------------------------------------------------------
    # Return the completion list
    # ------------------------------------------------------------------
    COMPREPLY=("${opts[@]}")
    return 0
}

# ----------------------------------------------------------------------
# Register the completion function with bash-completion
# ----------------------------------------------------------------------
complete -F _ollama_run_completion ollama

