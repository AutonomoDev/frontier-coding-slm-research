#Thinking...
#We need to produce a bash completion script.
#
#Requirements:
#
#- Only triggers for `ollama run`. So we need to check if COMP_WORDS[1] is "run". Also COMP_WORDS[0] likely "ollama". Also should be robust to command line contexts like "ollama run" plus maybe other args after model. We only care about completing the model name after run, not other args.
#
#- Parse `ollama list` output, get first column names. Use only Bash built-ins and coreutils like awk is prohibited. So we can't use awk. We can use `cut -d' ' -f1` but we need to handle multiple spaces. The list output is columns separated by spaces, but the first column could contain spaces? No, model names are no spaces. There are multiple spaces. So we can use `cut -d' ' -f1` but that will treat each field separated by single spaces, but there may be multiple spaces. But `cut -d' ' -f1` with default field separator being space will treat each space as delimiter but only single spaces? Actually cut with -d uses single char delimiter, so multiple spaces produce empty fields, which might produce blank lines. Better use `awk` but prohibited. Instead we can use `sed` or `read`. Use `while read -r line; do ...`. We can parse lines ignoring header.
#
#We can read the output and cut the first column by extracting until first space. We can use parameter expansion.
#
#We can get the output of `ollama list` and store in an array:
#
#mapfile -t model_names < <(ollama list | tail -n +2 | while read -r line; do
#  # skip header
#  # take first word until first space
#  # use ${line%%[[:space:]]*}
#  echo "${line%%[[:space:]]*}"
#done)
#
#Need to ensure no duplicates: We can sort -u to remove duplicates. Since duplicates unlikely, but requirement says no duplicates. So we can pipe through sort -u.
#
#Also we need to filter suggestions based on cur: the word currently typed. cur is ${COMP_WORDS[COMP_CWORD]}. Need to filter model_names that start with cur.
#
#Also no fallback to filenames: So we should set COMPREPLY to filtered array only. If none, COMPREPLY stays empty.
#
#Also we need fallback for _get_comp_words_by_ref: Not needed, we will manually set cur and prev.
#
#The script needs to be self-contained and include function, register with complete.
#
#Also we should guard against running this completion if not in completion context? Usually completions are executed only when required. So we just define a function _ollama_run_completion and register it.
#
#Edge Cases:
#
#- If the user has typed 'ollama run ' then cur is empty string. So we should suggest all model names. That means we need to set cur variable: if COMP_CWORD is 2, and last word is empty? When pressing Tab after space, cur will be empty string. Good.
#
#- We need to ensure we only complete when COMP_WORDS[1] is run and COMP_WORDS[0] is ollama. But also maybe user types "ollama" only. But that's fine.
#
#- Also we need to ensure we are not completing if the current word is after the model name. For example "ollama run model --param". In that case, we shouldn't complete again because the word after model might be something else. But the requirement is only for the word immediately following run. So we check if COMP_CWORD == 2? Wait: COMP_CWORD is the index of the current word. If user typed "ollama run " and pressed tab, the cursor is after a space, COMP_CWORD = 2? Let's test: With "ollama run" no trailing space, COMP_CWORD=2? Actually words are 0: ollama, 1: run. Press tab after run with space? When there is trailing space, COMP_WORDS[2] will be empty string? Usually COMP_CWORD is index of word being completed. When there is a trailing space, the current word is empty string, but still index is 2. So we need to trigger when COMP_CWORD==2? But if user typed "ollama run l", COMP_CWORD=2, cur = 'l'. So we only need to trigger when COMP_CWORD == 2. That ensures we are completing the model name. But if user typed "ollama run model --param", COMP_CWORD would be 3, not 2. So we shouldn't complete. So we enforce that.
#
#Thus in function:
#
#if [[ ${COMP_WORDS[1]} != "run" || ${COMP_CWORD} -ne 2 ]]; then return 0; fi
#
#Also need to handle case where command is aliased or completions triggered from other script? But fine.
#
#Parsing:
#
#model_list=$(ollama list | tail -n +2 | sed -E 's/^([^\s]+).*/\1/' | sort -u)
#
#But we want to use built-in to parse each line: while read -r line; do name=${line%%[[:space:]]*}; echo "$name"; done
#
#But we need to skip header: tail -n +2 or if we manually skip first line. We can use read to skip first line.
#
#Implementation:
#
#mapfile -t models < <(
#  # Use while loop
#  local header_skipped=0
#  while IFS= read -r line; do
#    if (( header_skipped == 0 )); then
#      header_skipped=1
#      continue
#    fi
#    local name="${line%%[[:space:]]*}"
#    printf '%s\n' "$name"
#  done < <(ollama list)
#)
#
#Then remove duplicates via sort -u: we can pipe into sort -u and read into array.
#
#But mapfile can't read from a pipe that includes read? Actually mapfile can read from a process substitution, but we have internal while; easier: we can store output of command pipeline in array: mapfile -t models < <(ollama list | tail -n +2 | cut -d' ' -f1 | sort -u) But cut -d ' ' -f1 may produce empty lines due to multiple spaces. Eg. 'llama3:latest                   a7320c749969' The first field separated by space after header may produce correct. The header line: 'NAME                            ID              SIZE    MODIFIED', cut -d' ' -f1 will output 'NAME'. Then tail -n +2 will skip header. Good. But if there are multiple spaces, cut -d ' ' -f1 will treat multiple spaces as a single delimiter? Actually with cut, if delimiter is space, consecutive delimiters are considered separate fields, leading to empty fields. For example, "NAME                            ID" has many spaces, cut -d' ' -f1 will produce 'NAME', but if there were multiple spaces before ID, still first field is 'NAME'. But for lines like 'llama3:latest                   a7320c749969', cut -d' ' -f1 gives 'llama3:latest'. So fine. But if there are leading spaces? No.
#
#So we can just use:
#
#mapfile -t models < <(ollama list | tail -n +2 | cut -d' ' -f1 | sort -u)
#
#This uses cut, which is standard. Good.
#
#Now we filter:
#
#COMPREPLY=()
#
#for m in "${models[@]}"; do
#  [[ $m == $cur* ]] && COMPREPLY+=("$m")
#done
#
#We don't want fallback to filenames: So we should not use `compgen -f`. We just set COMPREPLY.
#
#Edge: If no matches, COMPREPLY stays empty.
#
#Also we need to handle that "ollama list" may be slow; but okay.
#
#Now register completion:
#
#complete -F _ollama_run_completion ollama
#
#But need to avoid overriding other completions for ollama? We may use complete -F _ollama_run_completion ollama. But we only trigger for run subcommand. If someone types 'ollama --help', the function will early return because COMP_WORDS[1] != run. So safe.
#
#Script should have shebang? Not needed but okay.
#
#Add comments.
#
#Add fallback for _get_comp_words_by_ref: Not needed.
#
#Now final script: Provide as one file with comments.
#
#Check for missing parentheses: In Bash, we can't define local variable outside function? We'll keep variables inside function.
#
#Better to define function like:
#
#_ollama_run_completion() {
#  local cur prev
#
#  cur="${COMP_WORDS[COMP_CWORD]}"
#  prev="${COMP_WORDS[COMP_CWORD-1]}"
#
#  # Only complete after "ollama run"
#  if [[ ${COMP_WORDS[1]} != "run" || ${COMP_CWORD} -ne 2 ]]; then
#    return 0
#  fi
#
#  # Get list of local models
#  mapfile -t _models < <(ollama list | tail -n +2 | cut -d' ' -f1 | sort -u)
#
#  # Filter suggestions based on current word
#  COMPREPLY=()
#  for m in "${_models[@]}"; do
#    [[ $m == $cur* ]] && COMPREPLY+=("$m")
#  done
#
#  return 0
#}
#
#complete -F _ollama_run_completion ollama
#
#But we must ensure that mapfile is available. It is standard in Bash 4+. Ok.
#
#Also we must handle missing ollama command: if not installed, the function may fail; but it's fine.
#
#Now produce final script.
#
#Remember each non-code line must start with '#'. So we need to comment all lines that are not code. Code lines start without '#'.
#
#Also we must ensure we don't include anything else.
#
#Let's produce script:
#
#```
## Bash completion script for 'ollama run' command.
## Provides autocompletion of local model names.
## Only activates when the second word is 'run'.
## The list of models is obtained from 'ollama list' output.
## No fallback to filename completion; only model names are suggested.
## Duplicates are removed and suggestions are filtered based on the word being typed.
#
#_ollama_run_completion() {
#  # Current word being completed
#  local cur="${COMP_WORDS[COMP_CWORD]}"
#
#  # Only trigger for 'ollama run <model>'
#  if [[ ${COMP_WORDS[1]} != "run" || ${COMP_CWORD} -ne 2 ]]; then
#    return 0
#  fi
#
#  # Retrieve local model names: first column of 'ollama list', skip header, unique
#  local -a models
#  models=()
#  while IFS= read -r line; do
#    # Skip header line
#    if [[ $line == NAME* ]]; then
#      continue
#    fi
#    # Extract first column (model name)
#    local name="${line%%[[:space:]]*}"
#    # Add to array
#    models+=("$name")
#  done < <(ollama list)
#
#  # Remove duplicates
#  if (( ${#models[@]} )); then
#    # Use sort -u to dedupe
#    mapfile -t models < <(printf '%s\n' "${models[@]}" | sort -u)
#  fi
#
#  # Filter suggestions based on the current word
#  COMPREPLY=()
#  for m in "${models[@]}"; do
#    [[ $m == $cur* ]] && COMPREPLY+=("$m")
#  done
#
#  return 0
#}
#
## Register completion for the 'ollama' command
#complete -F _ollama_run_completion ollama
#```
#
#But we used while read reading from ollama list. That might produce duplicates? But we dedupe after. However we also need to skip header. The header may be "NAME". The line begins with 'NAME'. So skip if line starts with 'NAME'.
#
#But the header could also be "NAME". We'll skip.
#
#We also used variable name "name" with local. Good.
#
#But we used mapfile to dedupe; that's fine.
#
#But we used `sort -u` which is standard.
#
#However, the while loop reads all lines including the header. But we skip header by if line starts with NAME. Good.
#
#But we must also ensure that we ignore empty lines. The while read may produce an empty line at the end if output ends with newline? It will just produce an empty line; but name will be empty string; we will add it to array. Then dedupe will keep empty string. That might cause COMPREPLY empty string suggestion. To avoid, we can check if name is non-empty. Add condition: if [[ -n $name ]]; then models+=("$name"); fi
#
#Add that.
#
#Also need to skip header if line starts with "NAME". Good.
#
#So modify.
#
#Also need to ensure local variables: In bash function, you can declare local. We used local cur. local name inside loop. Good.
#
#Add the condition.
#
#Also ensure we don't produce "models=()" at start; we can just use mapfile with process substitution.
#
#But we can keep while loop; easier.
#
#Now produce final script.
#
#Double-check: We defined local -a models; then used while read loop to fill; then dedupe with mapfile; but we used models variable again as array after dedupe.
#
#But we used mapfile -t models < <(printf '%s\n' "${models[@]}" | sort -u). That works.
#
#Alternatively, we could just use mapfile -t models < <(ollama list | tail -n +2 | cut -d' ' -f1 | sort -u) to skip header and parse. But cut -d' ' -f1 may produce empty lines due to multiple spaces? Let's test: Suppose line is 'llama3:latest                   a7320c749969'. If we cut -d ' ' -f1, the first delimiter is the first space after the name; since there are multiple spaces, cut -d ' ' will treat the first space after name as delimiter, giving 'llama3:latest' correctly. But if there were leading spaces, not. So fine. For header, cut -d ' ' -f1 would output 'NAME', but we tail -n +2 skip header. Good. That might produce fewer empty lines. So simpler. But we can keep loop.
#
#I'll keep loop.
#
#Now final script:
#
#```
## Bash completion script for the 'ollama run' command.
## Provides autocompletion of local model names from 'ollama list'.
## Activates only when the second word of the command line is 'run'.
## No fallback to file names; only model names are suggested.
## Duplicates are removed and suggestions are filtered based on the word being typed.
#
#_ollama_run_completion() {
#  # Current word to be completed
#  local cur="${COMP_WORDS[COMP_CWORD]}"
#
#  # Only run this completion when the command is 'ollama run <model>'
#  if [[ ${COMP_WORDS[1]} != "run" || ${COMP_CWORD} -ne 2 ]]; then
#    return 0
#  fi
#
#  # Collect model names from 'ollama list'
#  local -a _models=()
#  while IFS= read -r line; do
#    # Skip the header line that starts with "NAME"
#    if [[ $line == NAME* ]]; then
#      continue
#    fi
#    # Extract the first column (model name)
#    local _name="${line%%[[:space:]]*}"
#    # Ignore empty names that may arise from blank lines
#    [[ -n $_name ]] && _models+=("$._name")
#  done < <(ollama list)
#
#  # Remove duplicate entries
#  if (( ${#_models[@]} )); then
#    _models=()
#    mapfile -t _models < <(printf '%s\n' "${_models[@]}" | sort -u)
#  fi
#
#  # Build the reply list, filtering by the current word
#  COMPREPLY=()
#  for m in "${_models[@]}"; do
#    [[ $m == $cur* ]] && COMPREPLY+=("$m")
#  done
#
#  return 0
#}
#
## Register the completion function for the 'ollama' command
#complete -F _ollama_run_completion ollama
#```
#
#But I had a typo: _models+=("$._name") incorrectly. Should be _models+=("$ _name")? Wait we need to append string variable: _models+=("$ _name")? Actually _name is variable containing name; we want to add it as array element: _models+=("$ _name")? Wait we had local _name. The string value is stored in variable `_name`. To add it, we write `_models+=("$ _name")` but there is space. That's wrong. Should be `_models+=("$ _name")` but there is space before variable name. It should be `_models+=("$ _name")`? Let's check: In bash, to reference variable value, use `$_name`. So _models+=("$ _name") is wrong because it includes a space after the opening quote. It should be `_models+=("$ _name")`? Actually we need: `_models+=("$ _name")`? Wait.
#
#Better: `_models+=("$ _name")`? Not good.
#
#We need to add variable value as array element: `_models+=("$ _name")` no; correct syntax: `_models+=("$ _name")`? Hmm.
#
#Simpler: `_models+=("$name")`. So we should use variable name `name`. But we used `_name`. Let's rename variable to `name`. So inside while loop:
#
#local name="${line%%[[:space:]]*}"
#[[ -n $name ]] && _models+=("$name")
#
#Thus correct.
#
#But we used `local -a _models=()` then after loop we dedupe. We used `_models` variable for array.
#
#We need to be consistent: we use `_models` for array.
#
#So function:
#
#local -a _models
#_models=()
#
#while IFS= read -r line; do
#  if [[ $line == NAME* ]]; then
#    continue
#  fi
#  local name="${line%%[[:space:]]*}"
#  [[ -n $name ]] && _models+=("$name")
#done < <(ollama list)
#
## dedupe
#if (( ${#_models[@]} )); then
#  mapfile -t _models < <(printf '%s\n' "${_models[@]}" | sort -u)
#fi
#
#COMPREPLY=()
#for m in "${_models[@]}"; do
#  [[ $m == $cur* ]] && COMPREPLY+=("$m")
#done
#
#Ok.
#
#Now final script.
#
#Let's produce final script with proper indentation but comments.
#
#We must start all non-code lines with '#'.
#
#Now produce final answer.
#...done thinking.

