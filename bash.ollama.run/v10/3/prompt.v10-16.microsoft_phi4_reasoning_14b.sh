# <think>We are tasked with generating a robust Bash completion script for `ollama run` command. The prompt is: "Create a robust Bash completion script" that handles colon in word break completions by temporarily removing colon from COMP_WORDBREAKS, then use _get_comp_words_by_ref -n : cur prev to re-parsing the words.
# 
# The instructions are:
# - Must be a single contiguous block of valid bash code.
# - It must have no extra commentary outside inline comments. Comments inside the code should begin with `#`.
# 
# I'll now produce a bash code script that defines a function _ollama_completions, check if COMP_WORDS[1] equals "run". If not, then return early.
# 
# - Steps:
# 1. Define function _ollama_completions.
# 2. Check if "$COMP_WORDS" count is at least 2 and if [ "${COMP_WORDS[1]}" == "run" ] else return.
# 3. Save original COMP_WORDBREAKS: local orig_word_breaks="$COMP_WORDBREAKS".
# 4. Remove colon from COMP_WORDBREAKS: COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}.
# 5. Use _get_comp_words_by_ref -n : cur prev to re-parse words, then restore COMP_WORDBREAKS immediately afterwards.
# 6. If previous argument equals "run", then generate completions using compgen -W "$models" -- "$cur". Where models are extracted by command: `ollama list | awk 'NR>1 {print $1}'`. (Maybe also do check if models is empty? but instructions not require error handling.)
# 7. Then set COMPREPLY=( $(compgen -W "$models" -- "$cur") ) maybe.
# 8. Register completion with complete -F _ollama_completions ollama.
# 
# - Also comments: include inline comments explaining each step. Must include only code and nothing else, as per instructions "absolutely no commentary outside the source code comments".
# 
# I must produce a single block of valid Bash code that can be saved to .sh file.
# 
# Edge cases:
# - If not run subcommand then return early.
# - Use local variable for COMP_WORDBREAKS original value.
# 
# I'll produce code: The function _ollama_completions() should check if COMP_WORDS[1] equals "run". Otherwise, return.
# 
# Then remove colon from COMP_WORDBREAKS. But we must call _get_comp_words_by_ref with -n : cur prev. In bash completion functions, there's a built-in function _get_comp_words_by_ref that is only available if bash-completion 2 or later is loaded. We need to set local variables for the current word (cur) and previous word (prev).
# 
# I check: There's usage of _get_comp_words_by_ref -n : cur prev. But instructions: "Use _get_comp_words_by_ref -n : cur prev". So it would be:
# _get_comp_words_by_ref -n : cur prev
# 
# After that, restore COMP_WORDBREAKS.
# 
# Then if "$prev" equals "run", then proceed with generating completions from `ollama list`.
# 
# I must store the output of ollama list command in a variable, e.g. local models=$(ollama list | awk 'NR>1 {print $1}').
# 
# But careful: "Model names often include colons, which are treated as word breaks by default in Bash completion" so we need to ensure that colon is not being split incorrectly. But note: the code already temporarily removed colon from COMP_WORDBREAKS when calling _get_comp_words_by_ref. So it's safe.
# 
# I must generate completions using compgen -W "$models" -- "$cur". But note that models variable might have multiple lines separated by newline, so that's fine.
# 
# Then complete registration: complete -F _ollama_completions ollama
# 
# I must include inline comments starting with "#".
# 
# Also instructions: "Do not add any extra echo statements or functions etc."
# 
# I'll produce code:
# 
# We start with function definition:
# function _ollama_completions() {
#     # Check if the first argument is "run"
#     [ "${COMP_WORDS[1]}" != "run" ] && return 0
#     local orig_word_breaks="$COMP_WORDBREAKS"
#     COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}   # Remove colon from word breaks to avoid splitting model names
#     _get_comp_words_by_ref -n : cur prev  # Reparse the command line using colon as normal character instead of break
#     COMP_WORDBREAKS="$orig_word_breaks"      # Restore original COMP_WORDBREAKS immediately after re-parsing
#     if [ "$prev" = "run" ]; then
#         local models=$(ollama list | awk 'NR>1 {print $1}')  # Retrieve available model names from ollama list command, skipping header line.
#         COMPREPLY=( $(compgen -W "$models" -- "$cur") )  # Generate completion matches for the current word.
#     fi
# }
# 
# Then register: complete -F _ollama_completions ollama
# 
# I must ensure the code is pure bash. It's fine.
# 
# Be careful with inline comments: Each comment should be prefixed with "#". And no additional commentary outside of inline comments.
# 
# Double-check instructions: "Focus solely on completing model names after ollama run; do not add completions for other subcommands."
# 
# Yes, that's done.
# 
# Edge cases: if COMP_WORDS is less than 2 maybe. But the check [ "${COMP_WORDS[1]}" != "run" ] will return error if no element in array. But probably it's safe because when running bash completion, COMP_WORDS always has at least one argument.
# 
# I must produce code in a single contiguous block of valid Bash code.
# 
# I'll produce final answer accordingly.
function _ollama_completions() {
	# Check if the subcommand is "run"; if not, exit without completing.
	[ "${COMP_WORDS[1]}" != "run" ] && return 0

	# Save the original COMP_WORDBREAKS to restore later.
	local orig_word_breaks="$COMP_WORDBREAKS"

	# Remove colon (:) from COMP_WORDBREAKS so that model names containing colons aren't split.
	COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}

	# Re-parse the current and previous words using _get_comp_words_by_ref with colon as a normal character.
	_get_comp_words_by_ref -n : cur prev

	# Immediately restore COMP_WORDBREAKS to its original value.
	COMP_WORDBREAKS="$orig_word_breaks"

	# If the previous word is "run", generate completions for model names.
	if [ "$prev" = "run" ]; then
		# Retrieve available models from ollama list, skipping header line (NR>1) and extracting first column ($1).
		local models=$(ollama list | awk 'NR > 1 {print $1}')
		# Generate COMPREPLY array with matching model names using compgen.
		COMPREPLY=( $(compgen -W "$models" -- "$cur") )
	fi
}

complete -F _ollama_completions ollama
