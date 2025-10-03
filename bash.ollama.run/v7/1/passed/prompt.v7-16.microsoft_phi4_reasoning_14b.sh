#<think>We are given a Bash Completion script generation prompt. The prompt is "Create a robust Bash completion script for the ollama run command that handles model names containing colons (e.g., codellama:13b, codegemma:7b)." This means we need to write out a bash completion script that meets several requirements. We must generate complete bash script that uses a robust algorithm.
#
#Let's re-read instructions carefully:
#
#Task:
#- Create robust Bash completion script for `ollama run` command.
#- Must handle model names containing colons (like codellama:13b, codegemma:7b).
#- Model names are retrieved via "ollama list" command
#- The script must work with bash-completion framework v2.
#
#Critical Requirements:
#
#1. Colon Handling:
#We need to save and restore COMP_WORDBREAKS in every code path.
#Specifically, we have to do:
#```
#local old_wb="$COMP_WORDBREAKS"
#COMP_WORDBREAKS=${COMP_WORDBREAKS//:}  # Remove colon
## ... completion logic ...
#COMP_WORDBREAKS="$old_wb"  # ALWAYS restore before ANY return/exit
#```
#
#2. Position Detection:
#- Find the exact position of "run" in COMP_WORDS array.
#- Only trigger completion when COMP_CWORD == run_index + 1
#- Do not assume fixed positions.
#
#3. Robust Data Parsing:
#We must retrieve model names from ollama list command using:
#```
#models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | awk '!seen[$0]++')
#```
#This is the robust way of parsing because spacing may vary.
#
#4. Helper function fallback:
#We need to use:
#```
#_get_comp_words_by_ref -n : cur prev words cword 2>/dev/null || {
#    # Manual fallback when helper unavailable
#    cur="${COMP_WORDS[COMP_CWORD]}"
#    prev="${COMP_WORDS[COMP_CWORD-1]}"
#}
#```
#
#5. Safe Filtering:
#We need to do safe prefix matching using compgen. So use:
#```
#COMPREPLY=($(compgen -W "$models" -- "$cur"))
#```
#NOT regex filtering.
#
#6. No filename fallback:
#- Register with: `complete -F _function_name ollama` (no `-o default`)
#- Clear COMPREPLY when not providing completions
#
#Expected Behavior Examples:
#If user types "ollama run <TAB>" then completion suggestions appear.
#If they type "ollama run code<TAB>" then suggestions show models starting with "code"
#If they type "ollama run codellama:<TAB>", then suggestions show codellama:13b and codellama:34b
#If no matching completions then output nothing.
#
#Script Requirements:
#- Provide only the complete bash script.
#- Include clear comments explaining each section (every non-code line starts with "#")
#- Script must be ready to source immediately, so it should define function and register completion command.
#
#So overall structure:
#
#We define a bash function, e.g. _ollama_run_completion maybe. Inside the function we want to do following steps:
#a) Save COMP_WORDBREAKS: local old_wb="$COMP_WORDBREAKS" then remove colon from COMP_WORDBREAKS.
#b) Find position of "run" in COMP_WORDS array using a loop over COMP_WORDS indices; i.e. for i in "${!COMP_WORDS[@]}"; do if [ "$word" = "run" ] then record run_index and break; fi done.
#c) Then check if COMP_CWORD equals run_index+1, otherwise return early with COMPREPLY=().
#d) Get current word and previous word using _get_comp_words_by_ref or fallback.
#
#e) Retrieve model list by running `ollama list` command and then parse out the first column (model names). Use robust parsing with awk's NR>1 etc.
#f) Then do compgen safe filtering: COMPREPLY=($(compgen -W "$models" -- "$cur"))
#g) Then restore COMP_WORDBREAKS variable.
#
#h) Register the function with complete command using "complete -F _ollama_run_completion ollama".
#
#Edge case: If not in run mode, then just return.
#
#Maybe also consider that if no models are available, COMPREPLY remains empty.
#We must use safe quotes. Possibly do quoting around variables that contain spaces. But likely model names don't have spaces because they are just the first column output from "ollama list". They can contain colon though, so we need to be careful.
#
#Plan: script:
#
#```
##!/usr/bin/env bash
## This is a robust Bash completion script for the 'ollama run' command.
## It supports model names with colons such as codellama:13b, codegemma:7b.
##
## IMPORTANT: Save and restore COMP_WORDBREAKS to correctly handle colon characters in completions.
#
#_ollama_run_completion() {
#    # Save current word break settings
#    local old_wb="$COMP_WORDBREAKS"
#    # Remove colon from COMP_WORDBREAKS so that colons are treated as normal characters.
#    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}
#
#    # Find the position of "run" in COMP_WORDS array
#    local run_index=-1
#    for index in "${!COMP_WORDS[@]}"; do
#        if [ "${COMP_WORDS[$index]}" = "run" ]; then
#            run_index=$index
#            break
#        fi
#    done
#
#    # Only provide completion if current word is the first argument after "run"
#    if [ $run_index -eq -1 ] || [ "$COMP_CWORD" != "$((run_index + 1))" ]; then
#        COMPREPLY=()
#        COMP_WORDBREAKS="$old_wb"
#        return 0
#    fi
#
#    # Get current and previous words using _get_comp_words_by_ref if available, else fallback
#    if type _get_comp_words_by_ref &>/dev/null; then
#        _get_comp_words_by_ref -n : cur prev words cword
#    else
#        cur="${COMP_WORDS[COMP_CWORD]}"
#        prev="${COMP_WORDS[COMP_CWORD-1]}"
#    fi
#
#    # Retrieve the list of models from 'ollama list'
#    local models
#    models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | awk '!seen[$0]++')
#
#    # Use compgen for safe prefix matching. This ensures that special characters (like ':') are handled properly.
#    COMPREPLY=( $(compgen -W "$models" -- "$cur") )
#
#    # Restore COMP_WORDBREAKS before returning
#    COMP_WORDBREAKS="$old_wb"
#}
#
## Register the completion function with the 'ollama' command without filename fallback.
#complete -F _ollama_run_completion ollama
#
## End of script. This file is ready to be sourced.
#```
#
#That is likely acceptable answer.
#
#I must also include comments for each section. Additionally, every non-code line starts with # which means all lines that are not code should begin with "#", so I'll ensure all commentary lines have a preceding '#'.
#
#The output must only contain the script code (complete bash script). I will now produce final output accordingly. We'll check that it meets all instructions: robust handling of colon, position detection, safe filtering, helper fallback etc.
#
#I will produce final answer in plain text as required.
#
#We need to be careful with variable usage and quoting. Use $(ollama list ...) for models; then do compgen -W "$models" -- "$cur". The models list is a space separated string of model names. I must use quotes around $models, etc. Also note that colon in COMP_WORDBREAKS is removed by: COMP_WORDBREAKS=${COMP_WORDBREAKS//:}. This does not require spaces.
#
#I need to check if any potential issues with the function _get_comp_words_by_ref might cause issues? I can leave that as given fallback.
#
#The script is intended for bash-completion framework v2. So register via complete -F command.
#
#Thus answer:
#
#I'll produce final code with careful comments.</think>#!/usr/bin/env bash
# This Bash completion script provides robust completions for the "ollama run" command.
# It handles model names containing colons (e.g., codellama:13b, codegemma:7b) by adjusting
# COMP_WORDBREAKS so that colons are treated as normal characters during word splitting.

