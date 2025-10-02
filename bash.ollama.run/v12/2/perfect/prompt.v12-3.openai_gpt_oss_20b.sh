#Thinking...
#We need to output pure bash code following instructions. Must include function _ollama_completions. Use _get_comp_words_by_ref with -n :. Fallback. After completion, call __ltrim_colon_completions "$cur". Use compgen. Also ensure sorting.
#
#Also handle checking first word "ollama" and prev is "run". But in logic: check if first word is "ollama" and prev is "run". Actually prev is the word before current. If prev is "run", good. But also need check first word is "ollama" to avoid other contexts. Could check COMP_WORDS[0] == "ollama". Use if [[ ${COMP_WORDS[0]} != ollama || $prev != run ]]; then COMPREPLY=(); return; fi.
#
#The script must set COMPREPLY accordingly.
#
#Edge: __ltrim_colon_completions function may not exist if bash-completion not loaded. But we assume. We must call it. If not exist, no error? We'll assume.
#
#Implement reading output: while read -r line; do ...; done < <(ollama list 2>/dev/null). Skip header: if [[ "$line" == "NAME"* ]] continue; skip empty: [[ -z "$line" ]] && continue. Use awk? Instead of piping each line through awk, just split with read: read -r name rest; but safer use awk: echo "$line" | awk '{print $1}'. But we are reading line by line, so we can use read -r name _; models+=("$name"). That splits on whitespace; first field is name. That works. We'll implement read -r name rest; but rest may contain spaces; but okay. Actually name may contain colon but no spaces. Good.
#
#Implement matches: if [[ "$name" == "$cur"* ]]; then matches+=("$name"); fi. Use glob pattern.
#
#Sorting: sorted_matches=$(printf '%s\n' "${matches[@]}" | sort). Then compgen -W "$sorted_matches" -- "$cur".
#
#Return.
#
#Edge: Need to set local arrays: local models=() matches=(). Also local cur prev.
#
#Also need to handle if _get_comp_words_by_ref fails: fallback. Use if ! _get_comp_words_by_ref -n : cur prev; then ... fi.
#
#Let's craft code.
#
#Add comments.
#
#Register complete.
#
#Also need to ensure __ltrim_colon_completions is defined. We'll call it.
#
#Ok.
#
#Also we need to use command -v ollama to check existence.
#
#Return early if no matches.
#
#Let's write.
#
#...done thinking.

#!/usr/bin/env bash

# Bash completion function for `ollama run` model names
_ollama_completions() {
    local cur prev models=() matches=()

    # Get current and previous words, preventing Bash from splitting on ':'
    if ! _get_comp_words_by_ref -n : cur prev; then
        # Fallback if the helper isn't available
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # Ensure we're completing after `ollama run`
    if [[ ${COMP_WORDS[0]} != ollama || $prev != run ]]; then
        COMPREPLY=()
        return
    fi

    # Verify that the `ollama` command is available
    if ! command -v ollama &>/dev/null; then
        COMPREPLY=()
        return
    fi

    # Fetch the list of models, parse only the first column (model names)
    while IFS= read -r line; do
        # Skip header and empty lines
        [[ -z "$line" || "$line" == NAME* ]] && continue
        # Split the line; first field is the model name
        read -r name _ <<< "$line"
        models+=("$name")
    done < <(ollama list 2>/dev/null)

    # No models found; nothing to complete
    if [[ ${#models[@]} -eq 0 ]]; then
        COMPREPLY=()
        return
    fi

    # Find matches that start with the current word
    for name in "${models[@]}"; do
        if [[ "$name" == "$cur"* ]]; then
            matches+=("$name")
        fi
    done

    # If no matches, clear completion list
    if [[ ${#matches[@]} -eq 0 ]]; then
        COMPREPLY=()
        return
    fi

    # Sort matches for consistent ordering
    local sorted_matches
    sorted_matches=$(printf '%s\n' "${matches[@]}" | sort)

    # Generate the completion candidates
    COMPREPLY=( $(compgen -W "$sorted_matches" -- "$cur") )

    # Fix colon handling for display after completions
    __ltrim_colon_completions "$cur"
}

# Register the completion function for the `ollama` command
complete -F _ollama_completions ollama


