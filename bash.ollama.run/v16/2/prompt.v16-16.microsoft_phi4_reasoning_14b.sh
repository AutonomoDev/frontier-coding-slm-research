<think>We are Phi. The user gives a detailed specification of a Bash completion script. We must produce complete, self-contained bash script for "ollama run" command with proper completions as described.

I'll now produce a code block that is exactly the skeleton and content provided. So I'll produce a text block containing the function definition `_ollama_completions()`, then include the index check, colon handling reparse, then check if ollama command exists, then get list models with awk and then generate completions via compgen, call __ltrim_colon_completions "$cur", etc. And register completion for "ollama" using complete -F _ollama_completions.

I'll produce a code block that is self-contained as described. I must output only the bash code without markdown formatting, so plain text with no markdown markers if possible? But instructions says: "OUTPUT ONLY THE BASH CODE", and then "saveable as .sh" file. So I'll produce one contiguous block of code.

I'll produce a script that starts with `#!/bin/bash` maybe? The specification said output only the bash code, but not required to add shebang because it's completions. But might be nice if we include shebang line. But instructions did not require shebang.

But I must follow exactly what is described in skeleton:

```
# Function Declaration: _ollama_completions() { ... }
...
```

So I'll produce code as follows:

```
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
    
    # Extract models robustly (skip header, get names only)
    local models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}')
    
    # If no models, empty reply
    [[ -z $models ]] && { COMPREPLY=(); return 0; }

    # Filter and set completions
    COMPREPLY=( $(compgen -W "$models" -- "$cur") )

    # MANDATORY: Fix display after colons
    __ltrim_colon_completions "$cur"
    
    return 0
}

complete -F _ollama_completions ollama
```

I must include inline comments for critical lines. I need to produce a single contiguous code block with no markdown formatting.

I'll check each requirement:

1) Function Declaration: `_ollama_completions() { ... }`
2) Exact indexing check is provided.
3) Colon handling:
    - "local _old_wb=${COMP_WORDBREAKS}"
    - "COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}" and then call `_get_comp_words_by_ref -n : cur prev`
4) Check if ollama available: `command -v ollama &>/dev/null || { COMPREPLY=(); return 0; }`
5) Extract models using "ollama list" piped to awk, skipping header.
6) Set completions with compgen
7) call __ltrim_colon_completions "$cur"
8) registration line: `complete -F _ollama_completions ollama`

Yes.

We must output only bash code. I'll produce exactly the above block of code in plain text, no markdown formatting instructions etc.

I'll now produce final answer with a contiguous code block containing the script.</think>_ollama_completions() {
	# CRITICAL: Check if completing after "ollama run"
	[[ ${COMP_WORDS[0]} != "ollama" || ${COMP_WORDS[1]} != "run" ]] && { COMPREPLY=(); return 0; }

	# Handle colons: Temporarily remove ':' from word breaks to reparse correctly
	local _old_wb=${COMP_WORDBREAKS}
	COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}
	_get_comp_words_by_ref -n : cur prev
	COMP_WORDBREAKS=${_old_wb}

	# Check if ollama available
	command -v ollama &>/dev/null || { COMPREPLY=(); return 0; }

	# Extract models robustly (skip header, get names only)
	local models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}')

	# If no models, empty reply
	[[ -z "$models" ]] && { COMPREPLY=(); return 0; }

	# Filter and set completions
	COMPREPLY=( $(compgen -W "$models" -- "$cur") )

	# MANDATORY: Fix display after colons (trims suggestions for clean insertion)
	__ltrim_colon_completions "$cur"
	return 0
}

complete -F _ollama_completions ollama

