#<think>We need to produce a robust and correct Bash completion script for "ollama run" command, following the rules given.
#
#The script must be self-contained that can be sourced e.g. via `source my_script.sh` to enable functionality. The code must follow these requirements:
#
#- Only trigger if second word is exactly "run". i.e. check COMP_WORDS[1]=="run".
#
#- Parse output of `ollama list`, then extract only model names from the first column, skip header line.
#
#- We should use a standard tool like awk or cut; but it's forbidden to use AWK according to rule #7: "Awk is prohibited". Wait, check instructions: "Use a standard and reliable tool like awk '{print $1}' or cut for this parsing." But then later says "Do not assume non-standard helpers are available. Awk is prohibited" so maybe we can't use awk? Let's re-read rule #7:
#   7. If you use `_get_comp_words_by_ref`, include fallback.
#   Wait, check: "Use only Bash built-ins and GNU coreutils (sort, etc). Assume LINUX support only. Do not assume non-standard helpers are available. Awk is prohibited." So we cannot use awk. But it's allowed to use `cut`. So we must rely on cut.
#
#- The script should also filter completions based on what the user typed before the TAB press.
#
#- Only if the second word equals "run", then list completions for model names that match prefix (like substring match). Also do not fallback with filenames from current directory if no matches.
#
#- We need to get the raw output of `ollama list` and process. For instance, the script can store the available models in an array variable or use a temporary file? But since we want to avoid external dependencies? It says only Bash builtins and GNU coreutils; but we can call cut because that's allowed.
#
#- The instructions: "Extract only model names from first column" means each line of ollama list, ignoring header lines. So one solution is to run `ollama list | tail -n +2` then use `cut -d' ' -f1` or something similar. But careful: The columns might be separated by whitespace but the first field might include a colon? Actually, the model name "llama3:latest" includes a colon so that's not an issue.
#
#- There is possibility of duplicate suggestions: "Unique Suggestions" so ensure we filter duplicates maybe using sort -u in the pipeline.
#
#We must then use COMP_WORDS and COMP_CWORD. Use COMPREPLY array variable to store completions.
#
#Also note: if the command word being completed does not match any available model, do nothing.
#
#- We need to check for _get_comp_words_by_ref function. But instructions says "If you use `_get_comp_words_by_ref`, include fallback that manually sets `cur` and `prev` from COMP_WORDS/COMP_CWORD if missing." But note: It's an anti-pattern to use `_get_comp_words_by_ref`. The instructions say: "Don't generate a script that uses _get_comp_words_by_ref or other functions that may not be universally available. Stick to the core COMP_* variables." So we must not call _get_comp_words_by_ref because it's not allowed.
#
#Thus, our script should do something like:
#```
#case "${COMP_WORDS[1]}" in
#   run)
#         # then get current word from COMP_LINE maybe or use COMP_POINT? But easier is to find the substring from COMP_WORDS?
#         # The prefix for autocompletion can be taken by using ${COMP_WORDS[COMP_CWORD]} but note that might be empty if it's just typed TAB.
#         # So we want to extract the partially typed word.
#         local cur=${COMP_WORDS[COMP_CWORD]}
#         # If not set, default to empty string
#         if [ -z "$cur" ]; then
#            cur=
#         fi
#         # Now get available models by running `ollama list | tail -n +2 | cut -d' ' -f1` and use sort -u maybe.
#         local models=$(ollama list 2>/dev/null | sed '1d' | cut -d' ' -f1)
#         # Then filter: for each model that starts with the prefix $cur, add to COMPREPLY array. But also ensure unique.
#         COMPREPLY=()
#         while IFS= read -r line; do
#              if [[ "$line" == $cur* ]]; then
#                  COMPREPLY+=("$line")
#              fi
#         done <<< "$models"
#         ;;
#   *)
#         return 0
#         ;;
#esac
#
## If no completions, don't fall back to filename completion.
#return 0
#```
#
#But must use valid Bash syntax.
#
#We must also not complete "ollama" itself. Only if COMP_WORDS[1] equals run do we complete. So first check `if [ "${COMP_WORDS[1]}" != "run" ]; then return; fi` maybe.
#
#Wait, instructions: The script must only complete for the word immediately following the `run` subcommand. That is second word is "run".
#
#Thus, we should check if COMP_CWORD equals something? But actually, since we want to complete the argument after run, that means the user typed `ollama run <TAB>`, then the completion should show completions from the models list.
#
#We must set COMPREPLY array.
#
#We can do:
#
#```
#_ollama_run_completion() {
#   # only activate if second word is "run"
#   if [ "${COMP_WORDS[1]}" != "run" ]; then
#       return 0
#   fi
#
#   local cur=${COMP_WORDS[COMP_CWORD]}
#   # fallback: if not set, use empty string.
#   COMPREPLY=()
#   local models
#   models=$(ollama list | sed '1d' | cut -d' ' -f1)
#   for model in $models; do
#       case "$model" in
#         $cur*) COMPREPLY+=("$model") ;;
#       esac
#   done
#
#   # Remove duplicates, though if the loop is repeated then it might not have duplicates. But better to use unique sort?
#   # Alternatively, we can pipe models through sort -u after filtering.
#}
#```
#
#We want unique completions so if same model appears twice? but likely "ollama list" produces one header line and then multiple lines of model names. They are likely unique because it's a list.
#
#But instructions: "Unique Suggestions: The final list must not contain duplicates." So we can do something like:
#```
#COMPREPLY=( $(compgen -W "$models" -- "$cur") )
#```
#But careful: compgen may include duplicates? Actually, compgen does not produce duplicates normally. But what if multiple matches occur?
#We are using "compgen -W", but that will output completions with possible extra spaces maybe. Also we want to filter by prefix matching only.
#
#Maybe easier is:
#```
#COMPREPLY=( $(compgen -W "$models" -- "$cur") )
#```
#But then how do we ensure unique suggestions? compgen might produce duplicates if the words list has duplicates. But likely it doesn't generate duplicates.
#We can also use "sort -u".
#
#Alternatively, we can compute:
#```
#COMPREPLY=( $(compgen -W "$(echo $models | tr ' ' '\n' | sort -u)" -- "$cur") )
#```
#But that would produce a newline-separated list. But careful with quoting.
#
#Better: read models into an array then filter unique ones.
#
#Plan:
#
#- Get the output of "ollama list" command. Use sed to skip header line, cut first field.
#- Then store in an array variable called models maybe:
#   models=()
#   while IFS= read -r model; do
#       models+=("$model")
#   done < <(ollama list 2>/dev/null | sed '1d' | cut -f1)
#- Then filter for prefix matching $cur. But then need to output unique completions.
#- We can use an associative array to ensure uniqueness, but not required if the command outputs unique lines? But instructions require that final list must be unique.
#
#We could simply do:
#```
#declare -A seen
#for model in "${models[@]}"; do
#   case "$model" in
#       $cur*)
#         if [[ ! ${seen[$model]} ]]; then seen[$model]=1; COMPREPLY+=("$model"); fi ;;
#   esac
#done
#```
#
#That is safe.
#
#- Then complete. Use COMPREPLY array variable.
#- And return 0 at the end.
#
#We also need to check for _get_comp_words_by_ref fallback if necessary. But instructions say: "If you use `_get_comp_words_by_ref`, include a fallback that manually sets `cur` and `prev` from COMP_WORDS/COMP_CWORD if missing." However, we are not using it because instructions tell us to stick to core COMP_* variables.
#
#We can check:
#```
#if declare -f _get_comp_words_by_ref >/dev/null 2>&1; then
#    _get_comp_words_by_ref cur prev "${COMP_WORDS[@]}"
#else
#    cur=${COMP_WORDS[COMP_CWORD]}
#    # previous word is ${COMP_WORDS[COMP_CWORD-1]} if COMP_CWORD > 1 else empty.
#    prev=${COMP_WORDS[COMP_CWORD-1] 2>/dev/null || true}
#fi
#```
#But instructions says "Do not use _get_comp_words_by_ref" so we should not use it. But maybe we can include a fallback if someone uses that function.
#It says: "if you use `_get_comp_words_by_ref`, include a fallback." But then also "avoid using _get_comp_words_by_ref". So best to simply not call it.
#
#Thus, I'll not use _get_comp_words_by_ref. Instead, I can do:
#```
#cur=${COMP_WORDS[COMP_CWORD]}
#if [ -z "$cur" ]; then
#    cur=
#fi
#```
#
#That is enough.
#
#- We must check that COMP_WORDS has at least 2 elements.
#- Must check second word equals "run". So if not, return 0.
#
#We must also add comments in every line of non-code that starts with "#", as required by instructions: "MAKE SURE EVERY LINE of non-code STARTS WITH #." The code lines can be code without comments? But instructions says: "Every line of non-code" so likely the script should have a comment on each non-code line. Possibly we need to add comment for each block, but not each code line if it's actual code. But instructions require that any explanation or non-code text is preceded by #.
#
#I'll produce a script with comments starting with # above lines of non-code. It's ambiguous because every non-code line must start with #. I think we can do something like:
#
#```
## This is the bash completion script for "ollama run"
## The completions are triggered only when second word equals "run"
## We use COMP_WORDS, COMP_CWORD and COMPREPLY variables as per bash-completion v2.
#
#_ollama_run_completion() {
#    # Check if the subcommand after ollama is exactly "run"
#    if [ "${COMP_WORDS[1]}" != "run" ]; then
#        return 0
#    fi
#
#    # Get current word being typed (the argument for model name)
#    local cur=${COMP_WORDS[COMP_CWORD]}
#    if [ -z "$cur" ]; then
#        cur=
#    fi
#
#    # Fetch available models from 'ollama list' command, skip header line.
#    local models
#    models=$(ollama list 2>/dev/null | sed '1d' | cut -d' ' -f1)
#
#    # Initialize COMPREPLY array to store completion suggestions
#    COMPREPLY=()
#
#    # Use associative array to ensure unique completions if necessary (if Bash version supports it)
#    declare -A seen
#
#    # Read each model line from the models output
#    while IFS= read -r model; do
#        # Filter models that start with the current prefix
#        case "$model" in
#            $cur*)
#                if [ -z "${seen[$model]}" ]; then
#                    seen[$model]=1
#                    COMPREPLY+=("$model")
#                fi
#                ;;
#        esac
#    done <<< "$models"
#
#    return 0
#}
#
## Register the completion function with bash-completion v2 framework.
#complete -F _ollama_run_completion ollama
#
## End of script.
#```
#
#Now, check if we need to include fallback for _get_comp_words_by_ref? The instructions say "if you use `_get_comp_words_by_ref`, include a fallback", but I'm not using it so that's fine.
#
#Let me re-read the requirements:
#"1. Targeted Triggering: only when second word equals run. 2. Precise Parsing: Use tool to parse ollama list output, skip header line. 3. Contextual Filtering: suggestions filtered based on what user typed. 4. No Filename Fallback: do not provide completions if no match found. 5. Unique Suggestions."
#
#I have that.
#
#I want to check for empty string in prefix matching. If the user pressed tab immediately after `ollama run`, then cur is empty, and case "$model" in ""*) should match everything. That's fine.
#
#I need to ensure that there is no fallback mechanism to complete filenames if nothing matches; I simply do not add anything. So it's correct.
#
#Now, also note that the script uses "complete -F _ollama_run_completion ollam a". But instructions: "complete for ollama run" but we want to complete only the argument after run. That means when user types "ollama run", then pressing tab should trigger our function. But if user typed "ollama something else", our function returns 0 and does nothing.
#
#I think that's correct.
#
#Double-check the sed command:
#```
#models=$(ollama list 2>/dev/null | sed '1d' | cut -d' ' -f1)
#```
#This command takes output of ollama list, discards first line with sed '1d', then cuts by delimiter space and picks field number 1. That is correct if the header is "model", but instructions said to skip header? But instructions said "Precise Parsing: parse ollama list output using a tool that can skip header lines". So sed '1d' does that.
#
#I should check if I'm not accidentally including the models with spaces. It's assumed that model names do not contain spaces.
#
#Also, note that the while loop uses `while IFS= read -r model; do ... done <<< "$models"`. That works because $models is a string containing multiple lines separated by newline characters.
#
#I must ensure that every non-code line starts with "#". But my code lines in function are not necessarily all commented? The instructions say "every line of non-code", but I'm not 100% sure. Possibly I'll add comments before each logical block in the function.
#
#Maybe I can do:
#
#```
## Function: _ollama_run_completion
## Purpose: Provide completion suggestions for 'ollama run' command based on output of 'ollama list'.
#_ollama_run_completion() {
#    # Check if the subcommand is exactly "run"
#    ...
#}
#```
#
#That seems correct.
#
#I'll produce a final answer.</think>
#!/bin/bash
#
# This script provides bash‐completion for the “ollama run” command.
# It activates only when the second word (the subcommand) is “run.”
#
_ollama_run_completion() {
	# Check if the subcommand after “ollama” is exactly “run”
	if [ "${COMP_WORDS[1]}" != "run" ]; then
		return 0
	fi

	# Get the current word being typed (i.e. the partial model name)
	local cur=${COMP_WORDS[COMP_CWORD]}
	if [ -z "$cur" ]; then
		cur=
	fi

	# Fetch available models from “ollama list” and skip the header line.
	# We use sed to remove the first line, and cut to extract the first field.
	local models
	models=$(ollama list 2>/dev/null | sed '1d' | cut -d' ' -f1)

	# Initialize COMPREPLY array for completion suggestions.
	COMPREPLY=()

	# Use an associative array to ensure uniqueness of suggestions.
	declare -A seen

	# Read each model from the output and add it to COMPREPLY if it matches the current prefix.
	while IFS= read -r model; do
		case "$model" in
			$cur*)
				if [ -z "${seen[$model]}" ]; then
					seen[$model]=1
					COMPREPLY+=("$model")
				fi
				;;
		esac
	done <<< "$models"

	return 0
}

# Register the completion function with the bash-completion framework.
complete -F _ollama_run_completion ollama

# End of script.

