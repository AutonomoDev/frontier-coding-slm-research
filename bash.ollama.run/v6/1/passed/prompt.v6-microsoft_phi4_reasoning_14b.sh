#<think>We are to produce a robust and correct Bash completion script for command "ollama run", which requires that suggestions come from parsing "ollama list" command output, and only complete model names in the first column after skipping header lines. We must use bash-completion v2 syntax and variables like COMP_WORDS etc.
#
#Plan: Write a self-contained bash completion script with comment lines starting with "#". The code should be commented so each non-code line starts with "#".
#
#We need to parse "ollama list" output using `cut` command, then filter suggestions by current word typed. Also the instructions say that the script must only complete if first word is "ollama", second word is "run". That means in COMP_WORDS index 1,2 maybe. However note: Bash uses indexes starting at 0? But conventionally COMP_WORDS[0] = command name, then subsequent words.
#
#We need to check that the current word being typed belongs to the "ollama run" pattern. Actually requirement says: The script must provide autocompletion suggestions for model names when a user types `ollama run` and then press tab. So in our code we want to complete only if COMP_WORDS[1] equals "run", i.e., check that first word is "ollama" (which is always the command name) and second word is "run". But note: Actually maybe we need to ensure that the previous word is exactly "run"? The instruction says check that first word is "ollama" and the previous word ("prev") is exactly run. So our code must check if COMP_WORDS[1] equals "run".
#
#Wait, careful: In bash completion scripts using COMP_WORDS array indexing from 0. Typically index 0 will be the command name (ollama), then index 1 will be subcommand "run". So we want to check that $COMP_WORDS[1] is exactly run. But instructions say that "previous word" should be "run". Possibly means that if $COMP_CWORD equals 2? But I think it's simpler: If [ ${COMP_WORDS[0]} != ollama ] then exit. And if [ ${COMP_WORDS[1]} != "run" ] then exit.
#
#But instructions say to complete only when command word "ollama run", not for any other subcommands or for file completions.
#
#The logic:
#- check if "$COMP_WORDS" length is at least 2, and COMP_WORDS[0] equals "ollama" and COMP_WORDS[1] equals "run".
#- Then get the current partial word to complete.
#- Use _get_comp_words_by_ref if available, with fallback. So I'll check if declare -F _get_comp_words_by_ref returns something then call it else set cur manually.
#
#We need to extract model names from "ollama list" output using "cut".
#The typical output: first column is the model name. But note: "NAME                            ID              SIZE    MODIFIED" header must be skipped.
#We can use grep to skip header, or perhaps we can do: ollama list | sed '1d' then pipe cut with a proper field separator? However instructions say to use `cut`.
#Maybe we want something like:
#models=$(ollama list | cut -d' ' -f1) but careful: The first column might be padded if there are spaces. So better to do: ollama list | tail -n +2 then pipe into "cut -f1" (the field separator is whitespace, so use `cut -d' ' -f1`).
#We want unique suggestions, so we can put them in an array maybe deduping with sort -u if needed.
#
#But note: The command "ollama list" output may have multiple spaces and the first column might be more than one field. But instructions say to use only cut.
#
#Plan:
#- Get completions as a space-separated string variable suggestions.
#- Filter based on current word typed. Use pattern matching with grep -F maybe?
#- Actually requirement says that if user types "cod" then complete models starting with cod, so we can do something like:
#    case-insensitive match? The instructions don't specify but probably it's exact substring search. But likely should be a prefix match: so use grep -F -- "$cur".
#
#I must check that suggestions are only unique. So maybe I'll store them in an array and then sort -u, or just using grep might filter duplicates automatically? But careful: If "ollama list" returns the same model twice, not likely.
#- But instructions say to ensure no duplicate entries.
#
#I need to ensure standard bash-completion v2 syntax:
#Typically we do:
#
#_ollama_run_completion() {
#  # check if command line matches: first word is "ollama" and second word is "run"
#  local cur prev words cword
#  if ! _get_comp_words_by_ref -n : cur prev; then
#      # fallback manual set of cur and prev from COMP_WORDS:
#      cur="${COMP_WORDS[COMP_CWORD]}"
#      prev="${COMP_WORDS[COMP_CWORD-1]}"
#  fi
#
#  # Only complete suggestions for ollama run <model>
#  if [[ ${COMP_WORDS[0]} != "ollama" || ${COMP_WORDS[1]} != "run" ]]; then
#    return
#  fi
#
#  # get list of models from "ollama list", skipping header
#  local model_list=$(ollama list | tail -n +2 | cut -d' ' -f1)
#
#  # Filter suggestions: only those that start with $cur. But instructions say filtered by the word user is currently typing, not necessarily prefix match?
#  # Actually "if the user types 'ollama run cod', then completion should complete models starting with 'cod'. That means we want to filter lines where column begins with "$cur".
#  local suggestions
#  suggestions=$(echo "$model_list" | tr ' ' '\n' | grep -F -- "$cur")
#
#  COMPREPLY=( $(compgen -W "${suggestions}" -- "$cur") )
#}
#complete -F _ollama_run_completion ollama
#
#That is the basic structure.
#
#I need to ensure each non-code line starts with "#". So I'll produce comments lines starting with "#".
#
#Let's start script:
#
##!/usr/bin/env bash
## This script provides autocompletion for the "ollama run" command using the bash-completion framework.
## It parses model names from the output of "ollama list", skipping header, and filters suggestions based on current word.
#
#Then code lines.
#
#I must include fallback for _get_comp_words_by_ref. So we check if declare -F _get_comp_words_by_ref returns non-empty then call it, otherwise use manual assignment.
#We can do:
#if ! _get_comp_words_by_ref -n : cur prev; then
#    cur="${COMP_WORDS[COMP_CWORD]}"
#    prev="${COMP_WORDS[COMP_CWORD-1]}"
#fi
#
#But note that COMP_WORDS is always available. But I need to check if _get_comp_words_by_ref is missing.
#
#I can do:
#if type _get_comp_words_by_ref &> /dev/null; then
#   _get_comp_words_by_ref -n : cur prev;
#else
#   cur="${COMP_WORDS[COMP_CWORD]}"
#   prev="${COMP_WORDS[COMP_CWORD-1]}"
#fi
#
#But instructions say "if you use _get_comp_words_by_ref, include a fallback that manually sets `cur` and `prev` if it is missing or fails." So do:
#
#if declare -F _get_comp_words_by_ref > /dev/null 2>&1; then
#    if ! _get_comp_words_by_ref -n : cur prev; then
#         cur="${COMP_WORDS[COMP_CWORD]}"
#         prev="${COMP_WORDS[COMP_CWORD-1]}"
#    fi
#else
#   cur="${COMP_WORDS[COMP_CWORD]}"
#   prev="${COMP_WORDS[COMP_CWORD-1]}"
#fi
#
#But instructions say "if you use _get_comp_words_by_ref, include a fallback". So do that.
#
#Then check if COMP_WORDS[0] is "ollama" and COMP_WORDS[1] equals "run", else return. But note: If we want to match the command words exactly, then we require at least 2 words in $COMP_WORDS.
#I can do:
#if [[ "${COMP_WORDS[0]}" != ollama ]] || [[ "${COMP_WORDS[1]}" != run ]]; then
#   return 1
#fi
#
#We must complete only if the command is "ollama run". But instructions said check that first word is "ollama" and previous word (prev) equals "run", but maybe it's better to check COMP_WORDS[1]. Possibly we can check using both methods, but I'll check COMP_WORDS[1] equals "run".
#
#Then get the model_list from "ollama list" command:
#model_list=$(ollama list | tail -n +2 | cut -d' ' -f1)
#
#Now filter based on $cur. But careful: If $cur is empty maybe then we want suggestions for all models?
#But instructions: The script should suggest completions if the user types "ollama run", then a tab triggers suggestion of all available model names. So even if cur is empty, then it should list all.
#Thus I'll use grep -F "$cur" on each line.
#
#So do:
#suggestions=$(echo "$model_list" | tr ' ' '\n' | grep -F -- "$cur")
#
#But note: The output from cut might have multiple models separated by whitespace? But since we are using tail then cut, the field separator is whitespace and may contain spaces in model names with colon. Actually instructions say "use cut to parse", so I can do:
#ollama list | tail -n +2 | cut -d' ' -f1
#This will output a line of multiple tokens separated by whitespace (which might be ambiguous if the first column contains extra spaces). But we assume that model names are not containing leading/trailing white space, but they can contain colons. So it's safe.
#
#But then suggestions variable is a list of models from each token. But then we must remove duplicates.
#We want unique suggestions. We can use sort -u. For instance:
#unique_suggestions=$(echo "$suggestions" | tr ' ' '\n' | sort -u)
#
#I'll do that.
#Then I need to complete the word using compgen, like:
#COMPREPLY=( $(compgen -W "${unique_suggestions}" -- "$cur") )
#That is standard.
#
#But check: The script might be a function _ollama_run_completion or similar.
#So declare function _ollama_run_completion() and then add "complete -F _ollama_run_completion ollama".
#
#I need to include comments in each non-code line, meaning lines starting with "#". So I'll put comment on each line that is not code? But instructions say: "MAKE SURE EVERY LINE of non-code STARTS WITH #." That means every comment must begin with '#' so maybe I'll ensure the script's comments all have "#".
#
#I need to include a shebang? Possibly yes.
#
#Let's produce complete code:
#
##!/usr/bin/env bash
## This script provides autocompletion for the "ollama run" command using the bash-completion framework.
## It parses model names from the output of "ollama list", skipping header lines, and filters suggestions based on the current word being typed.
#
#_ollama_run_completion() {
#    # Declare variables to hold the current completion word and previous word.
#    local cur prev
#    if declare -F _get_comp_words_by_ref &>/dev/null; then
#        # Use _get_comp_words_by_ref for Bash-completion v2 compatibility.
#        if ! _get_comp_words_by_ref -n : cur prev; then
#            # Fallback: manually set current and previous words from COMP_WORDS array.
#            cur="${COMP_WORDS[COMP_CWORD]}"
#            prev="${COMP_WORDS[COMP_CWORD-1]}"
#        fi
#    else
#        # Fallback if _get_comp_words_by_ref is not available.
#        cur="${COMP_WORDS[COMP_CWORD]}"
#        prev="${COMP_WORDS[COMP_CWORD-1]}"
#    fi
#
#    # Only complete for the "ollama run" command (first word must be "ollama" and second word must be "run").
#    if [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]; then
#        return 1
#    fi
#
#    # Retrieve the list of local models from "ollama list", skipping the header line.
#    local model_line
#    model_line=$(ollama list | tail -n +2)
#
#    # Extract only the first column (model names) using cut.
#    local model_list
#    model_list=$(echo "$model_line" | cut -d' ' -f1)
#
#    # Filter suggestions based on the current word being typed.
#    # Split the model list into lines and perform a fixed-string match.
#    local filtered_models
#    filtered_models=$(echo "$model_list" | tr ' ' '\n' | grep -F -- "$cur")
#
#    # Remove duplicate entries by sorting uniquely.
#    local unique_suggestions
#    unique_suggestions=$(echo "$filtered_models" | sort -u)
#
#    # Generate the completion suggestions using compgen.
#    COMPREPLY=( $(compgen -W "${unique_suggestions}" -- "$cur") )
#}
#
#complete -F _ollama_run_completion ollama
#
#That should do it.
#
#I must ensure each non-code line starts with "#". So I'll check: Each comment has a preceding "#", and code lines don't need to start with # but that's acceptable.
#
#Double-check logic:
#- When the user types "ollama run" then COMP_WORDS[0] is "ollama", COMP_WORDS[1] is "run".
#- When the user types partial model name, e.g. "cod", then cur becomes "cod".
#- We get "ollama list | tail -n +2" returns lines starting with maybe a header row removed? Actually "tail -n +2" means from line 2 onward.
#- Then cut -d' ' -f1 will extract field 1 of each line. That should be the model name if no extra spaces.
#- Then echo "$model_list" splits by space, then grep for fixed string match on $cur.
#- If cur is empty (i.e., when user just typed "ollama run"), then grep returns all lines? Actually grep with pattern "" might not return empty string, so check: grep -F -- "$cur" if $cur is empty. Let's test: echo "something" | grep -F -- "". It doesn't match because the regex would be empty. So we need to handle case when cur is empty: maybe use compgen -W "$model_list" but that might fail if model_list is empty.
#- But instructions say: When user types "ollama run", then a tab should complete all models, not require prefix matching.
#So I can do:
#if [[ -z "$cur" ]]; then
#    unique_suggestions=$(echo "$model_list" | tr ' ' '\n' | sort -u)
#else
#    filtered_models = grep...
#- But instructions say "filtered based on the current word", and if cur is empty, that means list all suggestions. So I'll do:
#
#if [[ -z "$cur" ]]; then
#   unique_suggestions=$(echo "$model_list" | tr ' ' '\n' | sort -u)
#else
#   unique_suggestions=$(echo "$model_list" | tr ' ' '\n' | grep -F -- "$cur" | sort -u)
#fi
#
#That is better.
#
#I'll update the code accordingly:
#
#    # Filter suggestions based on the current word being typed.
#    local filtered_models unique_suggestions
#    if [[ -z "$cur" ]]; then
#        # If no prefix is entered, list all models uniquely.
#        unique_suggestions=$(echo "$model_list" | tr ' ' '\n' | sort -u)
#    else
#        # Filter the model names that start with or contain the current word.
#        filtered_models=$(echo "$model_list" | tr ' ' '\n' | grep -F -- "$cur")
#        unique_suggestions=$(echo "$filtered_models" | sort -u)
#    fi
#
#That should do.
#
#I'll now produce final code script. I'll not include markdown formatting as requested, just plain text.
#I'll produce the answer as plain text with code block maybe but instructions say "by default plain text".
#
#I'll produce final code below.</think>#!/usr/bin/env bash
# This script provides autocompletion for the "ollama run" command using the bash-completion framework.
# It parses model names from the output of "ollama list", skipping header lines, and filters suggestions based on the current word being typed.

