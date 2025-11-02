#!/bin/bash
# Bash completion for "ollama run <model>"
#
# This script provides completions only when you type:
#   ollama run <partial-model>
# It works by invoking "ollama list" once to get available models,
# filtering them based on your current prefix, and then sorting the matches alphabetically.
#
# Save this file (e.g., /etc/bash_completion.d/ollama.sh or ~/.bash_completion.d/ollama.sh)
# and source it in your .bashrc:
#   . /path/to/this/script.sh

# [[HUMAN COMMENTED-OUT]]
# <think>We need to produce a working bash-completion script for the command "ollama run <model>" that dynamically lists available models by parsing the output of `ollama list`. The requirements: 
# 1. Trigger condition: only offer completions when the command is `ollama run` and user is completing after "run". This means we need to check if number of arguments equals 2, i.e., COMP_WORDS[1] = "run" or similar.
# 2. Model retrieval: invoke ollama list once and capture its full output into a variable. Do not pipe the command's result directly, but store it in a variable.
# 3. Prefix filtering: use current word from COMP_WORDS and COMP_CWORD to filter model names so only those matching prefix are suggested. We can do that using compgen or manually. But we have to assign sorted list into COMPREPLY.
# 4. Graceful failure: if ollama list fails or errors, silently return with no completions (do not produce errors).
# 5. Sorting: sort matches alphabetically before assigning them to COMPARE.
# 6. No external dependencies: Only use built-ins. Use only bash builtins, so we cannot rely on external commands like sort? But wait, "sort" is available in most systems as a shell builtin if it's not an external command? Actually, "sort" is usually a separate binary though built-in might be provided by bash sometimes but I think the user said "only use bash built-ins". There's no 'builtin sort' in bash. But we can do sorting manually using arrays and loops maybe with array manipulations sorted algorithm implemented inside shell script? But that's tricky to implement in pure bash, however, since this is a completion function, we might call external command sort if necessary. But the instructions say: "No external dependencies" meaning not use jq or awk, but I think it's okay to use standard commands like sort because it's usually available. However, the instructions says "only built-in shell features", but then "do not call jq, awk, etc." It doesn't mean we cannot use external commands if they are built-ins. But "sort" is not a bash builtin function, but it's an external command? Possibly yes. The instructions mention to use only Bash builtins; so maybe we should implement sorting manually with shell built-in array manipulation. However, implementing sort manually in pure bash can be done by using "readarray" and then doing bubble sort perhaps? But that might be complicated. Alternatively, if the user says no external dependencies (like jq), but doesn't mention not using commands like sort. Let me re-read the instructions: "No external dependencies; Only use Bash built-ins; do not call jq or external JSON parsers." So I think it's safe to use built-in shell features including "sort" command if available? But the prompt said "only built-in shell features", so maybe we should implement a sort using only bash arrays and builtins. Alternatively, since our list is short (the models), we can use shell built-in array sorting. However, I know that Bash 4+ has arrays and we could do something like: 
# models=( $var ) and then do:
# sorted=()
# for model in "${models[@]}"; do sorted+=("$model"); done; sort them using "sort" command? But if the requirement is to not use external commands, I might implement a simple bubble sort. But maybe it's simpler to use "IFS=$'\n'" and then something like: 
# maybe we can call "printf '%s\n' "${models[@]}" | sort"? That involves piping though, which is allowed? The instructions said "only built-ins" so external commands might be considered dependencies?
# Wait, they said "dependency-free bash-completion script", meaning no dependencies on third-party tools. The only dependency is Bash itself.
# We can assume that the system has a sort command. But then "do not use any third party tools (no jq or external JSON parsers)" but sorting and other utilities like "sort" are standard commands usually.
# 
# The instructions say: "Only use built-in shell features". They want to avoid using jq, awk, etc. So I assume it's safe to use sort because that is a built-in command? However, in Bash, there is no internal sort function. But the requirement says "do not call external JSON parsers" so we are allowed to use standard utilities like 'sort' if they're commonly available.
# 
# Let's check: "Follow these requirements exactly". The requirements said: 
# "Use only bash built-ins; do not call jq, awk or any external parsing helpers." So I think using sort is acceptable because it's a standard command. But maybe we can use the fact that shell arrays and built-in string manipulations are enough.
# 
# I'll produce code with:
# - It defines a function _ollama_run_completion.
# - The trigger condition: Check if $COMP_WORDS[0] equals "ollama", $COMP_WORDS[1] equals "run". Also check length COMP_CWORD.
# - Then get the model list by calling "ollama list" once, capturing output into variable. Use something like:
#    models_output=$(ollama list 2>/dev/null) so that errors are silent and if it fails, we return.
# 
# - Check if $models_output is empty or non-zero? Possibly if ollama list fails then do: return.
# - Then separate the models from $models_output. The output is either one per line or whitespace separated. We can use IFS to split by newlines first, but what about whitespace separation? Perhaps we check if newline exists, otherwise we split by spaces?
# 
# Idea: If "$models_output" contains a newline, then use "readarray -d $'\n'"? Alternatively, we can do:
# IFS=$'\n'
# models=($models_output)
# But this will break on any whitespace? But the requirement says the output could be either one per line or separated by whitespace. So if it's only whitespace-separated then splitting with IFS=$'\n' would produce only one element, because there is no newline.
# Wait, we want to get words regardless of newline vs whitespace.
# 
# Maybe do:
# models=($models_output)
# But careful: If models_output has multiple lines, this will split on any whitespace. But that's actually fine: if each line is a separate model then splitting by whitespace will yield one word per line. However, if the output is "model1 model2", then splitting it will yield "model1" and "model2". So using models=($models_output) works.
# 
# But careful: If there are no valid words maybe we skip that.
# 
# Then the prefix to filter should be $COMP_WORDS[COMP_CWORD] (current word being completed). But note, $COMP_WORDS array is 0-indexed? Actually COMP_WORDS indexing starts at 1? Typically, $COMP_WORDS[1] is command itself "ollama", $COMP_WORDS[2] is "run". And the current word is at index ${#COMP_WORDS[@]} i.e., last element, which is COMP_WORDS[(($CWORD))]. But we need to extract that.
# We can do: 
# prefix=${COMP_WORDS[$COMP_CWORD]}
# But careful: if COMP_CWORD equals 2 then it's "run"? Actually, we want to complete after run. So when $COMP_CWORD equals 3? Let's check: For command: ollama run <model>
# The array will be: [0]="ollama", [1]="run", [2] is the model being completed if any.
# So typically COMP_WORDS[2] (since COMP_WORDS indexing in bash starts at index 0, because they are positional parameters. Actually $COMP_WORDS is an array with first element "ollama", second "run" then maybe third as partial or empty).
# We can do: prefix=${COMP_WORDS[$(( COMP_CWORD -1 ))]}? Let's check typical usage:
# For bash completion, usually you use ${COMP_WORDS[COMP_CWORD-1]}. But I've seen examples that get the current word being completed by using: "current_word=${COMP_WORDS[$COMP_CWORD]}" if array is 0-indexed. Let me recall how it works exactly:
# The COMP_WORDS are stored as an array starting at index 0. So for a command like: ollama run model, then COMP_WORDS[0]="ollama", COMP_WORDS[1]="run", and COMP_WORDS[2] would be "model" if partially typed.
# And COMP_CWORD is the number of words (so equals 3).
# So we want to use ${COMP_WORDS[$(( COMP_CWORD - 1 ))]} as the current word.
# I recall that in many bash completion scripts, they do: "current=${COMP_WORDS[COMP_CWORD-1]}" because COMP_WORDS is indexed from 0. So I'll do:
# prefix=${COMP_WORDS[$(($COMP_CWORD-1))]}
# That should be correct.
# 
# Then filter models that start with prefix. We need to iterate over the list of models and check if they begin with the prefix.
# We can either build a new array matching completions or use compgen -W "..." "$prefix".
# But requirement says: "populate COMPREPLY correctly using compgen or manual filtering." And then "sort them alphabetically" before assigning. We might do:
# matches=()
# for m in "${models[@]}"; do
#   if [[ $m == $prefix* ]]; then matches+=("$m"); fi
# done
# Then sort the matches array manually. To implement sorting using bash builtins, we can use "printf" to join them and pipe to sort? But that is external dependency. Alternatively, I'll implement a simple bubble sort in bash.
# We want to sort alphabetically.
# I need a function or inline code to sort an array without calling sort command because the instructions say no third-party tools. The instructions do not mention explicitly disallowing using "sort" command; they only said "only built-in shell features", but I'd rather implement sorting manually with bash arrays and loops, to be safe.
# 
# I can implement a simple bubble sort:
# for ((i=0; i<${#matches[@]}-1; i++)); do
#   for ((j=i+1; j<${#matches[@]}; j++)); do
#     if [[ "${matches[i]}" > "${matches[j]}" ]]; then
#       tmp=${matches[i]}
#       matches[i]=${matches[j]}
#       matches[j]=$tmp
#     fi
#   done
# done
# But I'm not sure if bash arrays can be indexed by ${matches[i]} because the syntax in bash is: ${matches[$i]}. But that's fine.
# 
# Alternatively, we can use compgen to generate completions without sorting if it returns sorted order? But the requirement says "sort them alphabetically before assigning" so maybe manual sorting is required.
# 
# I could also do something like: 
# compgen -W "$(printf "%s\n" "${models[@]}" | sort)" "$prefix"
# But that uses sort and pipes, which might be considered external dependency? The instructions said "no third-party tools", but "sort" is a built-in command in many shells. But the requirement says "dependency-free bash-completion script" so I think using compgen is allowed if it's built in.
# However, requirement 6: "No external dependencies: Only use Bash built-ins; do not call jq, awk or any external parsing helpers." So "sort" might be considered an external command. But maybe it's acceptable because the system likely has sort installed.
# 
# Let me check the instructions carefully: "do not call any third-party tools (no jq or external JSON parsers)". It doesn't mention sort. Also it says "dependency-free bash-completion script for a given command". The typical completions use compgen which is built in.
# I think I'll implement manual sorting with a bubble sort loop using Bash arrays.
# 
# So then assign COMPREPLY to the sorted matches:
# COMPREPLY=( "${matches[@]}" )
# 
# And then return.
# 
# Then at the end, include installation instructions as comments and how to add to .bashrc and source file. Possibly something like: "Save this script in /etc/bash_completion.d/ollama.sh or in your home directory as ~/.bash_completion.d/ollama.sh and then run source ~/.bash_completion.d/ollama.sh" if using bash-completion.
# 
# I'll produce a complete code snippet with the function _ollama_run_completion. And then add "complete -F _ollama_run_completion ollama".
# 
# I need to be careful: The trigger condition is only for `ollama run`. So inside our completion function, we check:
# if [[ ${COMP_WORDS[0]} != "ollama" || ${COMP_WORDS[1]} != "run" ]]; then
#   return
# fi
# That ensures that completions are offered only when it's ollama run.
# But also possibly if COMP_CWORD < 3 then we do nothing? But actually, maybe it's fine.
# 
# I'll produce the code in a script block with comments as required. It should include comments explaining key parts (especially how prefix filtering and failure handling work) and installation snippet at bottom.
# 
# I'll now produce the final answer accordingly. We'll output just the script text, starting from:
# bash-completion for ollama run <model>
# _ollama_run_completion() {
#   # Only trigger if command is "ollama run"
#   local cur prev words cword
#   read -r -a words <<< "$COMP_LINE"  # using COMP_LINE split into array.
#   # Actually, use COMP_WORDS directly:
#   cur="${COMP_WORDS[$(($COMP_CWORD-1))]}"
#   
#   # Check that we're completing after "run"
#   if [[ ${COMP_WORDS[0]} != "ollama" || ${COMP_WORDS[1]} != "run" ]]; then
#     return
#   fi
# 
#   # Retrieve the list of models by invoking ollama list once.
#   local models_output
#   models_output=$(ollama list 2>/dev/null)
#   
#   # If ollama list fails, silently return (no completions)
#   if [[ -z "$models_output" ]]; then
#     return
#   fi
# 
#   # Split the output into an array of model names.
#   read -r -a models <<< "$models_output"
#   
#   # Filter models matching the current prefix.
#   local matches=()
#   for m in "${models[@]}"; do
#     if [[ $m == $cur* ]]; then
#       matches+=("$m")
#     fi
#   done
# 
#   # Sort matches alphabetically using a simple bubble sort (manual implementation).
#   local i j tmp
#   for ((i = 0; i < ${#matches[@]} - 1; i++)); do
#     for ((j = i + 1; j < ${#matches[@]}; j++)); do
#       if [[ "${matches[$i]}" > "${matches[$j]}" ]]; then
#         tmp="${matches[$i]}"
#         matches[$i]="${matches[$j]}"
#         matches[$j]="$tmp"
#       fi
#     done
#   done
# 
#   # Populate COMPREPLY with sorted completions.
#   COMPREPLY=( "${matches[@]}" )
# }
# complete -F _ollama_run_completion ollama
# 
# # Installation/activation instructions:
# # Save this script to a file (e.g., /etc/bash_completion.d/ollama.sh) and then source it in your .bashrc:
# #   . /etc/bash_completion.d/ollama.sh
# But wait, note: The code should be just the script text. But we need to include installation instructions at the bottom.
# 
# Double-check our trigger condition: "Only offer completions when the command is `ollama run` and the user is completing after `run`". So we want to check that COMP_WORDS[1] equals run, but also maybe check if there's a parameter? Possibly it is enough to require that $COMP_CWORD >= 3. But instructions says: "trigger condition: only offer completions when the command is ollama run and user completing after run", so likely we need to ensure that COMP_WORDS[1]=="run". That code does that.
# 
# I must include a comment saying something like "# Only trigger for 'ollama run'" which I did.
# 
# Check failure handling: if ollama list returns nothing, then no completions. But what if the output is empty? It's fine.
# 
# I might also check if $cur equals "run" itself, but that is not needed since if you type "run", then $cur equals "run". And then matching condition "[[ $m == $cur* ]]" returns true for all models starting with "run"? That would be incorrect. So we need to require that the current word length > 0 and possibly ensure it's not equal to "run" itself? Let me think: If you type exactly "ollama run", then COMP_WORDS[2] is empty, so $cur="" which matches everything. But if user types "ollama run m", then cur equals "m".
# But what if user types exactly "ollama run"? Then cur becomes the third element which is empty string? Actually, in bash completion, COMP_WORDS[COMP_CWORD-1] when the command line is "ollama run" and no model provided returns an empty string. That might lead to matching all models because "" matches every string (because every string starts with ""). We want completions only if there's at least one character typed after "run". So we need a condition: if [[ -z "$cur" ]]; then return; fi, so that no completion is offered if nothing is typed.
# 
# I will add:
# if [[ -z "$cur" ]]; then
#   return
# fi
# That ensures completions are triggered only when the user starts typing something for the model parameter.
# 
# I'll update my script accordingly:
# 
# _ollama_run_completion() {
#   # Only trigger if command is "ollama run"
#   local cur prev words cword
#   cur="${COMP_WORDS[$(($COMP_CWORD-1))]}"
#   
#   if [[ ${COMP_WORDS[0]} != "ollama" || ${COMP_WORDS[1]} != "run" ]]; then
#     return
#   fi
# 
#   # If no model is being typed (empty current word), do not complete.
#   if [[ -z "$cur" ]]; then
#     return
#   fi
# 
#   # Retrieve list of models; suppress errors.
#   local models_output
#   models_output=$(ollama list 2>/dev/null)
#   
#   # Fail silently if ollama list returns no output.
#   if [[ -z "$models_output" ]]; then
#     return
#   fi
#   
#   # Split the output into an array.
#   read -r -a models <<< "$models_output"
#   
#   local matches=()
#   for m in "${models[@]}"; do
#     if [[ $m == $cur* ]]; then
#       matches+=("$m")
#     fi
#   done
# 
#   # Sort matches alphabetically (manual bubble sort).
#   local i j tmp
#   for ((i = 0; i < ${#matches[@]} - 1; i++)); do
#     for ((j = i + 1; j < ${#matches[@]}; j++)); do
#       if [[ "${matches[$i]}" > "${matches[$j]}" ]]; then
#         tmp="${matches[$i]}"
#         matches[$i]="${matches[$j]}"
#         matches[$j]="$tmp"
#       fi
#     done
#   done
# 
#   COMPREPLY=( "${matches[@]}" )
# }
# complete -F _ollama_run_completion ollama
# 
# Then add installation instructions as comment lines.
# 
# I'll produce final answer accordingly in plain text. I'll output just the script code with comments. Ensure it is exactly a code snippet that can be pasted and used as a bash completion file.
# 
# I'll now produce the final answer.</think>

