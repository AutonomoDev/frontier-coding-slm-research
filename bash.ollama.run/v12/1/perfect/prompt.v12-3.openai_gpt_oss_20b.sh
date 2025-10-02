#Thinking...
#We need to generate a bash script as per the instructions. It must contain a function _ollama_completions, with the logic described. Ensure we call __ltrim_colon_completions. Must handle fallback for _get_comp_words_by_ref. Use local variables. Add comments. At the end, register completion. Let's write.
#
#We need to parse ollama list. Use while read -r line; do ... skip header. Use awk? In while loop, we could read line and if first column is not "NAME" and line non-empty then extract first word: model="${line%% *}". Or use awk. We'll build local array models.
#
#After building models, create matches array by iterating and check prefix with [[ $model == $cur* ]] but careful with null. Use [[ ${model:0:${#cur}} == "$cur" ]].
#
#Sorted matches: sorted_matches=$(printf '%s\n' "${matches[@]}" | sort). Then COMPREPLY=( $(compgen -W "$sorted_matches" -- "$cur") ). Ensure local. Then call __ltrim_colon_completions "$cur".
#
#Edge: If models array empty: COMPREPLY=(); return.
#
#Ok. Let's code. Use local cur prev. Check first word: use ${COMP_WORDS[0]}. And previous word is ${COMP_WORDS[COMP_CWORD-1]}. But if _get_comp_words_by_ref used, we rely on cur prev. But we also need to check first word is "ollama" regardless. So use ${COMP_WORDS[0]}. Also need to ensure COMP_WORDS[COMP_CWORD-1] is "run". Actually need to check that the command preceding the current argument is "run". But the function is registered on "ollama", so COMP_WORDS[0] is "ollama". And we check prev is "run". So fine.
#
#Also we need to handle case where COMP_CWORD=0? But we can guard.
#
#Let's produce code.
#
#Also note __ltrim_colon_completions is part of bash-completion 2+. We just call it.
#
#Ok code.
#...done thinking.

#!/usr/bin/env bash
# Bash completion for `ollama run` that handles model names containing colons

_ollama_completions() {
    # Local variables for current and previous word
    local cur prev

    # Try to use bash-completion's word parsing that ignores colons.
    # If unavailable, fall back to basic COMP_WORDS indices.
    if ! _get_comp_words_by_ref -n : cur prev; then
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # Only trigger when the command is "ollama" and the previous word is "run"
    if [[ "${COMP_WORDS[0]}" != "ollama" || "$prev" != "run" ]]; then
        COMPREPLY=()
        return
    fi

    # Ensure the ollama executable exists
    if ! command -v ollama &>/dev/null; then
        COMPREPLY=()
        return
    fi

    # Retrieve model names from `ollama list`, ignoring header and empty lines
    local -a models=()
    while IFS= read -r line; do
        # Skip header line and empty lines
        [[ -z "$line" || "$line" == NAME* ]] && continue
        # Extract the first column (model name)
        local model="${line%% *}"
        models+=("$model")
    done < <(ollama list 2>/dev/null)

    # If no models were found, nothing to complete
    if (( ${#models[@]} == 0 )); then
        COMPREPLY=()
        return
    fi

    # Find matches that start with the current word
    local -a matches=()
    for model in "${models[@]}"; do
        if [[ ${#cur} -eq 0 || ${model:0:${#cur}} == "$cur" ]]; then
            matches+=("$model")
        fi
    done

    # If no matches, clear completions
    if (( ${#matches[@]} == 0 )); then
        COMPREPLY=()
        return
    fi

    # Sort matches to provide orderly suggestions
    local sorted_matches
    sorted_matches=$(printf '%s\n' "${matches[@]}" | sort)

    # Generate the final completion list
    COMPREPLY=( $(compgen -W "$sorted_matches" -- "$cur") )

    # Critical: trim any leading colon so completions appear after a colon
    __ltrim_colon_completions "$cur"
}

# Register the completion function for the `ollama` command
complete -F _ollama_completions ollama


