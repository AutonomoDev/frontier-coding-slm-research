<think>We are asked: "Bash Completion Script Generation Prompt" for "ollama run", that handles model names containing colons. The sample code has colon handling, etc.

We need to produce a robust bash completion script which meets all requirements described. We have the following instructions:

**Task:** Create a robust Bash completion script for `ollama run` command that handles model names containing colons (e.g., codellama:13b, codegemma:7b). 

Given Context:
- Model names are retrieved via ollama list command.
- They often contain colon. We must ensure completions work by saving COMP_WORDBREAKS and removing colon from it in the completion logic then restoring afterwards.

**Requirements:**

1. Colon Handling (MOST IMPORTANT)
   - Code snippet required:
     local old_wb="$COMP_WORDBREAKS"
     COMP_WORDBREAKS=${COMP_WORDBREAKS//:}  # Remove colon
   Then do completion logic.
   At the end, always restore before return/exit.

2. Position Detection: Find exact position of "run" in COMP_WORDS array; only trigger completion when COMP_CWORD equals run_index +1 i.e. when it's the parameter after "run". So we must loop over COMP_WORDS to find index where word is "run", then check if current completion word (COMP_CWORD) equals that index+1.

3. Robust Data Parsing: Models command using ollama list, get the first column for each line skipping header lines and deduplicate models. Use proper awk filtering with variable whitespace. i.e.
   models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | awk '!seen[$0]++')

4. Helper Function Fallback:
   - Get _get_comp_words_by_ref -n : cur prev words cword, if not available, fallback to manually assign variables.
   The snippet provided is: 
   _get_comp_words_by_ref -n : cur prev words cword 2>/dev/null || {
    # Manual fallback when helper unavailable
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
   }
   
5. Safe Filtering:
   Use safe prefix matching: 
   COMPREPLY=($(compgen -W "$models" -- "$cur"))
   Do not use grep because regex issues.

6. No Filename Fallback:
   Register using complete -F _function_name ollama (no -o default).
   Clear COMPREPLY=() when not providing completions.

We then need to output the complete bash script with all required sections, with comments starting with # on every non-code line.

Now we produce a robust Bash completion script that meets requirements. I'll include:

- Function name: _ollama_run_completion or similar. 
- In the function, first check if command is "run" then get index of run in COMP_WORDS array.
  But note: We must detect if current word (COMP_CWORD) equals to run_index+1 i.e. parameter after 'run'.
  
Edge cases: What if ollama list output fails? Then maybe don't produce completions.

I'll create a function called _ollama_run_completion that does:

   - If no "run" in COMP_WORDS, then do nothing.
   - Find index of word "run", store it in variable run_index. Then check if COMP_CWORD equals run_index+1; if not, then return.
   - Save current COMP_WORDBREAKS into old_wb and remove colon from it: COMP_WORDBREAKS=${COMP_WORDBREAKS//:}. 
   - Set old_wb for restoration later.
   - Then use _get_comp_words_by_ref to obtain the variables cur, prev. But if helper not available then fallback assignment.

   - Retrieve models:
      local models
      models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | awk '!seen[$0]++')
   
   - Use compgen -W "$models" -- "$cur" to generate completion candidates.
   - If there is no candidate, then clear COMPREPLY.

   - Finally restore COMP_WORDBREAKS = old_wb before finishing function.

- The script must be ready to source immediately. We need to include the "complete" registration line: complete -F _ollama_run_completion ollama.
  
We'll provide a complete bash script with all these requirements and add comments lines starting with # for every non-code line.

I'll produce code accordingly.

Plan:
```
# Bash Completion Script for "ollama run"
#
# This script provides robust command-line completion for the `ollama run` command,
# handling model names that contain colons. It ensures proper handling of COMP_WORDBREAKS
# by saving and restoring them, and uses safe prefix matching with compgen.
#

_ollama_run_completion() {
  # Find the index of "run" in COMP_WORDS array:
  local run_index=0
  for (( i=0; i<COMP_CWORD; i++ )); do
    if [ "${COMP_WORDS[i]}" = "run" ]; then
      run_index=$i
      break
    fi
  done

  # Only trigger completion if the current word is immediately after "run"
  if [ $COMP_CWORD -ne $((run_index + 1)) ]; then
    return
  fi

  # Save and modify COMP_WORDBREAKS to handle colons in model names
  local old_wb="$COMP_WORDBREAKS"
  COMP_WORDBREAKS=${COMP_WORDBREAKS//:}  # Remove colon from word break characters

  # Retrieve the current completion candidate using helper function if available,
  # fallback otherwise.
  _get_comp_words_by_ref -n : cur prev words cword 2>/dev/null || {
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
  }

  # Retrieve list of model names from "ollama list" command, handling variable whitespace.
  local models
  models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | awk '!seen[$0]++')

  if [ -n "$models" ]; then
    # Generate completion candidates safely using compgen with prefix matching.
    COMPREPLY=($(compgen -W "$models" -- "$cur"))
  else
    # Clear COMPREPLY when no models available.
    COMPREPLY=()
  fi

  # Restore original COMP_WORDBREAKS before returning
  COMP_WORDBREAKS="$old_wb"
}

# Register the completion function for "ollama" command without filename fallback.
complete -F _ollama_run_completion ollama
```

I need to add comments on every non-code line starting with #. Also, each code snippet must be commented appropriately.

I'll produce final answer accordingly in a complete script that can be sourced immediately. I'll ensure no markdown formatting is used by default? The instructions said: "Include clear comments explaining each section" and "Ensure every non-code line starts with #", but the sample says "Script must be ready to source immediately". So I'll include all code as plain text.

I'll produce final answer accordingly.</think>#!/bin/bash
# Bash Completion Script for the "ollama run" command
#
# This script provides robust completion for the "ollama run" command,
# ensuring that model names containing colons (e.g., codellama:13b) are handled correctly.
#
# The script:
#  - Detects the position of the word "run" in the command arguments.
#  - Only triggers completion when the current word is immediately after "run".
#  - Saves and restores COMP_WORDBREAKS to handle colons properly.
#  - Retrieves model names from "ollama list" using robust awk parsing.
#  - Uses compgen for safe prefix matching without filename fallback.

_ollama_run_completion() {
    # Find the index of "run" in the COMP_WORDS array
    local run_index=0
    for (( i=0; i<COMP_CWORD; i++ )); do
        if [ "${COMP_WORDS[i]}" = "run" ]; then
            run_index=$i
            break
        fi
    done

    # Only trigger completion when the current word is immediately after "run"
    if [ $COMP_CWORD -ne $((run_index + 1)) ]; then
        return
    fi

    # Save original COMP_WORDBREAKS and remove colon from it to handle model names with colons
    local old_wb="$COMP_WORDBREAKS"
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}  # Remove colon from word break characters

    # Retrieve the current completion candidate using helper function if available,
    # otherwise fall back to manual assignment.
    _get_comp_words_by_ref -n : cur prev words cword 2>/dev/null || {
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    }

    # Retrieve the list of model names from "ollama list", handling variable whitespace.
    local models
    models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | awk '!seen[$0]++')

    if [ -n "$models" ]; then
        # Generate completion candidates using compgen with safe prefix matching.
        COMPREPLY=($(compgen -W "$models" -- "$cur"))
    else
        # Clear COMPREPLY when there are no models available.
        COMPREPLY=()
    fi

    # Restore the original COMP_WORDBREAKS before returning
    COMP_WORDBREAKS="$old_wb"
}

# Register the completion function for the "ollama" command without filename fallback.
complete -F _ollama_run_completion ollama

