#<think>We are asked: "Bash Completion Script Generation Prompt" which is a prompt instructing us to create a robust Bash completion script for the "ollama run" command that handles model names containing colons. It has many details: context includes sample ollama list output, critical requirements such as colon handling (saving/restoring COMP_WORDBREAKS), etc. We need to produce a complete bash script with clear comments. Requirements are:
#
#1. Colon Handling: In any code path, we must save and restore COMP_WORDBREAKS. So use the line:
#```
#local old_wb="$COMP_WORDBREAKS"
#COMP_WORDBREAKS=${COMP_WORDBREAKS//:}
#...
#COMP_WORDBREAKS="$old_wb"
#```
#
#2. Position Detection: find position of "run" in COMP_WORDS array; trigger only when COMP_CWORD == run_index+1.
#
#3. Robust Data Parsing: Use ollama list, and process output with awk to handle variable whitespace. The sample code is:
#```
#models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | awk '!seen[$0]++')
#```
#
#We must not use cut.
#
#4. Helper function fallback: For COMPREPLY, first try to call _get_comp_words_by_ref if available.
#
#5. Safe filtering: Use compgen with -W "$models" option and -- "$cur".
#
#6. No Filename Fallback: Register with complete -F _function_name ollama (and no default flag).
#
#We must produce a script that is ready to source immediately, meaning that at the end we register completion for "ollama". We include clear comments explaining each section.
#
#I need to output code in plain text without markdown formatting. I'll ensure every non-code line starts with "#".
#
#Let's now construct our solution:
#
#The overall structure: Write a function _ollama_run_completion() maybe.
#- The function must check if the current word (cur) is not empty, then list models from ollama list output.
#
#Pseudo-code:
#
#function _ollama_run_completion()
#{
#   # Save old COMP_WORDBREAKS
#   local old_wb="$COMP_WORDBREAKS"
#   COMP_WORDBREAKS=${COMP_WORDBREAKS//:}
#
#   # determine index of "run" in the command words
#   local run_index=0
#   local i; for ((i = 0; i < ${#COMP_WORDS[@]}; i++)); do
#       if [[ "${COMP_WORDS[i]}" == "run" ]]; then
#           run_index=$i; break;
#       fi
#   done
#
#   # Only proceed if we are completing after "run"
#   if [ "$COMP_CWORD" -ne "$((run_index + 1))" ]; then
#      return 0
#   fi
#
#   # Get the current partial input (cur) using _get_comp_words_by_ref helper if available
#   local cur prev words cword
#   if type _get_comp_words_by_ref &>/dev/null; then
#       _get_comp_words_by_ref -n : cur prev words cword 2>/dev/null || { cur="${COMP_WORDS[COMP_CWORD]}"; }
#   else
#       cur="${COMP_WORDS[COMP_CWORD]}"
#   fi
#
#   # Get the list of models using robust parsing from ollama list.
#   local models
#   models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | awk '!seen[$0]++')
#
#   if [ -n "$cur" ]; then
#       COMPREPLY=($(compgen -W "$models" -- "$cur"))
#   else
#       COMPREPLY=()
#   fi
#
#   # Restore COMP_WORDBREAKS before returning
#   COMP_WORDBREAKS="$old_wb"
#}
#
#Register the function with complete:
#complete -F _ollama_run_completion ollama
#
#I must include comments on each section as required. And every non-code line begins with "#". Let me produce final code accordingly.
#
#I'll output the script text.
#
#I'll check details:
#
#- We need colon handling in all code paths. So at start of function, do:
#   local old_wb="$COMP_WORDBREAKS"
#   COMP_WORDBREAKS=${COMP_WORDBREAKS//:}
#   ... then restore later
#- Also note: we must use COMP_WORDBREAKS restoration always before any return or exit. So at end of function, ensure that line is present.
#- The helper for _get_comp_words_by_ref fallback as well.
#
#I'll produce final code accordingly.
#
#I'll check each bullet:
#
#1. Colon Handling - done in beginning and restore at end.
#2. Position detection: We loop through COMP_WORDS array to find "run". Then if COMP_CWORD != run_index+1, return 0 (i.e., no completion).
#3. Robust Data Parsing: Use ollama list with awk as described.
#
#4. Helper Function Fallback: Use _get_comp_words_by_ref and then fallback to use COMP_WORDS[COMP_CWORD] if not available.
#5. Safe Filtering: Use compgen command
#6. No Filename Fallback: When registering complete, only call complete -F function without default fallback.
#
#I'll produce final code accordingly.
#
#I'll include clear comments explaining each section as required by the prompt.
#
#I must produce output with every non-code line starting with "#".
#
#I'll produce solution in plain text as output. I'll now produce final answer in plain text.</think># Bash Completion Script for "ollama run"
# This script provides robust tab completion for the ollama run command,
# handling model names that include colons (e.g., codellama:13b).

_ollama_run_completion()
{
    # Save current COMP_WORDBREAKS and remove colon characters to allow colon handling
    local old_wb="$COMP_WORDBREAKS"
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}

    # Find the index position of "run" within COMP_WORDS
    local run_index=0
    local i
    for ((i = 0; i < ${#COMP_WORDS[@]}; i++)); do
        if [[ "${COMP_WORDS[i]}" == "run" ]]; then
            run_index=$i
            break
        fi
    done

    # Only trigger completion when the current word index is exactly after "run"
    if [ "$COMP_CWORD" -ne "$((run_index + 1))" ]; then
        # No completion here; return empty suggestion list.
        COMP_WORDBREAKS="$old_wb"
        return 0
    fi

    # Retrieve the current (partial) word being typed using helper function if available;
    # fallback to manual extraction if not.
    local cur prev words cword
    if type _get_comp_words_by_ref &>/dev/null; then
        _get_comp_words_by_ref -n : cur prev words cword 2>/dev/null || {
            cur="${COMP_WORDS[COMP_CWORD]}"
        }
    else
        cur="${COMP_WORDS[COMP_CWORD]}"
    fi

    # Retrieve the list of available models from "ollama list",
    # using awk to handle variable whitespace and duplicates.
    local models
    models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | awk '!seen[$0]++')

    # Generate COMPREPLY options that match the current input (prefix matching)
    if [ -n "$cur" ]; then
        COMPREPLY=($(compgen -W "$models" -- "$cur"))
    else
        COMPREPLY=()
    fi

    # Restore original COMP_WORDBREAKS before returning from the function
    COMP_WORDBREAKS="$old_wb"
}

# Register completion for the ollama command using our _ollama_run_completion function.
complete -F _ollama_run_completion ollama

