#<think>We have a prompt: "Bash Completion Script Generation Prompt" and then instructions. The task is: "Create robust Bash completion script for the `ollama run` command that handles model names containing colons (e.g., codellama:13b, codegemma:7b)". There's a sample output listing models using ollama list command with header lines, but we only want rows after first line.
#
#We are required to include clear comments explaining each section. Also every non-code line must start with "#". The script must be ready to source immediately. We need code that registers the completion function with complete -F _ollama_run ollama. But instructions: "complete -F _function_name ollama" (no "-o default"). So we'll register completions for "ollama run", only when argument is run? Let's check requirements:
#
#- The script uses bash-completion v2 framework.
#
#- It must work with model names containing colons, so careful: COMP_WORDBREAKS. We require to save and restore them.
#
#Specifically instructions say:
#```
## MUST save and restore COMP_WORDBREAKS in ALL code paths
#local old_wb="$COMP_WORDBREAKS"
#COMP_WORDBREAKS=${COMP_WORDBREAKS//:}  # Remove colon
## ... completion logic ...
#COMP_WORDBREAKS="$old_wb"  # ALWAYS restore before ANY return/exit
#```
#We need to do that.
#
#- Position detection: Find the exact position of "run" in COMP_WORDS array. Only trigger completion when COMP_CWORD == run_index + 1.
#
#- Robust Data Parsing: models = $(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | awk '!seen[$0]++') is desired.
#- Use helper function fallback:
#```
#_get_comp_words_by_ref -n : cur prev words cword 2>/dev/null || {
#    # Manual fallback when helper unavailable
#    cur="${COMP_WORDS[COMP_CWORD]}"
#    prev="${COMP_WORDS[COMP_CWORD-1]}"
#}
#```
#
#But the instructions require that we do this.
#
#- Safe Filtering: Use compgen with safe prefix matching, i.e.
#```
#COMPREPLY=($(compgen -W "$models" -- "$cur"))
#```
#
#- No filename fallback: registration: complete -F _function_name ollama (no -o default)
#
#Let's now plan the script:
#
#We'll define a bash completion function called _ollama_run perhaps. In that function, we first determine the index where "run" appears in COMP_WORDS array. That means iterate over COMP_WORDS and find the one equal to run.
#
#We then check if COMP_CWORD equals (index_of_run + 1). If not, return.
#
#Then define a local variable old_wb containing COMP_WORDBREAKS. Then do: COMP_WORDBREAKS=${COMP_WORDBREAKS//:}. But careful: We need to remove colon from the set of word break characters. How? For each character in COMP_WORDBREAKS, we want to filter out ":". So we can use parameter expansion perhaps.
#
#We must store old_wb and then after completion logic, restore it.
#
#Then next step: call helper function _get_comp_words_by_ref if available, else manually compute 'cur' using COMP_WORDS[COMP_CWORD] etc.
#
#But note: If _get_comp_words_by_ref fails or is not available, we do fallback. But instructions require:
#```
#_get_comp_words_by_ref -n : cur prev words cword 2>/dev/null || {
#    # Manual fallback when helper unavailable
#    cur="${COMP_WORDS[COMP_CWORD]}"
#    prev="${COMP_WORDS[COMP_CWORD-1]}"
#}
#```
#But also we need to use the variables properly. The recommended code snippet is exactly that.
#
#Then retrieve models using:
#```
#models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | awk '!seen[$0]++')
#```
#
#We then use compgen:
#```
#COMPREPLY=($(compgen -W "$models" -- "$cur"))
#```
#
#Then restore COMP_WORDBREAKS = old_wb.
#
#Then exit the function.
#
#We also need to register the completion for command "ollama run". But note that we want only run completions when the "run" is provided. So if no argument is "run", then it's not triggered? Actually, instruction says: Only trigger completion when COMP_CWORD equals run_index + 1, so we check if this condition holds.
#
#Let's check further details:
#- If no matching models are found in "ollama list", then COMPREPLY should be empty.
#- Also note that we must use compgen to generate completions. So our code is straightforward.
#
#I'll now produce a complete bash script with all these instructions.
#
#The final code structure:
#
#```
## Bash completion function for ollama run
#_ollama_run() {
#    # Find the index of "run" in COMP_WORDS array
#    local run_index=0 found=0
#    for (( i=0; i < ${#COMP_WORDS[@]}; i++ )); do
#        if [ "${COMP_WORDS[i]}" = "run" ]; then
#            run_index=$i
#            found=1
#            break
#        fi
#    done
#
#    # Only complete after the 'run' argument.
#    if [ $found -eq 0 ] || [ "$COMP_CWORD" -ne "$((run_index + 1))" ]; then
#        return  # Do not complete if "run" not found or not at expected position.
#    fi
#
#    # Save and modify COMP_WORDBREAKS to handle colons in model names.
#    local old_wb="$COMP_WORDBREAKS"
#    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}  # Remove colon from word break characters.
#
#    # Retrieve current word using helper if available
#    if _get_comp_words_by_ref -n : cur prev words cword 2>/dev/null; then
#        :
#    else
#        cur="${COMP_WORDS[COMP_CWORD]}"
#        prev="${COMP_WORDS[COMP_CWORD-1]}"
#    fi
#
#    # Obtain list of models from 'ollama list', filtering duplicates.
#    local models
#    models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | awk '!seen[$0]++')
#
#    # Use compgen to safely filter completions based on prefix matching.
#    COMPREPLY=($(compgen -W "$models" -- "$cur"))
#
#    # Restore COMP_WORDBREAKS
#    COMP_WORDBREAKS="$old_wb"
#}
#
## Register the completion function with bash-completion.
#complete -F _ollama_run ollama
#```
#
#But careful: The instructions require that every non-code line starts with "#". So we must include a comment at top describing the script. Also each code block should have comments above them.
#
#I need to check "OLLAMA list" command is used. And instructions for COMP_WORDBREAKS saving and restoration are included as described.
#
#We might also note that if _get_comp_words_by_ref doesn't exist, we fallback with manual assignment.
#
#Double-check: The script must be robust so it won't fail if ollama list fails? Perhaps it's fine because models is empty then COMPREPLY becomes empty.
#
#I need to check that our code works in bash completion framework v2. That means using complete -F _ollama_run ollama command registration.
#
#We need to check for every non-code line: "Ensure every non-code line starts with #". So we must not produce any blank lines that are not commented? We have some blank lines maybe with comments, but it's fine if they start with "#".
#
#Also the script should be ready to source immediately, so no additional invocation is needed.
#
#I'll now produce final answer.</think>#!/usr/bin/env bash
# This Bash completion script provides completions for the "ollama run" command.
# It handles model names that include colons (e.g., codellama:13b, codegemma:7b).
#
# The script is designed to work with the bash-completion framework v2.
# It carefully saves and restores COMP_WORDBREAKS to allow colon characters in completions.

