#Thinking...
#We need to output a Bash script. Must adhere to constraints: single block of code, no markdown. Provide comments. The function _ollama_completions must be defined.
#
#We need to use _get_comp_words_by_ref -n : cur prev; with fallback.
#
#The function should check if command is "ollama" and previous word is "run"? Actually "prev" after parsing should be "run". But also need to ensure COMP_LINE or COMP_WORDS[0] is "ollama". The check may need to use COMP_WORDS[0] maybe.
#
#We'll need to set COMPREPLY=() early for no match.
#
#Also need to check if ollama command exists: if ! command -v ollama > /dev/null; then return 0.
#
#We need to retrieve model names: run `ollama list --format json`? But sample shows plain. We'll just use `ollama list`. Use awk to extract first column, skip header. That could be: `ollama list | awk 'NR>1 {print $1}'`. But header may have spaces. We'll skip first line NR==1.
#
#Then we store into array model_names. We'll filter matches using pattern matching against $cur.
#
#We can do:
#
#matches=()
#
#while read -r model; do
#   if [[ $model == $cur* ]]; then
#        matches+=("$model")
#   fi
#done < <(ollama list | awk 'NR>1 {print $1}')
#
#If no matches, COMPREPLY=(); return
#
#Else sorted: sorted=$(printf "%s\n" "${matches[@]}" | sort | tr '\n' ' ')
#
#Then COMPREPLY=( $(compgen -W "$sorted" -- "$cur") )
#
#After that call __ltrim_colon_completions "$cur".
#
#Edge: __ltrim_colon_completions might not exist if bash-completion not loaded. But it's part of bash-completion. We can call it anyway; if not, maybe not defined. Could check if function exists: if declare -f __ltrim_colon_completions >/dev/null; then __ltrim_colon_completions "$cur"; fi
#
#But requirement says call it after setting COMPREPLY. So we can check.
#
#Also need to support fallback for systems without bash-completion: if ! _get_comp_words_by_ref ... we fall back.
#
#The function _get_comp_words_by_ref returns 0 on success; so we can do:
#
#if ! _get_comp_words_by_ref -n : cur prev; then
#   cur="${COMP_WORDS[COMP_CWORD]}"
#   prev="${COMP_WORDS[COMP_CWORD-1]}"
#fi
#
#Also need to check that previous word before the current word is "run" and that current command is "ollama". So use:
#
#if [[ ${COMP_WORDS[0]} != ollama ]]; then
#   return 0
#fi
#
#Also check if prev != "run". Use [[ $prev != run ]]; then COMPREPLY=(); return; fi
#
#Then proceed.
#
#Edge: we need to check that current word is after run: e.g., "ollama run" then the next word is model. Good.
#
#Let's craft code accordingly.
#
#Also need to register at end: complete -F _ollama_completions ollama
#
#Now produce final code with comments.
#
#Ensure no extraneous output.
#
#Let's produce.
#...done thinking.

#!/usr/bin/env bash
# Bash completion script for `ollama run` that handles model names containing colons.
# This script is intended to be sourced directly in the shell environment.

# Function that implements the completion logic.
_ollama_completions() {
    # Ensure the command being completed is `ollama`.  If not, exit early.
    if [[ "${COMP_WORDS[0]}" != ollama ]]; then
        return 0
    fi

    # Attempt to parse words using the bash-completion helper, taking colons into account.
    # The `-n :` option tells it to treat ':' as part of the word rather than a separator.
    if ! _get_comp_words_by_ref -n : cur prev; then
        # Fallback for systems without bash-completion: use raw COMP_WORDS.
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # Only provide completions after the `run` subcommand.
    if [[ "$prev" != run ]]; then
        COMPREPLY=()
        return 0
    fi

    # Verify that the `ollama` command is available before attempting to list models.
    if ! command -v ollama > /dev/null 2>&1; then
        COMPREPLY=()
        return 0
    fi

    # Retrieve the list of available models from `ollama list`.
    # The output format is a table; we extract the first column and skip the header.
    local models
    models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}')

    # If the command failed or returned no models, exit gracefully.
    if [[ -z "$models" ]]; then
        COMPREPLY=()
        return 0
    fi

    # Build an array of matching model names based on the current word prefix.
    local match
    local matches=()
    while IFS= read -r model; do
        # Bash pattern matching: match if the model name starts with the current input.
        if [[ "$model" == "$cur"* ]]; then
            matches+=("$model")
        fi
    done <<< "$models"

    # If there are no matches, clear COMPREPLY and exit.
    if [[ ${#matches[@]} -eq 0 ]]; then
        COMPREPLY=()
        return 0
    fi

    # Sort the matches to provide deterministic completion order.
    local sorted_matches
    sorted_matches=$(printf "%s\n" "${matches[@]}" | sort | tr '\n' ' ')

    # Generate the final completion candidates.
    COMPREPLY=( $(compgen -W "$sorted_matches" -- "$cur") )

    # Adjust completion display for colons by trimming the part before the colon.
    # This is required for correct visual completion when model names contain ':'.
    if declare -f __ltrim_colon_completions > /dev/null 2>&1; then
        __ltrim_colon_completions "$cur"
    fi
}

# Register the completion function for the `ollama` command.
complete -F _ollama_completions ollama

# End of script.