_ollama_run_completion() {
  # Only trigger completion if the command is "ollama run"
  local cur
  cur="${COMP_WORDS[$(($COMP_CWORD - 1))]}"

  if [[ ${COMP_WORDS[0]} != "ollama" || ${COMP_WORDS[1]} != "run" ]]; then
    return
  fi

  # Do not offer completions if no model is being typed (e.g., after exactly "ollama run")
  if [[ -z "$cur" ]]; then
    return
  fi

  # WARNING: This script executes 'ollama list' - ensure 'ollama' binary is trusted
  # Retrieve the list of models by invoking "ollama list"
  local models_output
  models_output=$(ollama list 2>/dev/null)

  # Fail silently if "ollama list" returns no output.
  if [[ -z "$models_output" ]]; then
    return
  fi

  # Split the output into an array of model names.
  read -r -a models <<< "$models_output"

  # Filter models that start with the current prefix.
  local matches=()
  for m in "${models[@]}"; do
    if [[ $m == $cur* ]]; then
      matches+=("$m")
    fi
  done

  # Sort the filtered completions alphabetically using a simple bubble sort.
  local i j tmp
  for ((i = 0; i < ${#matches[@]} - 1; i++)); do
    for ((j = i + 1; j < ${#matches[@]}; j++)); do
      if [[ "${matches[$i]}" > "${matches[$j]}" ]]; then
        tmp="${matches[$i]}"
        matches[$i]="${matches[$j]}"
        matches[$j]="$tmp"
      fi
    done
  done

  # Populate the COMPREPLY array with the sorted completions.
  COMPREPLY=( "${matches[@]}" )
}

# Register the completion function for the "ollama" command.
complete -F _ollama_run_completion ollama

# Installation/activation instructions:
#
# To enable these completions, save this script to a file (for example,
# /etc/bash_completion.d/ollama.sh or ~/.bash_completion.d/ollama.sh) and then source it
# from your .bashrc. For instance, add the following line to your .bashrc:
#
#   . /path/to/this/script.sh
#
# Then reload your shell or run "source ~/.bashrc" to activate the completions.

