#<think>We need to produce a bash script that is a completion for "ollama run" subcommand only, with all instructions given in the prompt. It must include comments and code, but we are not supposed to include any text outside of code. We must output pure Bash code.
#
#I'll check instructions carefully:
#
#User message: The assistant is asked to produce a bash script that handles completions for "ollama run" command. Requirements step by step:
#1) function _ollama_completions
#2) Check if first word is "ollama" and previous word is "run", else exit.
#3) Handle colons splitting: use _get_comp_words_by_ref -n : cur prev; if that fails, fallback to using COMP_WORDS[COMP_CWORD] for current completion, and similarly for previous. But must check exactly that condition.
#
#Step by step:
#- The function should be something like:
#
#function _ollama_completions() {
#    # Check subcommand: first word "ollama" and second word "run"
#    if [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]; then
#         COMPREPLY=()
#         return 0
#    fi
#
#But wait, careful reading: It says check if first word is not "ollama" OR prev is not "run", then set COMPREPLY empty. But note the code sample given in instructions says "if the first word is not 'ollama' or prev is not 'run', set COMPREPLY=() and return early." So it's like: if [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]. But careful: COMP_WORDS has indices from 0 to n. But instructions say first word is ollama, second word is run.
#
#- Then colon handling. The code must try:
#if ! _get_comp_words_by_ref -n : cur prev; then
#    # fallback to basic
#    local current_word and previous_word are set using COMP_WORDS[COMP_CWORD] etc.
#So we have something like:
#
#if ! _get_comp_words_by_ref -n : cur prev 2>/dev/null; then
#   cur="${COMP_WORDS[COMP_CWORD]}"
#   prev="${COMP_WORDS[COMP_CWORD-1]}"
#fi
#
#But note: _get_comp_words_by_ref is part of bash-completion. So if that fails, we use fallback.
#
#We can check function definition in our script with:
#
#if ! type _get_comp_words_by_ref >/dev/null 2>&1; then
#   # maybe just skip? But instructions require a fallback.
#But instructions say: "Try `if ! _get_comp_words_by_ref -n : cur prev; then`" So we check if not available, use fallback.
#
#Maybe code:
#
#if ! _get_comp_words_by_ref -n : cur prev; then
#    local cur="${COMP_WORDS[COMP_CWORD]}"
#    local prev="${COMP_WORDS[COMP_CWORD-1]}"
#fi
#
#Then complete logic:
#If prev is "run": then check that the command "ollama" exists: using if command -v ollama &>/dev/null. If not, set COMPREPLY=() and return.
#
#Then run `ollama list 2>/dev/null` output to an array maybe? But instructions say: "Run ollama list and read it line by line in a while loop." It can be done with something like:
#
#models=() # local array for model names
#while IFS= read -r line; do
#   if [[ "$line" == NAME* ]]; then continue, skip header. But note instructions says "skip header 'NAME ID SIZE MODIFIED' and empty lines". So check if the line equals "NAME ID SIZE MODIFIED" or is empty.
#
#   But we need to extract first column with awk: We can do `model=$(echo "$line" | awk '{print $1}')` then add that if not empty.
#done < <(ollama list 2>/dev/null)
#
#But instructions say: "Use 'awk '{print $1}'" or similar. So I'll use:
#models=()
#while IFS= read -r line; do
#    # skip header and empty lines
#    if [[ "$line" == NAME* ]] || [[ -z "$line" ]]; then continue; fi
#    model=$(echo "$line" | awk '{print $1}')
#    models+=("$model")
#done < <(ollama list 2>/dev/null)
#
#Then check if models array is empty. So check: if ${#models[@]} -eq 0, then set COMPREPLY=() and return.
#
#Next, create an array "matches". But instructions says: "Make another array for matches: loop through models, add if it starts with "$cur"." So we iterate over each model in "models" array, check if string begins with cur. But careful: the colon splitting: since our current word may be empty or not, but that's fine.
#
#So do something like:
#matches=()
#for m in "${models[@]}"; do
#   if [[ "$m" == "$cur"* ]]; then
#       matches+=("$m")
#   fi
#done
#
#Then sort the matches. But instructions say: "Sort the matches before using compgen, to make suggestions orderly." So we can use an array sorted_matches computed by:
#sorted_matches=$(printf '%s\n' "${matches[@]}" | sort)
#
#But then set COMPREPLY with "compgen -W "$sorted_matches" -- "$cur"". But note that compgen is a builtin command. However, caution: The variable $cur contains the current partial word typed.
#
#Now final step: After setting COMPREPLY, always call __ltrim_colon_completions "$cur". So do:
#
#__ltrim_colon_completions "$cur"
#
#And then complete function returns.
#
#Finally, register completion for "ollama" command using:
#complete -F _ollama_completions ollama
#
#Add comments in code explaining each part.
#
#Edge case: The instructions say "Only complete model names after 'ollama run'". So check if not matching condition then COMPREPLY=() and return early. We must check first two words from COMP_WORDS.
#
#I'll produce a bash code script that is pure text with no markdown formatting, but we are allowed to output plain text as the answer message.
#
#I'll generate code:
#
#We need function _ollama_completions () {
#   local cur prev
#   # Check if subcommand "run" is used after "ollama"
#   if [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]; then
#         COMPREPLY=()
#         return 0
#   fi
#
#   # Attempt to use bash-completion function _get_comp_words_by_ref with no colon splitting
#   if ! _get_comp_words_by_ref -n : cur prev; then
#       local cur="${COMP_WORDS[COMP_CWORD]}"
#       local prev="${COMP_WORDS[COMP_CWORD-1]}"
#   fi
#
#   if [[ "$prev" != "run" ]]; then
#       COMPREPLY=()
#       return 0
#   fi
#
#   # Check that 'ollama' command exists before proceeding
#   if ! command -v ollama &>/dev/null; then
#         COMPREPLY=()
#         return 0
#   fi
#
#   local models=()    # array to hold model names from ollama list output
#   while IFS= read -r line; do
#       # Skip header and empty lines
#       if [[ "$line" == NAME* ]] || [[ -z "$line" ]]; then continue; fi
#       # Extract first column (model name) using awk
#       local model=$(echo "$line" | awk '{print $1}')
#       models+=("$model")
#   done < <(ollama list 2>/dev/null)
#
#   if [ ${#models[@]} -eq 0 ]; then
#         COMPREPLY=()
#         return 0
#   fi
#
#   # Build matches array: add model names starting with current word fragment
#   local matches=()
#   for m in "${models[@]}"; do
#       if [[ "$m" == "$cur"* ]]; then
#           matches+=("$m")
#       fi
#   done
#
#   # Sort the match suggestions
#   local sorted_matches=$(printf '%s\n' "${matches[@]}" | sort)
#
#   COMPREPLY=( $(compgen -W "$sorted_matches" -- "$cur") )
#
#   # Critical colon fix: trim completions if necessary to handle colons correctly.
#   __ltrim_colon_completions "$cur"
#}
#
## Register the completion function with bash-completion for "ollama" command
#complete -F _ollama_completions ollama
#
#I need to check details: There is a comment about fallback: Use local variables. And "Always call __ltrim_colon_completions $cur" after setting COMPREPLY.
#
#I'll produce the code exactly as required, with proper comments and no markdown formatting outside the code block.
#
#Be careful that function name is _ollama_completions exactly. And using complete -F _ollama_completions ollama registers for "ollama". So output code should be exactly that.
#
#I'll now produce final answer.</think>#!/bin/bash
# Bash completion script for "ollama run"
# Only completes model names from "ollama list" after the "run" subcommand.
# This script handles colons properly by using _get_comp_words_by_ref with -n :,
# and calls __ltrim_colon_completions to fix colon splitting issues.