_ollama_run() {
    # Find the position/index of "run" within the command line words.
    local run_index=0 found=0
    for (( i=0; i<${#COMP_WORDS[@]}; i++ )); do
        if [ "${COMP_WORDS[i]}" = "run" ]; then
            run_index=$i
            found=1
            break
        fi
    done

    # Only provide completions when the current word position is immediately after "run".
    if [ $found -eq 0 ] || [ "$COMP_CWORD" -ne "$((run_index + 1))" ]; then
        return
    fi

    # Save the original COMP_WORDBREAKS.
    local old_wb="$COMP_WORDBREAKS"
    # Remove colon from word break characters to allow colons in model names.
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}

    # Attempt to use bash-completion helper function for retrieving the current and previous words.
    if _get_comp_words_by_ref -n : cur prev words cword 2>/dev/null; then
        :
    else
        # Fallback: manually retrieve the current word (cur) and the previous word (prev).
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # Retrieve a list of unique model names from "ollama list", robust against variable whitespace.
    local models
    models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | awk '!seen[$0]++')

    # Generate completions based on the current word prefix using compgen for safe matching.
    COMPREPLY=($(compgen -W "$models" -- "$cur"))

    # Restore COMP_WORDBREAKS before exiting.
    COMP_WORDBREAKS="$old_wb"
}

# Register the completion function with bash-completion without filename fallback.
complete -F _ollama_run ollama

# End of script.

