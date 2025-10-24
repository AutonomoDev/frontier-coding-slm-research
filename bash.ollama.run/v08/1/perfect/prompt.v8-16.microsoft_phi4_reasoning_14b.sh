#<think>We need to provide a bash completion script that satisfies the requirements. We have a prompt:
#
#Title: "Bash Completion Script Generation Prompt" which instructs me to produce a robust Bash completion script for "ollama run command".
#
#Task details:
#- It is required that the script handles model names containing colons (e.g., codellama:13b, codegemma:7b).
#- The script must work with bash-completion framework version 2.
#
#Critical Requirements:
#
#1. Colon Handling:
#   - Save and restore COMP_WORDBREAKS in all code paths.
#   - Remove colon from the COMP_WORDBREAKS variable so that completion logic is not broken by colon characters.
#   Specifically:
#   local old_wb="$COMP_WORDBREAKS"
#   COMP_WORDBreaks=${COMP_WORDBreaks//:}
#   then restore afterwards.
#
#2. Position Detection: Find exact position of "run" in COMP_WORDS array; only trigger completion when COMP_CWORD == run_index + 1.
#
#3. Robust Data Parsing:
#   - Use ollama list output to get models, but handle variable whitespace.
#   Use something like: models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | awk '!seen[$0]++')
#   That is the robust approach.
#
#4. Helper function fallback:
#   The script uses _get_comp_words_by_ref -n : cur prev words cword, and if that fails then fallback manually.
#
#5. Safe Filtering: Use compgen with model names list to safe prefix matching; avoid using grep regex issues.
#
#6. No Filename Fallback: register completion with complete -F _function_name ollama (no default option), and clear COMPREPLY when no completions are provided.
#
#Expected Behavior:
#- "ollama run <TAB>" triggers the completions.
#- "ollama run code<TAB>" triggers completions that start with "code"
#- "ollama run codellama:<TAB>" returns models starting with "codellama:"
#- "ollama run xyz<TAB>" returns no completions if there is no match.
#
#Script must be ready to source immediately, so we need a complete script. It should only include code lines and comments lines that start with "#". The code is expected output: the entire bash script.
#
#Let's produce the script accordingly. We'll create function _ollama_run_completion maybe? Possibly name it _ollama_run. Then register completion using "complete -F _ollama_run ollama".
#
#Plan:
#
#- Write a shell function called _ollama_run or similar.
#- In the function:
#    - Save COMP_WORDBREAKS and remove colon from it.
#    - Determine position of command word "run" in COMP_WORDS.
#      For each index, if COMP_WORDS[i] equals "run", then set run_index = i. Then check if COMP_CWORD is exactly run_index + 1.
#
#- If not (i.e., if completion not triggered on model argument), then clear COMPREPLY and return.
#
#- Use _get_comp_words_by_ref to get current word being completed or fallback with manual extraction from COMP_WORDS[COMP_CWORD] etc.
#
#- Then use "ollama list" command to get models.
#   - The robust parsing: models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | awk '!seen[$0]++')
#   But careful with the fact that AWK doesn't have seen array, we can do a trick by using sort or similar.
#   Wait, we need to ensure unique model names. The sample script uses: models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | awk '!seen[$0]++')
#   But AWK usually does not have arrays unless using a different AWK version? I recall that gawk supports associative arrays.
#   Alternatively, we can use "sort -u" if we are using bash.
#
#   Let's check sample: models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | sort -u)
#   That is more robust in many cases.
#
#   But the requirements say to do:
#     models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | awk '!seen[$0]++')
#   We can use that if AWK supports arrays (which usually gawk does). I'll keep with instructions.
#
#- Then safe prefix matching using compgen -W "$models" -- "$cur".
#
#- Finally, restore COMP_WORDBREAKS and return.
#
#- Comments: every non-code line must start with "#", so every comment is preceded by "#". We need to ensure that the script is complete code that can be sourced directly.
#
#Let's produce a complete code snippet. I'll call it _ollama_run_completion or similar, but maybe simpler name: _ollama_run.
#
#I will produce something like:
#
##!/bin/bash
## Bash Completion for ollama run command
#
#_ollama_run() {
#  # Save current COMP_WORDBREAKS and remove colon from them to handle model names with colons.
#  local old_wb="$COMP_WORDBREAKS"
#  COMP_WORDBREAKS=${COMP_WORDBREAKS//:}
#
#  # Find the index of "run" in COMP_WORDS
#  local run_index=0
#  for (( i=0; i<COMP_CWORD; i++ )); do
#    if [ "${COMP_WORDS[$i]}" = "run" ]; then
#      run_index=$((i))
#      break
#    fi
#  done
#
#  # Only trigger completion if we are completing the model argument, i.e., COMP_CWORD == run_index + 1
#  if [ "$COMP_CWORD" -ne "$((run_index+1))" ]; then
#    COMPREPLY=()
#    return 0
#  fi
#
#  # Retrieve current word being completed using bash completion helper.
#  local cur prev words cword
#  _get_comp_words_by_ref -n : cur prev words cword 2>/dev/null || {
#      cur="${COMP_WORDS[COMP_CWORD]}"
#      prev="${COMP_WORDS[COMP_CWORD-1]}"
#  }
#
#  # Retrieve model list from ollama list command.
#  local models
#  models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | sort -u)
#
#  # Filter completions based on the current prefix, ensuring safe matching.
#  COMPREPLY=( $(compgen -W "$models" -- "$cur") )
#
#  # Restore COMP_WORDBREAKS
#  COMP_WORDBREAKS="$old_wb"
#}
#
## Register completion for ollama command using our _ollama_run function.
#complete -F _ollama_run ollama
#
#That is the entire code. But let's check each requirement:
#- Colon handling: Save and restore COMP_WORDBREAKS. We do that at top of function.
#
#- Position detection: We find "run" index, then check if COMP_CWORD == run_index+1.
#
#- Robust data parsing: use 'ollama list 2>/dev/null | awk 'NR>1 {print $1}' | sort -u' (or we can stick to the provided command with second awk using array seen, but I think sort -u is acceptable. The instruction says:
#   models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | awk '!seen[$0]++')
#   But then said "WRONG: Fragile to spacing", so use that robust parsing.
#
#   However, we can check if the AWK command works. The sample code says:
#
#   models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | awk '!seen[$0]++')
#   But then note "Robust Data Parsing" section: it shows that sample code is correct.
#
#   So maybe I'll use the exact sample:
#     models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | awk '!seen[$0]++')
#
#   I think I'll do that. But then note that AWK might not support arrays if it's old version but I'm assuming gawk is used.
#
#- Helper function fallback: we use _get_comp_words_by_ref -n : cur prev words cword.
#
#- Safe filtering: Use compgen with safe prefix matching.
#
#- No filename fallback: Register with complete -F and no default option. We do that at the end.
#
#- Expected behavior: With "ollama run <TAB>" etc, it should work.
#
#Thus I'll produce the script.
#
#I need to ensure every non-code line starts with '#' which means each comment line must start with '#'.
#
#Also include a note for immediate sourcing.
#
#I'll produce code with # comments at beginning of file.
#
#I might also add a header comment like: "# Bash completion script for ollama run command" etc.
#
#I can write:
## This script provides bash completions for the 'ollama run' command, handling model names with colons.
## It must be sourced in your shell environment to enable the completions.
#
#Yes. I'll produce that as output.
#
#Let's produce the final answer.</think>#!/bin/bash
# Bash completion script for the "ollama run" command.
# This script handles model names containing colons (e.g., codellama:13b) and works with bash-completion framework v2.
#
# To enable, source this file in your shell configuration.

_ollama_run() {
    # Save current COMP_WORDBREAKS and remove colon to properly handle model names with colons
    local old_wb="$COMP_WORDBREAKS"
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}

    # Only trigger completions when completing the model argument for "ollama run"
    if ! ([ "${COMP_WORDS[1]}" = "run" ] && [ "$COMP_CWORD" -eq 2 ]); then
        COMPREPLY=()
        return 0
    fi

    # Retrieve the current word being completed using bash completion helper.
    local cur prev words cword
    _get_comp_words_by_ref -n : cur prev words cword 2>/dev/null || {
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    }

    # Retrieve the list of models from "ollama list" command.
    # Use robust parsing to handle variable whitespace and ensure uniqueness.
    local models
    models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | awk '!seen[$0]++')

    # Filter completions safely using compgen with the provided model prefix.
    COMPREPLY=( $(compgen -W "$models" -- "$cur") )

    # Restore COMP_WORDBREAKS before exiting.
    COMP_WORDBREAKS="$old_wb"
}

# Register the completion function for the "ollama" command without filename fallback.
complete -F _ollama_run ollama

