#<think>We are Phi, we have a detailed prompt that instructs us to output only Bash code script fulfilling the requirements: The script must generate completions for "ollama run", extracting model names from `ollama list` output using awk or cut after header etc.
#
#Let's step through instructions:
#
#Step-by-step breakdown of requirements:
#1. Must create function _ollama_completions.
#2. In that function, check if first word is "ollama" and previous word (prev) is "run". If not, then COMPREPLY=() and return early.
#3. Handle colon splitting: use `_get_comp_words_by_ref -n : cur prev` if available; if not fallback to using `cur="${COMP_WORDS[COMP_CWORD]}"`, etc. The instructions mention:
#    "if ! _get_comp_words_by_ref -n : cur prev; then
#      fallback: set cur and prev with COMP_WORDS indexing" etc.
#   So code snippet something like:
#
#```
#if ! _get_comp_words_by_ref -n : cur prev 2>/dev/null; then
#  cur="${COMP_WORDS[COMP_CWORD]}"
#  prev="${COMP_WORDS[COMP_CWORD-1]}"
#fi
#```
#But instructions: "Try `if ! _get_comp_words_by_ref -n : cur prev; then`" but not mention 2>/dev/null maybe. But I'll use it to be safe.
#
#4. If prev equals "run", then check if ollama command exists, by using `command -v ollama &> /dev/null`. Then run `ollama list 2>/dev/null` and read each line in a while loop.
#   For each line:
#   - Skip header row with first column equal to NAME or the whole line equals "NAME ID SIZE MODIFIED"? But instructions: "Skip header 'NAME ID SIZE MODIFIED'". So we can check if the line begins with "NAME" maybe?
#   Alternatively, check if line starts with "#", but not sure. The sample output shows header as "NAME ID SIZE MODIFIED". We'll do a condition like:
#   ```
#   if [[ "$line" == "NAME"* ]]; then continue; fi
#   ```
#   Also skip empty lines.
#   Then use awk to print first column. But instructions say: Use awk '{print $1}' or similar to get only the model name (first column).
#   - We'll store them in a local array called models.
#5. After loop, if models is empty then set COMPREPLY=() and return.
#6. Now create another array "matches", where we loop through models. For each model, check if it begins with $cur pattern.
#7. Then sort matches using: `sorted_matches=$(printf '%s\n' "${matches[@]}" | sort)`.
#8. Set COMPREPLY with compgen -W "$sorted_matches" -- "$cur".
#9. Always after setting COMPREPLY, call __ltrim_colon_completions "$cur".
#
#I must also add comment lines.
#
#Additionally, at end register the completion: complete -F _ollama_completions ollama
#
#No markdown formatting text outside code.
#
#The instructions say "DO NOT ADD ANY TEXT OUTSIDE THE CODE!" so I'll output only plain bash script. We must not include extraneous commentary except comments inside code.
#
#I must also check that first word is "ollama" and second word is run. But careful: "if the first word is not 'ollama' or prev is not 'run'" then set COMPREPLY=() and return. So condition: if [[ ${COMP_WORDS[0]} != "ollama" ]] || [[ $prev != "run" ]]; then exit early.
#
#We must use _get_comp_words_by_ref if available to get the current word, because otherwise it's splitting colons incorrectly.
#The instructions say:
#```
#if ! _get_comp_words_by_ref -n : cur prev; then
#  fallback: set cur and prev using COMP_WORDS
#fi
#```
#So that is important.
#
#Let's check script robustness. I'll use local arrays for models and matches.
#
#I must handle colons properly. We need to call __ltrim_colon_completions "$cur" at end, no matter what.
#
#Also note: "complete -F _ollama_completions ollama".
#
#Edge-case handling: if command -v ollama returns false, then set COMPREPLY=() and return.
#Make sure to redirect error output of "ollama list" command to /dev/null.
#
#I'll check step-by-step:
#
#Define function:
#```
#_ollama_completions () {
#   # local variables
#}
#```
#Inside:
#- Check first word: COMP_WORDS[0] is "ollama". If not, then COMPREPLY=() and return.
#- Similarly check if previous word equals run. But careful: if the number of words is less than 2, then we can't refer to prev? But instructions say: Only complete after "ollama run", so presumably there are at least two words.
#
#Better: Check that COMP_CWORD >= 2 and then COMP_WORDS[1] equals "run". So condition:
#```
#if [[ "${COMP_WORDS[0]}" != "ollama" || ${#COMP_WORDS[@]} -lt 2 || "${COMP_WORDS[1]}" != "run" ]]; then
#    COMPREPLY=()
#    return
#fi
#```
#
#But instructions says: "set COMPREPLY=() and return if first word is not 'ollama' or prev is not run". So do that.
#
#Then colon handling:
#```
#if ! _get_comp_words_by_ref -n : cur prev; then
#  cur="${COMP_WORDS[COMP_CWORD]}"
#  prev="${COMP_WORDS[COMP_CWORD-1]}"
#fi
#```
#
#Now if prev equals "run", then continue.
#But since we already checked that COMP_WORDS[1] is run, but it might not be needed because I'm doing check anyway.
#
#I want to add a comment: # handle colon splitting properly by using _get_comp_words_by_ref with -n : flag
#
#Then check if ollama command exists:
#```
#if ! command -v ollama &>/dev/null; then
#  COMPREPLY=()
#  return
#fi
#```
#
#Now get models list from "ollama list". We'll store in local array called models. We must read each line from the output.
#
#I can do something like:
#```
#models=() # initialize array
#while IFS= read -r line; do
#    # skip header and empty lines
#    if [[ "$line" =~ ^NAME ]]; then continue; fi
#    if [ -z "$line" ]; then continue; fi
#    # extract first column using awk or cut. We can use: model=$(echo "$line" | awk '{print $1}')
#    model=$(echo "$line" | awk '{print $1}')
#    models+=("$model")
#done < <(ollama list 2>/dev/null)
#```
#Alternatively, we can use while read loop reading from process substitution of (ollama list 2>/dev/null).
#
#After the while loop, if no models then set COMPREPLY=() and return.
#
#Then create matches array: I'll do:
#```
#matches=()
#for model in "${models[@]}"; do
#    # if model starts with $cur (case-sensitive match)
#    if [[ "$model" == ${cur}* ]]; then
#        matches+=("$model")
#    fi
#done
#```
#
#Now sort matches. We can join sorted_matches as:
#```
#sorted_matches=$(printf '%s\n' "${matches[@]}" | sort)
#```
#Or we could also reassign to array sorted_matches, but it's okay if string variable.
#
#Then set COMPREPLY= using compgen command. So:
#```
#COMPREPLY=( $(compgen -W "$sorted_matches" -- "$cur") )
#```
#
#After that, call __ltrim_colon_completions "$cur".
#So:
#```
#__ltrim_colon_completions "$cur"
#```
#But note: The function __ltrim_colon_completions might not be available if using bash-completion version 2? But instructions says "always call" so I'll do that.
#
#Then at the end, register completion for ollama command:
#```
#complete -F _ollama_completions ollama
#```
#
#I must include proper comments explaining each part (especially colon splitting and __ltrim_colon_completions usage).
#
#I will output pure bash code with no markdown formatting. The assistant's answer should be a single block of code that is valid bash script.
#
#I'll now produce the code:
#
#```
## Bash Completion Script for ollama run completions
#_ollama_completions() {
#    # Only complete if first word is "ollama" and second word (prev) is "run"
#    local cur prev words cword
#    if [[ "${COMP_WORDS[0]}" != "ollama" ]] || (( COMP_CWORD < 2 )); then
#        COMPREPLY=()
#        return
#    fi
#
#    # Ensure second argument is "run"
#    if [[ "${COMP_WORDS[1]}" != "run" ]]; then
#        COMPREPLY=()
#        return
#    fi
#
#    # Use _get_comp_words_by_ref to handle colons properly, fallback if not available.
#    if ! _get_comp_words_by_ref -n : cur prev; then
#        cur="${COMP_WORDS[COMP_CWORD]}"
#        prev="${COMP_WORDS[COMP_CWORD-1]}"
#    fi
#
#    # Only proceed if previous word is "run"
#    if [[ "$prev" != "run" ]]; then
#        COMPREPLY=()
#        return
#    fi
#
#    # Check that ollama command exists.
#    if ! command -v ollama &>/dev/null; then
#        COMPREPLY=()
#        return
#    fi
#
#    # Get the list of models from 'ollama list', skipping header and empty lines.
#    local models=()
#    while IFS= read -r line || [ -n "$line" ]; do
#        # Skip header row starting with "NAME"
#        if [[ "$line" =~ ^NAME ]]; then
#            continue
#        fi
#        # Skip empty lines
#        [[ -z "$line" ]] && continue
#
#        # Extract the first column (model name) using awk.
#        local model
#        model=$(echo "$line" | awk '{print $1}')
#        models+=("$model")
#    done < <(ollama list 2>/dev/null)
#
#    # If no models were found, exit.
#    if [ ${#models[@]} -eq 0 ]; then
#        COMPREPLY=()
#        return
#    fi
#
#    # Build matches: only add model names starting with the current word fragment.
#    local matches=()
#    for model in "${models[@]}"; do
#        if [[ "$model" == ${cur}* ]]; then
#            matches+=("$model")
#        fi
#    done
#
#    # Sort the matches to ensure ordered suggestions.
#    local sorted_matches
#    sorted_matches=$(printf '%s\n' "${matches[@]}" | sort)
#
#    # Set COMPREPLY with matching model names.
#    COMPREPLY=( $(compgen -W "$sorted_matches" -- "$cur") )
#
#    # CRITICAL: fix completion display for colons by trimming spaces before colon in the suggestions.
#    __ltrim_colon_completions "$cur"
#}
#
## Register the completion function for ollama command.
#complete -F _ollama_completions ollama
#```
#I'll produce such code.
#
#Edge considerations: The instructions said "Do not output the full `ollama list` without parsing it first" and so on. So I'm using awk to print only the model name column.
#
#I must also check that "prev" equals "run". But note: if COMP_CWORD < 2 then we return early. Already did check, but maybe more robust is to use "if [[ $COMP_WORDS[1] != run ]]" condition.
#
#I'll now produce final code with comments as required by instructions and not extra text outside the code block.
#
#I must produce only pure bash code without markdown formatting.
#
#I'll produce answer accordingly.</think>
_ollama_completions() {
	# Only complete if first word is "ollama" and second word (prev) is "run"
	local cur prev
	if [[ "${COMP_WORDS[0]}" != "ollama" ]] || (( COMP_CWORD < 2 )); then
		COMPREPLY=()
		return
	fi

	if [[ "${COMP_WORDS[1]}" != "run" ]]; then
		COMPREPLY=()
		return
	fi

	# Use _get_comp_words_by_ref to handle colons properly; fallback if not available.
	if ! _get_comp_words_by_ref -n : cur prev; then
		cur="${COMP_WORDS[COMP_CWORD]}"
		prev="${COMP_WORDS[COMP_CWORD-1]}"
	fi

	# Proceed only if the previous word is "run"
	if [[ "$prev" != "run" ]]; then
		COMPREPLY=()
		return
	fi

	# Check that ollama command exists.
	if ! command -v ollama &>/dev/null; then
		COMPREPLY=()
		return
	fi

	# Get the list of models from 'ollama list', skipping header and empty lines.
	local models=()
	while IFS= read -r line || [ -n "$line" ]; do
		# Skip header row starting with "NAME"
		if [[ "$line" =~ ^NAME ]]; then
			continue
		fi
		[[ -z "$line" ]] && continue

		# Extract the first column (model name) using awk.
		local model
		model=$(echo "$line" | awk '{print $1}')
		models+=("$model")
	done < <(ollama list 2>/dev/null)

	# If no models were found, exit early.
	if [ ${#models[@]} -eq 0 ]; then
		COMPREPLY=()
		return
	fi

	# Build an array of matches: only add model names starting with the current word fragment.
	local matches=()
	for model in "${models[@]}"; do
		if [[ "$model" == ${cur}* ]]; then
			matches+=("$model")
		fi
	done

	# Sort matches to ensure ordered suggestions.
	local sorted_matches
	sorted_matches=$(printf '%s\n' "${matches[@]}" | sort)

	# Set COMPREPLY with matching model names.
	COMPREPLY=( $(compgen -W "$sorted_matches" -- "$cur") )

	# CRITICAL: Correctly handle colons in suggestions by trimming spaces before them.
	__ltrim_colon_completions "$cur"
}

complete -F _ollama_completions ollama

