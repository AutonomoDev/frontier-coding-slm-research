# [[HUMAN COMMENTED-OUT]]
# Bash Completion Generator — ollama run <model>
# 
# Introduction
# This completion script enables tab completion for the `ollama run <model>` command. It generates a single Bash function that performs the necessary checks and populates the COMPREPLY array with the available models.
# 
# 
# 
# Do Not:
# - Add COMP_CWORD or fallback logic.
# - Check for `_get_comp_words_by_ref` or `__ltrim_colon_completions` existence.
# - Use arrays for models.
# - Sort input models.
# 
# 
# 
# Must Do (Exact Steps)

# Function definition
_ollama_completions() {
   # Validate command - ensure we're completing "ollama run"
   [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }
   
   # Extract current word and previous word
   local cur prev
   _get_comp_words_by_ref -n : cur prev
   
   # Fetch available ollama models
   if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
   local models
   models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
   [[ -z "$models" ]] && { COMPREPLY=(); return; }
   
   # Generate completions based on current word
   COMPREPLY=($(compgen -W "$models" -- "$cur"))
   
   # Sort completions and trim colon prefixes
   COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
   __ltrim_colon_completions "$cur"
}

# Register the completion function for ollama command
complete -F _ollama_completions ollama

# [[HUMAN COMMENTED-OUT]]
# 
# 
# Output Rules
# - Output **only Bash code**, no markdown.
# - Inline comments for key logic.
# - Must handle:
# 	+ No `ollama` command
# 	+ Empty model list
# 	+ Colons (`codellama:<TAB>`)
# 
# 
# 
# Verification Checklist
# - [ ] Checks only COMP_WORDS[0] and [1]
# - [ ] Uses `_get_comp_words_by_ref -n :`
# - [ ] `models=$(...)` scalar string
# - [ ] Uses `compgen -W "$models" -- "$cur"`
# - [ ] Sorts COMPREPLY via `printf | sort`
# - [ ] Calls `__ltrim_colon_completions "$cur"`
# - [ ] Returns safely on missing/empty models