# Bash completion script for the `ollama` command.
# When the second word is `run`, it autocompletes local model names.
# Model names are extracted from the first column of `ollama list` output,
# the header line is skipped, duplicates are removed,
# and suggestions are filtered to match the word being typed.
# No filename completion fallback is provided.

_ollama_run_completion() {
  # The word that the user is currently typing
  local cur="${COMP_WORDS[COMP_CWORD]}"

  # Activate only for `ollama run <model>`
  if [[ ${COMP_WORDS[1]} != "run" || ${COMP_CWORD} -ne 2 ]]; then
    return 0
  fi

  # Collect model names from `ollama list`
  local -a _models
  _models=()
  while IFS= read -r line; do
    # Skip the header line that starts with "NAME"
    if [[ $line == NAME* ]]; then
      continue
    fi
    # Extract the first column (model name)
    local name="${line%%[[:space:]]*}"
    [[ -n $name ]] && _models+=("$name")
  done < <(ollama list)

  # Remove duplicate entries
  if (( ${#_models[@]} )); then
    mapfile -t _models < <(printf '%s\n' "${_models[@]}" | sort -u)
  fi

  # Build the completion reply list, filtering by the current word
  COMPREPLY=()
  for m in "${_models[@]}"; do
    [[ $m == $cur* ]] && COMPREPLY+=("$m")
  done

  return 0
}

# Register the completion function for the `ollama` command
complete -F _ollama_run_completion ollama

