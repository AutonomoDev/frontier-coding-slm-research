#<think>We are given a detailed specification to produce a complete self-contained bash completion script. We have to output the entire script, with inline comments exactly as required. The instructions specify:
#- Use function _ollama_completions.
#- Contains exact index check: 
#   `[[ ${COMP_WORDS[0]} != "ollama" || ${COMP_WORDS[1]} != "run" ]] && { COMPREPLY=(); return 0; }`
#- Must include colon handling lines exactly. The script must also check if ollama is available.
#- Use "local models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}')" to extract models from the output of `ollama list`.
#- Then, set COMPREPLY with compgen -W "$models" -- "$cur".
#- Must call __ltrim_colon_completions "$cur".
#- Ends with "complete -F _ollama_completions ollama".
#
#I have to produce a code block that is the entire bash code.
#
#The instructions: "OUTPUT ONLY THE BASH CODE" so no extra text, just code. I'll output final answer as plain code.
#
#Let's check our script:
#
#We start with function declaration `_ollama_completions() { ... }` in which we do:
#
#
#function _ollama_completions(){
#  # CRITICAL: Check if completing after "ollama run"
#  [[ ${COMP_WORDS[0]} != "ollama" || ${COMP_WORDS[1]} != "run" ]] && { COMPREPLY=(); return 0; }
#  
#  # Handle colons: Temporarily remove ':' from word breaks to reparse correctly
#  local _old_wb=${COMP_WORDBREAKS}
#  COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}
#  _get_comp_words_by_ref -n : cur prev
#  COMP_WORDBREAKS=${_old_wb}
#
#  # Check if ollama available
#  command -v ollama &>/dev/null || { COMPREPLY=(); return 0; }
#  
#  # Extract models robustly (skip header, get names only)
#  local models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}')
#  
#  # If no models, empty reply
#  [[ -z "$models" ]] && { COMPREPLY=(); return 0; }
#  
#  # Filter and set completions
#  COMPREPLY=( $(compgen -W "$models" -- "$cur") )
#  # MANDATORY: Fix display after colons
#  __ltrim_colon_completions "$cur"
#  return 0
#}
#
#
#Then, at the end of file, we must have:
#`complete -F _ollama_completions ollama`
#
#We need to produce exactly a script with those lines.
#
#Also note that if there's any error in our code, it might be because we are using quotes. We also want to check "models" variable, so use double quotes: [[ -z "$models" ]] etc.
#
#I must include inline comments only on critical lines as described (for example, why reparse) but not extra text.
#
#The script is "production ready", handles errors gracefully by checking command existence and models.
#
#I also note that the instructions mention sorting if easy. But it said "sort if easy" but prioritize reliability over extras. Possibly we can sort the output of "ollama list" to ensure consistent ordering? The instructions say: "Handle errors, sort if easy (`| sort`)". I'm not sure whether to add " | sort" or not because instructions said optional sorting is allowed. But since it's robust and production ready, we might consider sorting models. However, the sample output has a header line, so if we add `sort` after extracting names, maybe then each model is sorted alphabetically.
#
#I can do: local models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | sort) to get sorted models. But instructions did not require sorting explicitly but said "if easy" so maybe it's allowed.
#
#But I have to be careful, because adding a pipe to sort may cause problems if output is empty? But no: if there are no models, then the AWK will produce nothing, and we check -z "$models". So it's fine. If there are many models, sorting might help consistency. However, instructions say "production-ready" so maybe I'll add sort.
#
#But careful: The instructions says: "Handle errors, sort if easy (`| sort`)" but then later said "MUST INCLUDE: End with complete -F _ollama_completions ollama", so that's the end line. So sorting is optional. Since it's not critical to functionality, I can add sort for improved behavior.
#
#I must produce code only without markdown formatting by default? But instructions says "OUTPUT ONLY THE BASH CODE" in a single contiguous block. So I'll output a code block with no markdown formatting.
#
#I'll check step by step:
#
#Step 1: function declaration
#
#_ollama_completions() {
#    # CRITICAL: Check if completing after "ollama run"
#    [[ ${COMP_WORDS[0]} != "ollama" || ${COMP_WORDS[1]} != "run" ]] && { COMPREPLY=(); return 0; }
#    
#    # Handle colons: Temporarily remove ':' from word breaks to reparse correctly
#    local _old_wb=${COMP_WORDBREAKS}
#    COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}
#    _get_comp_words_by_ref -n : cur prev
#    COMP_WORDBREAKS=${_old_wb}
#
#    # Check if ollama available
#    command -v ollama &>/dev/null || { COMPREPLY=(); return 0; }
#    
#    # Extract models robustly (skip header, get names only)
#    local models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | sort)
#    
#    # If no models, empty reply
#    [[ -z "$models" ]] && { COMPREPLY=(); return 0; }
#    
#    # Filter and set completions
#    COMPREPLY=( $(compgen -W "$models" -- "$cur") )
#    # MANDATORY: Fix display after colons
#    __ltrim_colon_completions "$cur"
#    return 0
#}
#
#Then register the completion:
#
#complete -F _ollama_completions ollama
#
#
#I must produce a complete self-contained script. I'll now produce code with exactly this block.
#
#Let's check potential pitfalls: The colon handling snippet uses COMP_WORDBREAKS and _get_comp_words_by_ref, which is provided by bash completion. It's standard.
#
#The instructions specify "production-ready" so we have to set COMPREPLY=() in all branches. We already did that if no models or command not found.
#Yes.
#
#The inline comments should be minimal as indicated: they are only on critical lines (e.g., check indexing, colon handling).
#
#I must include the final registration line exactly with complete -F _ollama_completions ollama.
#
#I'll produce code. I'll produce a single code block without markdown formatting by default. It says "OUTPUT ONLY THE BASH CODE", so no explanation text outside of it.
#
#I'll now produce answer in plain text.</think>
_ollama_completions() {
	# CRITICAL: Check if completing after "ollama run"
	[[ ${COMP_WORDS[0]} != "ollama" || ${COMP_WORDS[1]} != "run" ]] && { COMPREPLY=(); return 0; }

	# Handle colons: Temporarily remove ':' from word breaks to reparse correctly
	local _old_wb=${COMP_WORDBREAKS}
	COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}
	_get_comp_words_by_ref -n : cur prev
	COMP_WORDBREAKS=${_old_wb}

	# Check if ollama available
	command -v ollama &>/dev/null || { COMPREPLY=(); return 0; }

	# Extract models robustly (skip header, get names only) and sort for consistency
	local models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | sort)

	# If no models, empty reply
	[[ -z "$models" ]] && { COMPREPLY=(); return 0; }

	# Filter and set completions
	COMPREPLY=( $(compgen -W "$models" -- "$cur") )
	# MANDATORY: Fix display after colons
	__ltrim_colon_completions "$cur"
	return 0
}

complete -F _ollama_completions ollama
