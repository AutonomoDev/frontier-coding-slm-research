#!/bin/bash

# [[HUMAN COMMENTED-OUT]]
#<think>We are asked to generate a bash script that does completions for `ollama run` command. The script should be written as a function _ollama_completions, etc.
#
#Let's read the instructions: There is a "Bash Completion" script with key tasks to do:
#
#It says: "Make script for `ollama run <model>`:" - so completions only model argument, handling colons. It handles colon completion.
#
#The script should be as follows:
#- Must check if command called is "ollama run". So the first two words must match "ollama" and "run".
#- Also check that COMP_CWORD (the word count index) equals 2.
#- Then retrieve `cur` with _get_comp_words_by_ref -n : . If not available, fallback to default using COMP_WORDS array.
#
#- The script should then get models: by running command: if command -v ollama exists then use "ollama list" output. We parse it from tail -n +2 because header is first line. Then we use awk '{print $1}' to get model names.
#- Next, sort them and generate COMPREPLY completions using compgen -W "<models>" -- "$cur".
#
#- After completion, check if __ltrim_colon_completions exists and call it.
#
#- At the end, register completions: complete -F _ollama_completions ollama
#
#Edge handling for missing command "ollama", or no models should be considered.
#
#- The code must include inline comments with key parts.
#
#We are asked to output only bash code. So I'll produce a bash code block.
#
#I'll now produce the script as a code snippet, following instructions exactly. We need to check that we follow steps:
#
#Step 1: Function _ollama_completions().
#
#Within function:
#Check if ${COMP_WORDS[0]} != "ollama" or ${COMP_WORDS[1]} != "run". If not match then set COMPREPLY=() and return 0.
#Then check if COMP_CWORD equals 2; if not, return 0. But the instructions in bullet point say: "[[ $COMP_CWORD -ne 2 ]] && return 0;".
#
#Wait careful: The text says:
##[[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return 0; }
#[[ $COMP_CWORD -ne 2 ]] && return 0;
#```
#
#We then set local variables: local cur prev. Then if type _get_comp_words_by_ref &>/dev/null exists, then call it to get variables.
#If not exist, fallback.
#
#Then parse:
#local models=()
#Then if command "ollama" is available, run "ollama list 2>/dev/null" and then pipe tail -n +2 to remove header line. Then use awk '{print $1}' to get the model names. So something like: `models=($(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}'))`.
#- There is possibility that command returns no models so we have an empty array.
#
#Then sort models:
#Sort them using IFS=$'\n' and then set variable. The instructions say: "Sort: IFS=$'\n' models=($(sort <<<"${models[*]}")); unset IFS". So I'll do exactly that.
#
#Then use compgen to fill COMPREPLY array with completions: `COMPREPLY=( $(compgen -W "${models[*]}" -- "$cur") )`.
#- Then check if type __ltrim_colon_completions exists, and call it.
#Finally end function.
#
#After that we need to register the function as completion for "ollama" command by calling complete -F _ollama_completions ollama. 
#But instructions says: "complete -F _ollama_completions ollama".
#
#So I'll produce code accordingly:
#
#```
#_ollama_completions() {
#    # Only activate if the first two words are 'ollama' and 'run'
#    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return 0; }
#    # Only complete when there is exactly one argument to complete (model)
#    [[ $COMP_CWORD -ne 2 ]] && return 0
#
#    # Get current word and previous word using _get_comp_words_by_ref if available
#    local cur prev
#    if type _get_comp_words_by_ref &>/dev/null; then
#        _get_comp_words_by_ref -n : cur prev
#    else
#        cur="${COMP_WORDS[COMP_CWORD]}"
#        # prev not used further, but required for compatibility
#        prev="${COMP_WORDS[COMP_CWORD-1]}"
#    fi
#
#    # Get list of models from 'ollama list' command output (skip header)
#    local models=()
#    if command -v ollama &>/dev/null; then
#        models=($(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}'))
#    fi
#
#    # Sort the model names
#    IFS=$'\n'
#    models=($(sort <<<"${models[*]}"))
#    unset IFS
#
#    # Generate completion options using compgen with word list from models array
#    COMPREPLY=( $(compgen -W "${models[*]}" -- "$cur") )
#
#    # Trim completions if needed for colon based completions
#    if type __ltrim_colon_completions &>/dev/null; then
#        __ltrim_colon_completions "$cur"
#    fi
#}
#
#complete -F _ollama_completions ollama
#```
#
#I'll now produce code with inline comments. The code must be only bash code. I'll produce output as a single block of script.
#
#Edge conditions: if "ollama" command is missing, then models becomes empty array and compgen won't complete anything, but that's acceptable.
#
#We can produce code accordingly. I'll produce the final answer.</think>

# _ollama_completions: Completion function for "ollama run <model>"
_ollama_completions() {
  # Only activate if first two words are "ollama" and "run"
  [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return 0; }
  # Only complete when exactly one argument (the model) is being completed
  [[ $COMP_CWORD -ne 2 ]] && return 0

  # Retrieve current word and previous word for colon handling.
  local cur prev
  if type _get_comp_words_by_ref &>/dev/null; then
    _get_comp_words_by_ref -n : cur prev
  else
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
  fi

  # Parse the available models from "ollama list" (skip header)
  local models=()
  if command -v ollama &>/dev/null; then
    models=($(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}'))
  fi

  # Sort model names for consistent order
  IFS=$'\n'
  models=($(sort <<<"${models[*]}"))
  unset IFS

  # Generate completions using compgen with the list of sorted models
  COMPREPLY=( $(compgen -W "${models[*]}" -- "$cur") )

  # If available, trim colon-based completions so that the colon is inserted correctly
  if type __ltrim_colon_completions &>/dev/null; then
    __ltrim_colon_completions "$cur"
  fi
}

# Register completion for "ollama" command
complete -F _ollama_completions ollama
