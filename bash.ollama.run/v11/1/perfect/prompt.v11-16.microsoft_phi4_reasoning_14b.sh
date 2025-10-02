#!/bin/bash
#<think>We are asked: "Bash Completion Script Generation Prompt", task is: "Create a robust Bash completion script for the `ollama run` command that dynamically completes model names retrieved from the `ollama list` command. The script must handle model names containing colons (e.g., `codellama:13b`, `codegemma:7b`) without breaking due to Bash's default word-splitting behavior on colons."
#
#We have instructions:
#- The code is a single contiguous block of valid Bash code.
#- It should be no extra commentary outside source code comments. So the entire script output must be code with inline comments explaining each step, but not additional text.
#- Must strictly adhere to "ABSOLUTELY NO COMMENTARY OR EXPLANATORY TEXT outside of the source code comments themselves."
#
#I'll produce a script that defines function `_ollama_completions` with proper checks and completions. Let's break down details.
#
#We need:
#1) function `_ollama_completions`
#2) Check if command is "ollama" and previous word is "run". If not, return early.
#3) For colon handling: Use `if ! _get_comp_words_by_ref -n : cur prev; then` fallback using standard COMP_WORDS parsing
#   Actually code snippet:
#   ```
#   local cur prev
#   if ! _get_comp_words_by_ref -n : cur prev; then
#       cur="${COMP_WORDS[COMP_CWORD]}"
#       prev="${COMP_WORDS[COMP_CWORD-1]}"
#   fi
#   ```
#
#4) If `prev` is "run", generate completions. Retrieve model names using `ollama list`. Use awk or while loop to parse first column, skipping header.
#5) Filter matches from array iteration and pattern matching against `$cur`, sort them.
#6) Then assign completion candidates to COMPREPLY with compgen -W "$sorted_matches" -- "$cur".
#7) After setting COMPREPLY, call `__ltrim_colon_completions "$cur"`.
#
#8) Register completions: complete -F _ollama_completions ollama
#
#9) Comments inline code.
#
#10) Check if command exists before calling it. Also handle empty output gracefully.
#
#Let's produce a script:
#```
##!/bin/bash
## define function _ollama_completions
#_ollama_completions() {
#    # Only complete for "ollama run"
#    local cur prev words cword
#    if ! _get_comp_words_by_ref -n : cur prev; then
#        cur="${COMP_WORDS[COMP_CWORD]}"
#        prev="${COMP_WORDS[COMP_CWORD-1]}"
#    fi
#
#    # Check that command is 'ollama' and previous word is 'run'
#    # We need to check the first two words of COMP_WORDS.
#    if [[ "${COMP_WORDS[0]}" != "ollama" || "${prev}" != "run" ]]; then
#        return 0
#    fi
#
#    # Check if ollama command exists
#    if ! command -v ollama >/dev/null 2>&1; then
#        return 0
#    fi
#
#    # Retrieve model names from 'ollama list' command, skip header line.
#    local models
#    models=$(ollama list 2>/dev/null | awk 'NR > 1 {print $1}')
#
#    # If no models found or error occurred, exit without completions.
#    if [[ -z "$models" ]]; then
#        return 0
#    fi
#
#    # Split models into array using IFS (space tab newline) but careful with colons inside.
#    local model_array=()
#    while IFS= read -r line; do
#      model_array+=("$line")
#    done <<< "$models"
#
#    # Filter matches: iterate over model_array to find entries starting with cur.
#    local suggestions=()
#    for m in "${model_array[@]}"; do
#        if [[ "$m" == "$cur"* ]]; then
#            suggestions+=("$m")
#        fi
#    done
#
#    # Sort the suggestions (if not already sorted) and join them into a space-separated string.
#    local sorted_matches
#    IFS=$'\n' read -r -d '' -a arr <<< "$(printf "%s\n" "${suggestions[@]}" | sort -u)"
#    sorted_matches="${arr[*]}"
#
#    # Generate completions using compgen with word list of models matching current input.
#    COMPREPLY=( $(compgen -W "$sorted_matches" -- "$cur") )
#
#    # Adjust colon-separated completion display.
#    __ltrim_colon_completions "$cur"
#}
#complete -F _ollama_completions ollama
#```
#
#We must also include inline comments. And we have to produce a single contiguous block of code.
#
#I'll produce final answer accordingly, ensuring no markdown formatting. We must produce exactly one continuous block of code with all comments included, but not additional commentary outside source code comments. No extra text beyond the code.
#
#I can output code in a code block? But instructions: "Your response must be ONLY the Bash code." So I'll provide just code.
#
#I'll produce a single code block in plain text with no markdown formatting. The assistant answer says: "Don't include additional commentary."
#
#Thus I'll produce:
#
#```
##!/bin/bash
## _ollama_completions: Provides dynamic completions for 'ollama run' command.
#_ollama_completions() {
#    # Define local variables for current and previous words.
#    local cur prev
#
#    # Use bash-completion helper to get the current word and previous word with colon handling.
#    if ! _get_comp_words_by_ref -n : cur prev; then
#        # Fallback: use standard COMP_WORDS parsing if helper is unavailable.
#        cur="${COMP_WORDS[COMP_CWORD]}"
#        prev="${COMP_WORDS[COMP_CWORD-1]}"
#    fi
#
#    # Ensure we're completing for 'ollama run'.
#    if [[ "${COMP_WORDS[0]}" != "ollama" || "${prev}" != "run" ]]; then
#        return 0
#    fi
#
#    # Verify that the 'ollama' command exists.
#    if ! command -v ollama >/dev/null 2>&1; then
#        return 0
#    fi
#
#    # Retrieve list of models from 'ollama list', skipping header row.
#    local model_list
#    model_list=$(ollama list 2>/dev/null | awk 'NR > 1 {print $1}')
#
#    # If no models found or command failed, exit without completions.
#    if [[ -z "$model_list" ]]; then
#        return 0
#    fi
#
#    # Read model names into an array while preserving colons.
#    local models=()
#    while IFS= read -r line; do
#        models+=("$line")
#    done <<< "$model_list"
#
#    # Build an array of suggestions matching the current input prefix.
#    local suggestions=()
#    for model in "${models[@]}"; do
#        if [[ "$model" == "$cur"* ]]; then
#            suggestions+=("$model")
#        fi
#    done
#
#    # Sort and remove duplicates from suggestions.
#    IFS=$'\n' read -r -d '' -a sorted_models <<< "$(printf "%s\n" "${suggestions[@]}" | sort -u)"
#
#    # Generate completion candidates using compgen with the filtered model names.
#    COMPREPLY=( $(compgen -W "${sorted_models[*]}" -- "$cur") )
#
#    # Adjust colon-separated completions display to avoid word splitting issues.
#    __ltrim_colon_completions "$cur"
#}
#
## Register the completion function for 'ollama' command.
#complete -F _ollama_completions ollama
#```
#
#I'll produce final answer code in a single block with no markdown formatting. We'll ensure that inline comments are present as required.
#
#I'll produce final answer now.</think>
# _ollama_completions: Provides dynamic completions for the 'ollama run' command.
_ollama_completions() {
    # Define local variables to hold the current and previous words.
    local cur prev

    # Attempt to retrieve the current and previous word using bash-completion helper,
    # ensuring proper handling of colons in model names.
    if ! _get_comp_words_by_ref -n : cur prev; then
        # Fallback: use standard COMP_WORDS parsing when _get_comp_words_by_ref is unavailable.
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # Only complete if the command is 'ollama' and the previous word is 'run'.
    if [[ "${COMP_WORDS[0]}" != "ollama" || "${prev}" != "run" ]]; then
        return 0
    fi

    # Check that the 'ollama' command exists before proceeding.
    if ! command -v ollama >/dev/null 2>&1; then
        return 0
    fi

    # Retrieve available model names from 'ollama list', skipping the header line.
    local model_list
    model_list=$(ollama list 2>/dev/null | awk 'NR > 1 {print $1}')

    # If no models are returned, exit gracefully without completions.
    if [[ -z "$model_list" ]]; then
        return 0
    fi

    # Read each line of the model list into an array while preserving colons.
    local models=()
    while IFS= read -r line; do
        models+=("$line")
    done <<< "$model_list"

    # Build an array of suggestions that match the current input prefix.
    local suggestions=()
    for model in "${models[@]}"; do
        if [[ "$model" == "$cur"* ]]; then
            suggestions+=("$model")
        fi
    done

    # Sort the suggestions and remove duplicates to ensure a clean completion list.
    IFS=$'\n' read -r -d '' -a sorted_models <<< "$(printf "%s\n" "${suggestions[@]}" | sort -u)"

    # Generate COMPREPLY using compgen with the sorted model names.
    COMPREPLY=( $(compgen -W "${sorted_models[*]}" -- "$cur") )

    # Adjust colon-separated completions display to avoid Bash's word-splitting issues.
    __ltrim_colon_completions "$cur"
}

# Register the completion function for the 'ollama' command.
complete -F _ollama_completions ollama