_ollama_completions() {
    # Local variables for current word (cur) and previous word (prev)
    local cur prev

    # Check that the command is "ollama" and the subcommand is "run"
    if [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]; then
        COMPREPLY=()
        return 0
    fi

    # Attempt to use bash-completion's _get_comp_words_by_ref with no colon splitting (-n :)
    if ! _get_comp_words_by_ref -n : cur prev; then
        # Fallback: use COMP_WORDS directly since _get_comp_words_by_ref is unavailable
        local cur="${COMP_WORDS[COMP_CWORD]}"
        local prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # If the previous word is not "run", do nothing.
    if [[ "$prev" != "run" ]]; then
        COMPREPLY=()
        return 0
    fi

    # Check that the 'ollama' command exists before proceeding.
    if ! command -v ollama &>/dev/null; then
        COMPREPLY=()
        return 0
    fi

    # Read the output of "ollama list" and extract only model names (first column)
    local models=()
    while IFS= read -r line; do
        # Skip header row and empty lines.
        if [[ "$line" == NAME* ]] || [[ -z "$line" ]]; then
            continue
        fi
        # Extract the first field (model name) using awk.
        local model
        model=$(echo "$line" | awk '{print $1}')
        models+=("$model")
    done < <(ollama list 2>/dev/null)

    # If no models were found, exit early.
    if [ ${#models[@]} -eq 0 ]; then
        COMPREPLY=()
        return 0
    fi

    # Build an array of matches: model names starting with the current word fragment.
    local matches=()
    for m in "${models[@]}"; do
        if [[ "$m" == "$cur"* ]]; then
            matches+=("$m")
        fi
    done

    # Sort the match suggestions to ensure order.
    local sorted_matches
    sorted_matches=$(printf '%s\n' "${matches[@]}" | sort)

    # Generate completions using compgen with the sorted list of model names.
    COMPREPLY=( $(compgen -W "$sorted_matches" -- "$cur") )

    # Critical colon fix: trim any extra characters added due to colon splitting.
    __ltrim_colon_completions "$cur"
}

# Register the completion function for the "ollama" command.
complete -F _ollama_completions ollama