_ollama_run_completion() {
    # Declare local variables to hold the current and previous completion words.
    local cur prev
    if declare -F _get_comp_words_by_ref &>/dev/null; then
        # Use _get_comp_words_by_ref for Bash-completion v2 compatibility.
        if ! _get_comp_words_by_ref -n : cur prev; then
            # Fallback: manually set current and previous words from COMP_WORDS array.
            cur="${COMP_WORDS[COMP_CWORD]}"
            prev="${COMP_WORDS[COMP_CWORD-1]}"
        fi
    else
        # Fallback if _get_comp_words_by_ref is not available.
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # Only complete suggestions when the command is "ollama run" (first word must be "ollama" and second word "run").
    if [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]; then
        return 1
    fi

    # Retrieve the list of local models from "ollama list", skipping the header line.
    local model_line
    model_line=$(ollama list | tail -n +2)
    
    # Extract only the first column (model names) using cut.
    local model_list
    model_list=$(echo "$model_line" | cut -d' ' -f1)
    
    # Filter suggestions based on the current word being typed.
    local filtered_models unique_suggestions
    if [[ -z "$cur" ]]; then
        # If no prefix is entered, list all models uniquely.
        unique_suggestions=$(echo "$model_list" | tr ' ' '\n' | sort -u)
    else
        # Otherwise, select only those model names that match the current word (fixed-string match).
        filtered_models=$(echo "$model_list" | tr ' ' '\n' | grep -F -- "$cur")
        unique_suggestions=$(echo "$filtered_models" | sort -u)
    fi

    # Generate the completion suggestions using compgen.
    COMPREPLY=( $(compgen -W "${unique_suggestions}" -- "$cur") )
}

complete -F _ollama_run_completion ollama