_ollama_run_completion() {
    # Save current COMP_WORDBREAKS to restore later.
    local old_wb="$COMP_WORDBREAKS"
    # Remove colon from COMP_WORDBREAKS to ensure model names with colons are handled correctly.
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}

    # Find the index of "run" in COMP_WORDS array.
    local run_index=-1
    for (( i=0; i<${#COMP_WORDS[@]}; i++ )); do
        if [ "${COMP_WORDS[$i]}" = "run" ]; then
            run_index=$i
            break
        fi
    done

    # Only provide completion when the current cursor position is immediately after "run".
    if [ $run_index -eq -1 ] || [ "$COMP_CWORD" != "$((run_index + 1))" ]; then
        COMPREPLY=()
        COMP_WORDBREAKS="$old_wb"
        return 0
    fi

    # Retrieve the current and previous words using _get_comp_words_by_ref if available.
    if type _get_comp_words_by_ref &>/dev/null; then
        _get_comp_words_by_ref -n : cur prev words cword
    else
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # Retrieve the list of models from "ollama list".
    # Use robust parsing to handle variable whitespace.
    local models
    models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | awk '!seen[$0]++')

    # Generate completions safely using compgen for prefix matching.
    COMPREPLY=( $(compgen -W "$models" -- "$cur") )

    # Restore COMP_WORDBREAKS before returning.
    COMP_WORDBREAKS="$old_wb"
}

# Register the completion function with the "ollama" command without filename fallback.
complete -F _ollama_run_completion ollama

# End of script. This file is ready to be sourced immediately.

