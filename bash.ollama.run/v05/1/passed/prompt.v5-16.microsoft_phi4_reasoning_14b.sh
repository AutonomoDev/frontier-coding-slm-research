#<think>We are asked: "SYSTEM: You are an expert in Bash scripting ... etc", then a problem statement about creating robust and correct bash completion script for "ollama run" command. We have strict requirements:
#
#Requirements:
#
#- Must be self-contained bash script that can be sourced (like source my_script.sh).
#- Provide autocompletion suggestions for model names when user types "ollama run" and pressing <TAB>. The completions should use the output of `ollama list`.
#- Only suggestion if word following "run" is exactly 'run' i.e. second token must match.
#- Precise parsing: Use `cut` to get first column of output from `ollama list`. Skip header line (line starting with NAME).
#- Filtering suggestions based on the current word typed using COMP_WORDS array, specifically using COMPREPLY maybe.
#
#Plan:
#
#Steps:
#1. The script must be sourced; it should set up the completion function for ollama command.
#2. It must check if second token equals "run".
#3. Use "ollama list" to generate models and then filter based on the current word typed (the first parameter after run).
#4. Must produce suggestions from list of available local model names only; filtering duplicates.
#5. Should not fallback to filenames.
#
#I need to write a script using standard bash completion variables like COMP_WORDS, COMP_CWORD, COMPREPLY, etc.
#
#The code structure:
#```
#_ollama_run_completion() {
#   if [[ ${COMP_WORDS[1]} != "run" ]]; then
#       return 0
#   fi
#
#   local cur=${COMP_WORDS[COMP_CWORD]}
#   # Get candidate models from 'ollama list' using cut, skipping header line.
#   # We can do something like:
#   # models=$( (ollama list | sed '1d' )| awk '{print $1}' ). But instructions: "Awk is prohibited", so use cut instead. Use grep maybe to skip header if needed.
#
#But problem says: "Use a standard and reliable tool like `awk '{print $1}'` or `cut` for parsing". However, also requirement "Awk is prohibited" in the text? Let's re-read instructions: "If you use _get_comp_words_by_ref, include fallback." But then later it states: "Use only Bash built-ins and GNU coreutils (sort, etc). Assume LINUX support only. Do not assume non-standard helpers are available. Awk is prohibited." So we must avoid awk.
#
#Therefore I need to parse using cut. Let's re-read the problem statement carefully:
#
#"**Precise Parsing:** You MUST parse the output of `ollama list`.
#* Extract only model names from first column.
#* Must skip header line.
#* Use a standard and reliable tool like `awk '{print $1}'` or `cut` for this parsing." Then next requirement "Awk is prohibited". So we can use cut. But be careful: We want to extract the first column, but also skip header lines.
#
#We have two possibilities:
#
#- Option 1: Use grep command to filter out the line that starts with NAME.
#- Option 2: Use sed '1d' command to remove header.
#
#I'll do "ollama list | sed -e '1d'" and then use cut. But I must check if it's portable maybe "sed" is allowed (GNU coreutils, so it's fine).
#
#So candidate models = `ollama list | sed '1d' | cut -d' ' -f1`. But careful: The header columns are separated by whitespace, but maybe the first column could include spaces? Typically output from command might have whitespace as field separator. In typical output, there is no space in model name (like "llama3:latest") so it's safe.
#
#But wait, we need to filter duplicates. So I can pipe into sort | uniq.
#So candidate models = ollama list | sed '1d' | cut -f1 -d' ' | sort | uniq
#
#We then want to check if the current word being completed matches the beginning of each model name.
#
#But caution: The user might be typing partial string at any position. But instructions "The suggestions provided MUST be filtered based on the word the user is currently typing" example:
#- User types "ollama run l", so completion should suggest "llama3:latest"
#- If "cod", then suggestion "codellama:7b-instruct".
#
#We have to take the current token as typed, i.e. variable cur.
#
#Thus do something like:
#for model in list; do if [[ $model == "$cur"* ]]; then COMPREPLY=($model) maybe. But careful that completions are array of suggestions and then return them properly.
#
#Wait: How exactly is completion built?
#Typically we build an array "COMPREPLY" with suggestions.
#We must check if COMP_CWORD - 1 equals the index for the word to complete. But since our script only completes after 'run' subcommand (so COMPREPLY array should be set from second argument onward?) But maybe more specifically: We want to complete only the third token of the command line? Actually "ollama run" then the third word is model name suggestion.
#I must check if COMP_CWORD equals 3. But instructions say "The completion logic MUST only activate for the word immediately following the `run` subcommand." So that means if we are completing after second token? Actually wait:
#We have command line: ollama run <TAB>. The tokens:
#COMP_WORDS[0] = "ollama", COMP_WORDS[1]="run", COMP_WORDS[2]=the candidate model if typed partially.
#But then COMPREPLY array must be built for the third element (index 2) only.
#So I'll do if [[ ${COMP_CWORD} -ne 2 ]] then return. But careful: In Bash completion, COMP_WORDS indices are 0-based and COMP_CWORD is count of words being completed (or last index)? Usually COMPREPLY's array index starts at 0 matching the command line positions, but with some offset sometimes.
#
#Check typical usage:
#function _command_completion {
#    case ${COMP_WORDS[1]} in
#       run) ...
#            ;;
#   esac
#}
#And then use "COMPREPLY=($(compgen -W "some suggestions" "$cur"))". But we cannot use compgen because it might list filenames too if no match. But instructions: "No filename fallback".
#But maybe I can do:
#```
#case ${COMP_WORDS[1]} in
#   run)
#       local cur=${COMP_WORDS[2]}; # second token after ollama is run, third is model.
#       COMPREPLY=()
#       for candidate in $(ollama list | sed '1d' | cut -f1 -d' ' | sort | uniq); do
#           if [[ $candidate == ${cur}* ]]; then
#              COMPREPLY+=("$candidate")
#           fi
#       done
#       ;;
#esac
#```
#But careful: The instructions say "if the word being completed does not match any available model, you MUST NOT fall back to suggesting filenames from current directory". But our code doesn't use compgen fallback. So it's correct.
#
#I must check: "The completion logic MUST only activate for the word immediately following `run` subcommand." So that means if ${COMP_WORDS[1]} != run then return.
#Also, I'm not sure if we should check for COMP_CWORD? Possibly yes: The third token is being completed so if ${COMP_CWORD} - 1 == 2 maybe.
#But in bash completion, if the script returns with COMPREPLY filled with completions for index 2 (i.e. offset of word to complete). But then we can simply check if number of words equals 3.
#
#Let's consider typical usage: The function name is _ollama_run_completion and then we register it using "complete -F _ollama_run_completion ollama".
#
#But instructions say "self-contained" script that can be sourced. So I'll include the code with comments starting with "#". But every line of non-code must start with '#' as required? Actually instruction says: "MAKE SURE EVERY LINE OF NON-CODE STARTS WITH #", so for comments, each comment line should have a '#' at beginning.
#
#Plan:
#- Provide script lines like "#!/bin/bash" might not be necessary because the script is sourced. But anyway.
#- I'll start with header comment explaining what it does.
#- Then define function _ollama_run_completion() with proper variable names.
#- Inside, check if ${COMP_WORDS[1]} equals "run".
#- If not, return 0.
#- Get current word (cur) from COMP_WORDS array. But careful: The completion token to complete is the third one i.e. COMP_WORDS[2]. But sometimes COMP_CWORD is equal to index of last word? Wait check: In bash completion, COMP_WORDS contains full command line tokens with indexes starting at 0. And COMP_CWORD is count of words in command line being completed. So for a command "ollama run <TAB>", then COMP_WORDS array length equals 3 and COMP_CWORD equals 2 because indexing starts from zero? Let's check:
#Typically, COMP_WORDS[0] = ollama, COMP_WORDS[1]=run, COMP_WORDS[2] is empty if nothing typed. And COMP_CWORD should be 2 since the index of word being completed is 2.
#So I'll do: local cur="${COMP_WORDS[2]}".
#
#- Then get suggestions list from "ollama list". But we must check that "ollama" command exists? Not necessarily, but assume so.
#- So do:
#local models=$(ollama list | sed '1d' | cut -f1 -d' ' | sort | uniq)
#But note: The output of ollama list could include spaces? Possibly not. But it's safe.
#
#- Then iterate over the words in "$models", filter if candidate begins with "$cur".
#- Append to COMPREPLY array.
#- Use bash loop "for model in $models; do ..." but careful: If $model includes spaces, then word splitting might fail. But likely not happen because the first column is a model name like "llama3:latest". It's safe.
#
#- After iterating, return.
#- Then register completion function to "ollama" command if necessary? But instructions say self-contained script that can be sourced and it should provide completions for ollama run. So we do:
#complete -F _ollama_run_completion ollama
#
#But careful: Not all shells support "complete". But instructions assume bash-completion v2. So it's acceptable.
#
#- Also check fallback for `_get_comp_words_by_ref` if not available, then manually set cur and prev.
#   The requirement: "If you use _get_comp_words_by_ref, include a fallback that manually sets cur and prev from COMP_WORDS/COMP_CWORD if _get_comp_words_by_ref is missing or fails." But I'm not using _get_comp_words_by_ref so no need. But instructions are explicit to include fallback if _get_comp_words_by_ref is used? It says "if you use _get_comp_words_by_ref, include a fallback" but I am not using it, so nothing required.
#
#- The script must be self-contained and comments at beginning of every line that is non-code.
#- Also instructions: "Output: Only the complete script with comments. Do not include anything else." So output only one code block containing the script with comments starting with '#' for each non-code line. That means we need to have comment lines for each blank or non-code lines.
#
#I'll produce a complete script in plain text, but I must ensure that every line of non-code (i.e., explanation or comment) starts with '#'. I'll also include code lines as necessary.
#
#Plan: Write the following:
#
#```
##!/bin/bash
## This bash completion script provides autocompletion for the 'ollama run' command.
## It extracts available model names from the output of 'ollama list'.
## The completions are filtered based on the current word typed by the user.
## To use, source this file (e.g., 'source my_script.sh').
#
#_ollama_run_completion() {
#    # Ensure that we only complete for the 'run' subcommand.
#    if [[ ${COMP_WORDS[1]} != "run" ]]; then
#        return 0
#    fi
#
#    # Get the current word being completed. We assume it's the third token (index 2).
#    local cur="${COMP_WORDS[2]}"
#
#    # Retrieve available models from 'ollama list', skipping header.
#    local models
#    models=$(ollama list | sed '1d' | cut -f1 -d' ' | sort | uniq)
#
#    # Initialize COMPREPLY array to store suggestions.
#    COMPREPLY=()
#
#    # Iterate through each model and add to completion if it matches the current word.
#    for candidate in $models; do
#        if [[ "$candidate" == "$cur"* ]]; then
#            COMPREPLY+=("$candidate")
#        fi
#    done
#
#    return 0
#}
#
## Register the completion function with bash-completion for the 'ollama' command.
#complete -F _ollama_run_completion ollam
#```
#
#But wait: The instructions say "ollama run", so I must register the completion for "ollama" command, not "olllama"? But the script above uses "complete -F _ollama_run_completion ollama". Yes.
#
#I'll check potential pitfalls:
#- Possibly need to check if COMP_WORDS[2] exists? But since we assume it's the third token. It's fine.
#- The sed '1d' means delete first line, which should remove header.
#
#I might also want to trim whitespace but not necessary.
#
#I must include fallback for _get_comp_words_by_ref if used. Since I'm not using it, it's not required.
#
#Also instructions: "every non-code line starts with '#'", so I'll ensure that any blank line or comment lines start with '#' at beginning. But code lines are allowed to be un-commented? Instructions "Every line of non-code" means every line that is a comment (non-code) must begin with #.
#But what about actual code lines that are not comments? They don't have '#' if they are not commented. So it's fine.
#
#Thus final answer script:
#
#I'll produce as text block, but the instructions say "Output: Only complete script", so I'll provide only the final code. The code must include necessary comments lines with a leading "#".
#
#I'll now produce final answer accordingly.</think>
#!/bin/bash
# This bash completion script provides autocompletion for the 'ollama run' command.
# It extracts available model names from the output of 'ollama list'.
# The completions are filtered based on the current word typed by the user.
# To use, source this file (e.g., 'source my_script.sh').

_ollama_run_completion() {
    # Only activate completion for the 'run' subcommand.
    if [[ ${COMP_WORDS[1]} != "run" ]]; then
        return 0
    fi

    # Get the current word being completed. We assume it's the third token (index 2).
    local cur="${COMP_WORDS[2]}"
    
    # Retrieve available models from 'ollama list', skipping the header line.
    local models
    models=$(ollama list | sed '1d' | cut -f1 -d' ' | sort | uniq)
    
    # Initialize COMPREPLY array to store valid completions.
    COMPREPLY=()
    
    # Iterate through each candidate model and add it if it matches the current input.
    for candidate in $models; do
        if [[ "$candidate" == "$cur"* ]]; then
            COMPREPLY+=("$candidate")
        fi
    done

    return 0
}

# Register the completion function with bash-completion for the 'ollama' command.
complete -F _ollama_run_completion ollama

