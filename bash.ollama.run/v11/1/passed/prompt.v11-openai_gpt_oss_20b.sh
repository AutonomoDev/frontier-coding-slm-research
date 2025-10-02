#Thinking...
#We need to output a bash script as described. Include function _ollama_completions, with colon handling. Also need __ltrim_colon_completions - but that's part of bash-completion. But we will call it. So we need to ensure it's available or fallback? They didn't ask to fallback for it. We will call it; assume environment. Provide error handling: if ollama not found, return. Use local variables. Provide sorting. Use compgen -W. Then after setting COMPREPLY, call __ltrim_colon_completions "$cur". Then complete -F _ollama_completions ollama.
#
#Make sure to handle _get_comp_words_by_ref fallback.
#
#Let's produce.
#
#Be careful with array iteration and pattern matching: we can use matches array, fill with each model name that matches cur.
#
#We also need to parse output. We'll use while read -r name rest; do [ "$name" != "NAME" ] && names+=("$name"); done < <(ollama list). But output header "NAME ID SIZE MODIFIED" so first column is NAME. So skip first line.
#
#Implementation:
#
#local cur prev
#
#if ! _get_comp_words_by_ref -n : cur prev; then
#  cur="${COMP_WORDS[COMP_CWORD]}"
#  prev="${COMP_WORDS[COMP_CWORD-1]}"
#fi
#
#Then check: if [[ "$prev" != "run" ]]; then COMPREPLY=(); return; fi
#
#But also need to check command is "ollama" - maybe ${COMP_WORDS[0]}? Actually the function is invoked for "ollama". So can just check previous word "run". But they said check if command is "ollama" and previous word is "run". So we can do if [[ ${COMP_WORDS[0]} != "ollama" || "$prev" != "run" ]]; then COMPREPLY=(); return; fi
#
#Ok.
#
#Check if ollama exists: command -v ollama > /dev/null || { COMPREPLY=(); return; }
#
#Now get models: local models=(); while read -r name _; do [[ "$name" == "NAME" ]] && continue; models+=("$name"); done < <(ollama list)
#
#If models empty: COMPREPLY=(); return.
#
#Now filter: local matches=(); for m in "${models[@]}"; do [[ "$m" == "$cur"* ]] && matches+=("$m"); done
#
#If matches empty: COMPREPLY=(); return
#
#sort: local sorted_matches; sorted_matches=$(printf '%s\n' "${matches[@]}" | sort)
#
#Then COMPREPLY=( $(compgen -W "$sorted_matches" -- "$cur") )
#
#Then __ltrim_colon_completions "$cur"
#
#Return.
#
#Let's write comments.
#
#Edge: if no compgen? but we assume.
#
#Also use local variables.
#
#Complete registration.
#
#Ok produce final bash code.
#...done thinking.

#!/usr/bin/env bash
# Bash completion for `ollama run` that handles model names containing colons.

_ollama_completions() {
    # Ensure we only provide completions for the `ollama` command.
    if [[ "${COMP_WORDS[0]}" != "ollama" ]]; then
        COMPREPLY=()
        return
    fi

    # Retrieve the current and previous words for completion.
    # `_get_comp_words_by_ref -n :` splits on colons to allow completion of
    # model names that include them (e.g., `codellama:13b`).
    # If the helper is not available, fall back to the default COMP_WORDS.
    local cur prev
    if ! _get_comp_words_by_ref -n : cur prev; then
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # Only complete after the `run` subcommand.
    if [[ "$prev" != "run" ]]; then
        COMPREPLY=()
        return
    fi

    # Verify that the `ollama` binary is available.
    if ! command -v ollama >/dev/null 2>&1; then
        COMPREPLY=()
        return
    fi

    # Retrieve the list of models from `ollama list`.
    # The first column contains the model name; skip the header line.
    local -a models=()
    while IFS= read -r name rest; do
        [[ "$name" == "NAME" ]] && continue
        models+=("$name")
    done < <(ollama list)

    # If no models were found, exit early.
    if [[ ${#models[@]} -eq 0 ]]; then
        COMPREPLY=()
        return
    fi

    # Filter the models that match the current word.
    local -a matches=()
    for m in "${models[@]}"; do
        [[ "$m" == "$cur"* ]] && matches+=("$m")
    done

    # If there are no matches, return an empty reply.
    if [[ ${#matches[@]} -eq 0 ]]; then
        COMPREPLY=()
        return
    fi

    # Sort the matching models to provide a consistent completion order.
    local sorted_matches
    sorted_matches=$(printf '%s\n' "${matches[@]}" | sort)

    # Generate the final completion list.
    COMPREPLY=( $(compgen -W "$sorted_matches" -- "$cur") )

    # Trim any leading colons from the display of the completed word.
    # This is crucial for correctly presenting completions such as
    # `codellama:13b` when the user has typed `codellama:`.
    __ltrim_colon_completions "$cur"
}

# Register the completion function for the `ollama` command.
complete -F _ollama_completions ollama


