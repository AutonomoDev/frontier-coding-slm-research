#<think>We are asked to produce a Bash completion script for ollama run command, meeting multiple requirements:
#
#- The script must be self-contained and can be sourced.
#- It uses `bash-completion` framework v2.
#- It provides autocompletion suggestions for model names when user types "ollama run <TAB>".
#
#The script must use standard variables COMP_WORDS, COMP_CWORD, etc. The logic must only trigger if the second word in COMP_WORDS is exactly "run" (i.e., we check ${COMP_WORDS[1]} == "run"). We need to parse the output of `ollama list` and extract only the first column (which is model names) skipping header line that starts with NAME. Use something like: using awk or cut.
#
#Plan:
#- The script begins with "# bash-completion function for ollama run", then declare _ollama_run_completion maybe.
#- We'll do check if [ ${COMP_CWORD} -eq 2 ] because command is "ollama run" plus maybe additional argument (the model name).
#- The logic: If COMP_WORDS[1] == "run", then we complete the third word. But note: Actually, "ollama run" has two words? Wait:
#   The user types "ollama run <TAB>" so the command line is something like:
#   - COMP_WORDS[0]: ollama
#   - COMP_WORDS[1]: run
#   - And if no model name provided, then COMPREPLY should contain completions.
#- Also check: If COMP_CWORD (which is index of current word) equals 2? But note, it might be that user typed a partial third argument. So we need to check that the second command word (COMP_WORDS[1]) is exactly "run". And then complete third argument.
#
#- Let's say if [ ${#COMP_WORDS[@]} -lt 3 ] or if COMPREPLY is empty? Actually, logic: if COMP_WORDS array length equals 2 and current position is 2. But we can always get suggestions for the model name when there is exactly one word typed after "ollama run". So in our function, we check:
#   if [ ${COMP_CWORD} -eq 2 ] then that means no third argument typed? Actually careful: The number of words is COMP_WORDS[0]=ollama, COMP_WORDS[1]=run. Then the current completion position equals 2 (count starts at index zero). So that's correct.
#
#- We need to generate a list from "ollama list" command output:
#   - Run: `ollama list` and then parse its output lines.
#   - But note: The output might contain header line starting with NAME. Use sed or awk to skip the header line, e.g. using grep -v '^NAME\s'. Actually, we can do something like:
#     models=$(ollama list | tail -n +2 | awk '{print $1}' )
#   Or perhaps use a loop reading lines and then cut by space.
#
#- But note: The text "llama3:latest" is the first column. Use `awk` to print $1.
#- Then filter based on current word:
#   Let current prefix be COMPREPLY candidate partial string from COMP_WORDS[2] if exists else empty string. But actually, we can check if [ ${COMP_CWORD} -eq 2 ] then the current argument is missing, so it's empty.
#   We need to get the current word being completed: _prev=${COMP_WORDS[$COMP_CWORD]} maybe.
#
#- Use "case" or "for each model in list", and if model starts with partial word, add to COMPREPLY array. We can use COMPREPLY=() then for each candidate, do
#  if [[ "$candidate" == "$current_prefix"* ]]; then
#    COMPREPLY+=("$candidate")
#  fi.
#
#- Remove duplicates. But careful: The output might already be unique? Possibly duplicates exist if the same model name is repeated. To remove duplicates, we can use associative arrays or simply check in a while loop that doesn't add duplicate entries. Since Bash version >=4 supports associative array but not all systems have bash-completion might require older bash version? But requirement says standard bash syntax compatible with bash-completion v2. I assume it's fine to use declare -A.
#
#- But we can also simply check if candidate is already in COMPREPLY using e.g., case "$candidate" in " ${COMPREPLY[@]} "* ) then skip, else add.
#
#- But careful: The logic might be not exactly that simple since COMPREPLY is an array of suggestions. We'll do something like:
#   declare -A seen
#   for candidate in ${models}; do
#       if [[ "$candidate" == "${current_word}*" ]]; then
#           if [ -z "${seen[$candidate]}" ]; then
#               COMPREPLY+=("$candidate")
#               seen["$candidate"]=1
#           fi
#       fi
#   done
#
#- But we need to store models as a string list. Also, we can use command substitution with pipe.
#
#- Use "COMPREPLY=( $(ollama list | tail -n +2 | awk '{print $1}' | grep "^${COMP_WORDS[2]}") )"
#  But careful: that is not robust because it might match partial word matching? Actually, the grep pattern "^co" would work. But then we also need to check if there's no suggestion at all.
#
#- Alternatively, use for candidate in $(ollama list ...). For each candidate, test candidate with prefix completion.
#
#- So our code:
#   _ollama_run_completion() {
#       # Check if second argument is "run"
#       if [[ ${COMP_WORDS[1]} != "run" ]]; then
#         return 0
#       fi
#
#       local cur=${COMP_WORDS[2]}
#
#       # Get model names from ollama list, skipping header line:
#       local models=$(ollama list | tail -n +2 | awk '{print $1}')
#       # Now iterate over each candidate:
#       local COMPREPLY=()
#       local seen=""
#       for m in $models; do
#           # Check if candidate starts with current word:
#           if [[ "$m" == "${cur}"* ]]; then
#               # If not already added:
#               case "${COMPREPLY[@]}" in
#                   *"$m"*)
#                       ;;
#                   *)
#                         COMPREPLY+=("$m")
#                       ;;
#               esac
#           fi
#       done
#
#       return 0
#   }
#
#But note: Using case with "COMPREPLY[@]" expansion is weird because if we want to check if m exists in COMPREPLY, then we need to iterate over COMPREPLY array. But since there's no built-in function for array membership in bash v3? We can do a simple loop:
#
#   local duplicate=0
#   for candidate in "${COMPREPLY[@]}"; do
#      if [[ "$candidate" == "$m" ]]; then duplicate=1; break; fi
#   done
#   if [ $duplicate -eq 0 ]; then COMPREPLY+=("$m"); fi
#
#- But that loop is inside the loop over models. That would be O(n^2). But probably it's fine for small arrays.
#
#- Alternatively, we can use declare -A array:
#   declare -A dup
#   then if [ -z "${dup[$m]}" ]; then dup[$m]=1 and COMPREPLY+=("$m") fi.
#   However, associative arrays require Bash version 4. But bash-completion v2 maybe requires bash >= 3?
#- But requirement says "standard Bash" so we assume Bash 4 is available usually nowadays.
#
#- But I'll check if there's any note about using an array to filter duplicate completions.
#  It's recommended that the final list does not contain duplicates. I can use either method.
#
#I might do:
#   declare -A dup
#   for m in $models; do
#     if [[ "$m" == "${cur}"* ]]; then
#         if [ -z "${dup[$m]}" ]; then
#            COMPREPLY+=("$m")
#            dup["$m"]=1
#         fi
#     fi
#   done
#
#- That is more efficient.
#
#- Then complete. Return 0.
#
#- Also check: The script must only activate for "ollama run" subcommand, not "ollama list", so we check if COMP_WORDS[1]=="run". But careful: When the user types 'ollama run', COMP_WORDS[0] is "ollama", [1]="run". So that's correct.
#
#- After defining the function _ollama_run_completion, must register it with the bash completion framework. That means call something like:
#   complete -F _ollama_run_completion ollama
#
#- But careful: The problem says script should be self-contained and can be sourced to enable functionality for command "ollama run". So we need to do: if [ "$BASH" ]; then use complete command.
#
#- Also possibly check the number of words. I'll add a check so that if COMP_CWORD < 2, return.
#
#- But the requirement says only triggered for the word immediately following `run` subcommand. So if COMP_WORDS[1] != "run", do nothing.
#
#- There is additional possibility: If no model name provided then cur might be empty string.
#   In that case, complete with all model names.
#   But if partial match filter doesn't find any suggestions, COMPREPLY remains empty and the function returns 0 so completions are not shown. That is acceptable as per requirement "if word doesn't match any available models, no suggestions".
#
#- I'll add comments in code.
#
#- The script must be self-contained and only contain complete script with comments.
#
#I produce a complete bash completion script file that includes:
#   #!/usr/bin/env bash
#   but not necessary because it's going to be sourced. But can include a comment that this is the script for ollama run completion.
#
#- I'll also ensure that our function _ollama_run_completion uses local variable names with lower-case, using double quotes.
#
#- Also careful: When reading output of `ollama list`, maybe we want to use "tail -n +2" to skip header line. That should be robust if header is the first line. Alternatively, we can grep out lines that start with NAME or "NAME", but tail is simpler.
#
#- The command ollama list might not exist sometimes? But not our problem: We assume it's available and output as described.
#
#- I'll also include some comment for usage instructions.
#
#The final script:
#
#----------------------
##!/bin/bash
## Bash completion script for the 'ollama run' command using bash-completion framework v2
#
#_ollama_run_completion() {
#    # Only complete if second word is "run"
#    if [[ "${COMP_WORDS[1]}" != "run" ]]; then
#        return 0
#    fi
#
#    # Get the current argument being completed (third word)
#    local cur="${COMP_WORDS[2]:-}"
#
#    # Retrieve available model names from 'ollama list' output, skipping header line.
#    # Use tail -n +2 to skip first line, and awk to print the first column.
#    local models
#    models=$(ollama list | tail -n +2 | awk '{print $1}')
#
#    # Array for completions; also use associative array to avoid duplicates.
#    COMPREPLY=()
#    declare -A seen
#
#    # Iterate over each model name and add if it matches the current prefix.
#    for model in $models; do
#        # Check if model starts with the current word being typed (case-sensitive)
#        if [[ "$model" == "$cur"* ]]; then
#            if [ -z "${seen[$model]}" ]; then
#                COMPREPLY+=("$model")
#                seen["$model"]=1
#            fi
#        fi
#    done
#
#    return 0
#}
#
## Register the completion function for 'ollama run'
#complete -F _ollama_run_completion ollama
#
#----------------------
#
#- That is essentially the answer.
#
#I will produce the complete script with comments, not extra text. The output must be "Only the complete script" so I'll provide final script code.
#
#I'll now produce final answer.</think>
#!/usr/bin/env bash
# Bash completion script for the 'ollama run' command.
# This script provides model name autocompletion by parsing the output of 'ollama list'.
#
# Requirements:
# 1. It only triggers when the second word is "run".
# 2. It parses 'ollama list', skipping the header, and extracts only the first column (model names).
# 3. Suggestions are filtered based on what the user currently types.
# 4. No fallback to file completions if no model matches.
# 5. Duplicates in suggestions are avoided.

_ollama_run_completion() {
    # Only complete if the second word is "run"
    if [[ "${COMP_WORDS[1]}" != "run" ]]; then
        return 0
    fi

    # Get the current argument being completed (the model name)
    local cur="${COMP_WORDS[2]:-}"

    # Retrieve available model names from 'ollama list', skipping the header line.
    # The first column is extracted using awk.
    local models
    models=$(ollama list | tail -n +2 | awk '{print $1}')

    # Initialize completion suggestions and an associative array to track duplicates.
    COMPREPLY=()
    declare -A seen

    # For each model name, if it starts with the current word being typed,
    # add it to the COMPREPLY array (if not already added).
    for model in $models; do
        if [[ "$model" == "$cur"* ]]; then
            if [ -z "${seen[$model]}" ]; then
                COMPREPLY+=("$model")
                seen["$model"]=1
            fi
        fi
    done

    return 0
}

# Register the completion function for the 'ollama' command.
complete -F _ollama_run_completion ollava

