#Thinking...
#We need to produce bash code with comments only inside. No external commentary. Ensure function _ollama_completions. Use bash-completion function _get_comp_words_by_ref, but fallback if not present. Also call __ltrim_colon_completions. Use compgen. Must set COMPREPLY. Ensure we check command exists: command -v ollama. If not, return. Also handle empty output. We need to parse 'ollama list' output: first column is model name. We skip header line. Use awk 'NR>1 {print $1}' to get names. Then we iterate to filter matches: use array to collect matches. Use pattern matching: [[ "$model" == "$cur"* ]] or [[ "$model" == *"$cur"* ]]? Usually bash completion uses prefix. So we filter by prefix. Use local arrays.
#
#Edge: Use readarray -t to read names. But use loop.
#
#Implementation:
#
#function _ollama_completions() {
#  local cur prev words cword
#  local -a model_names matches sorted
#
#  # Check if ollama command exists
#  if ! command -v ollama >/dev/null 2>&1; then
#    COMPREPLY=()
#    return 0
#  fi
#
#  # Use bash-completion helper if available
#  if ! _get_comp_words_by_ref -n : cur prev; then
#    cur="${COMP_WORDS[COMP_CWORD]}"
#    prev="${COMP_WORDS[COMP_CWORD-1]}"
#  fi
#
#  # Only complete after 'ollama run'
#  if [[ "$prev" != "run" ]]; then
#    COMPREPLY=()
#    return 0
#  fi
#
#  # Retrieve model names
#  mapfile -t model_names < <(ollama list 2>/dev/null | awk 'NR>1 {print $1}')
#  if (( ${#model_names[@]} == 0 )); then
#    COMPREPLY=()
#    return 0
#  fi
#
#  # Filter matches
#  matches=()
#  for name in "${model_names[@]}"; do
#    if [[ "$name" == "$cur"* ]]; then
#      matches+=("$name")
#    fi
#  done
#
#  if (( ${#matches[@]} == 0 )); then
#    COMPREPLY=()
#    return 0
#  fi
#
#  # Sort matches
#  IFS=$'\n' sorted=$(printf '%s\n' "${matches[@]}" | sort)
#  IFS=$'\n' readarray -t sorted_matches <<<"$sorted"
#
#  # Generate COMPREPLY
#  COMPREPLY=( $(compgen -W "${sorted_matches[*]}" -- "$cur") )
#
#  # Trim colon completions
#  __ltrim_colon_completions "$cur"
#
#  return 0
#}
#
#complete -F _ollama_completions ollama
#
#But need to ensure __ltrim_colon_completions is available. It's part of bash-completion. If not, the call may fail. But requirement is to call. If not loaded, may cause error. Could wrap in if command -v __ltrim_colon_completions. But spec: "call __ltrim_colon_completions" critical. We'll call.
#
#Also note that _get_comp_words_by_ref may not exist. So we need fallback.
#
#Also we need to handle environment where bash-completion is loaded. _get_comp_words_by_ref may require that. We use 'if ! _get_comp_words_by_ref -n : cur prev; then ...'
#
#But _get_comp_words_by_ref returns 1 if not found. So we use !.
#
#Now implement. Ensure local variable names.
#
#Let's craft final code.
#
#Use mapfile if available; but use older read loop to avoid dependencies. Use 'while read -r line; do ...'.
#
#But we can use 'readarray -t model_names' which requires bash 4+. We can assume bash >=4.
#
#Ok.
#
#Let's produce final bash code.
#
#...done thinking.

#!/usr/bin/env bash
# Bash completion script for `ollama run` with support for model names containing colons.

# The function `_ollama_completions` is invoked by the `complete` builtin to generate completions.
# It uses the `bash-completion` helper `_get_comp_words_by_ref` when available, and falls back
# to the raw COMP_WORDS array otherwise.  The helper accepts a `-n :` option to treat
# colons as part of the current word instead of word separators, which is essential for
# completing names like `codellama:13b`.

_ollama_completions() {
    local cur prev
    local -a model_names matches sorted_matches
    local IFS=  # preserve IFS for `readarray` usage

    # -------------------------------------------------------------------------
    # Check that the `ollama` command is available. If not, we abort completion.
    # -------------------------------------------------------------------------
    if ! command -v ollama >/dev/null 2>&1; then
        COMPREPLY=()
        return 0
    fi

    # -------------------------------------------------------------------------
    # Retrieve the current and previous words.  Prefer the `bash-completion`
    # helper, which correctly handles colons when invoked with `-n :`.  If the
    # helper is not present, fall back to the raw COMP_WORDS array.
    # -------------------------------------------------------------------------
    if ! _get_comp_words_by_ref -n : cur prev; then
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # -------------------------------------------------------------------------
    # Only provide completions when the previous word is the subcommand `run`.
    # For any other context we return an empty completion list.
    # -------------------------------------------------------------------------
    if [[ "$prev" != "run" ]]; then
        COMPREPLY=()
        return 0
    fi

    # -------------------------------------------------------------------------
    # Execute `ollama list` to obtain the list of available model names.
    # The first column contains the model name; skip the header row.
    # If the command fails or returns no models, we provide no completions.
    # -------------------------------------------------------------------------
    mapfile -t model_names < <(ollama list 2>/dev/null | awk 'NR>1 {print $1}')
    if (( ${#model_names[@]} == 0 )); then
        COMPREPLY=()
        return 0
    fi

    # -------------------------------------------------------------------------
    # Filter the retrieved model names to those that match the current word.
    # We perform a prefix match (`== "$cur"*`) which is the standard behaviour
    # of Bash completion tools.
    # -------------------------------------------------------------------------
    matches=()
    for name in "${model_names[@]}"; do
        if [[ "$name" == "$cur"* ]]; then
            matches+=("$name")
        fi
    done

    # If nothing matched, return an empty completion list.
    if (( ${#matches[@]} == 0 )); then
        COMPREPLY=()
        return 0
    fi

    # -------------------------------------------------------------------------
    # Sort the matches alphabetically to provide a predictable order.
    # `compgen -W` expects a single string of words separated by spaces,
    # so we construct that string from the sorted array.
    # -------------------------------------------------------------------------
    IFS=$'\n' sorted=$(printf '%s\n' "${matches[@]}" | sort)
    IFS=$'\n' readarray -t sorted_matches <<<"$sorted"

    # -------------------------------------------------------------------------
    # Generate the COMPREPLY array using `compgen`.  The `--` delimiter indicates
    # the end of options for `compgen` and the beginning of the word to match.
    # -------------------------------------------------------------------------
    COMPREPLY=( $(compgen -W "${sorted_matches[*]}" -- "$cur") )

    # -------------------------------------------------------------------------
    # Apply the colon-trimming helper so that completions containing colons
    # are displayed correctly.  Without this call, the completion would
    # incorrectly truncate the part before the colon.
    # -------------------------------------------------------------------------
    __ltrim_colon_completions "$cur"

    return 0
}

# -------------------------------------------------------------------------
# Register the completion function for the `ollama` command.
# -------------------------------------------------------------------------
complete -F _ollama_completions ollama


