# <think>We need to generate a single bash function for tab completion for "ollama run <model>" command. The instructions are in the prompt with step-by-step instructions. We'll produce code that is exactly matching steps given.
# 
# Let's re-read instructions carefully:
# 
# "Generate a *single Bash function* that enables tab completion for `ollama run <model>`."
# 
# We need to produce a single bash function, named "_ollama_completions() {" and then complete it with the necessary logic. The provided pseudocode is as follows:
# ```
# _ollama_completions() {
#    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }
#    
#    local cur prev
#    _get_comp_words_by_ref -n : cur prev
#    
#    if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
#    local models
#    models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
#    [[ -z "$models" ]] && { COMPREPLY=(); return; }
#    
#    COMPREPLY=($(compgen -W "$models" -- "$cur"))
#    
#    COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
#    __ltrim_colon_completions "$cur"
# }
# 
# complete -F _ollama_completions ollama
# ```
# 
# The instructions require that we generate code exactly as described. We need to produce "only Bash code, no markdown." But then the prompt says: "Output only Bash code", and inline comments for key logic.
# 
# We must not check COMP_CWORD or fallback logic. Do not use arrays for models? Wait the instruction says "Do not use arrays for models". I think the above instructions "must do" list includes this step: "models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')" is a scalar string, so that's fine. But check "do not sort input models"? It says "Sort input models." Actually instruction number 6 "Sort + trim" is to run: 
# ```
# COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
# __ltrim_colon_completions "$cur"
# ```
# So that's exactly what we need.
# 
# I must produce the code as a single bash function with inline comments. The instructions ask for output rules "only Bash code, no markdown." So I'll provide code in plain text.
#  
# Let me check each step:
# 
# Step 1: Function declaration:
## _ollama_completions() {
#    ...
# }
# ```
# 
# Step 2: Validate command:
# ```
# [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }
# ```
# We need to check if the first word is ollama and second is run. So that's done.
# 
# Step 3: Extract word info:
# ```
# local cur prev
# _get_comp_words_by_ref -n : cur prev
# ```
# 
# Step 4: Fetch models. We must check if "ollama" command exists, then fetch models from "ollama list". But note: The code should run "ollama list 2>/dev/null | tail -n +2 | awk '{print $1}'" to get models. But instructions say use scalar string for models, so that's fine.
# 
# Step 5: Generate completions:
# ```
# COMPREPLY=($(compgen -W "$models" -- "$cur"))
## 
# Step 6: Sort + trim:
## COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
# __ltrim_colon_completions "$cur"
# ```
# 
# After function we need to register the completion for "ollama" using "complete -F _ollama_completions ollama".
# 
# Edge cases: No "ollama" command, empty model list. So in step 4, if no models then return safely.
# 
# We must add inline comments for key logic:
# - Validate command (check that first two words are "ollama run")
# - Extract current word input and previous word
# - Check if ollama command exists; if not, empty completion.
# - Fetch model list from "ollama list" ignoring header lines using tail -n +2.
# - If no models returned, exit function safely.
# - Use compgen to generate completions based on the available models string.
# - Sort completions and trim them using __ltrim_colon_completions.
# 
# We must not check for COMP_CWORD or fallback logic. So we don't need to reference that.
# 
# The instructions say "Don't use arrays for models" but then step says "local models", it's a scalar variable, so that's fine.
# 
# Now I'll produce code as plain text in bash.
# 
# I can produce:
# 
# ```
# _ollama_completions() {
#     # Validate command: Ensure the first two words are "ollama run"
#     [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }
# 
#     # Get the current and previous word
#     local cur prev
#     _get_comp_words_by_ref -n : cur prev
# 
#     # Check if 'ollama' command exists before proceeding
#     if ! command -v ollama &>/dev/null; then 
#         COMPREPLY=()
#         return
#     fi
# 
#     # Fetch the list of models from "ollama list" command, ignoring header lines
#     local models
#     models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
# 
#     # If no models are found, exit safely
#     [[ -z "$models" ]] && { COMPREPLY=(); return; }
# 
#     # Generate completions for the current word using available model names
#     COMPREPLY=($(compgen -W "$models" -- "$cur"))
# 
#     # Sort completions and trim any colon prefixed completions
#     COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
#     __ltrim_colon_completions "$cur"
# }
# 
# # Register the completion function with bash for 'ollama'
# complete -F _ollama_completions ollama
# ```
# 
# We need to produce exactly that code, but without markdown formatting. So I'll output plain text.
# 
# I must note: "Output only Bash code" means we should not include any additional explanation in text, just the code.
# 
# Thus I will produce final answer as plain text (Bash code with inline comments). We'll provide exactly one bash function plus the registration line.
# 
# Let's check instructions regarding colon completions ("codellama:<TAB>"). The code calls __ltrim_colon_completions "$cur", so that should handle colons. So I have satisfied that requirement.
# 
# I must produce output in plain text with no markdown formatting, only Bash code. So I'll produce exactly the code block without markdown formatting markers maybe triple backticks or not? But instructions say "output only Bash code" and "no markdown". So probably I'll produce plain text.
# 
# I'll now produce final answer as requested.</think>
_ollama_completions() {
	# Validate command: ensure first two words are "ollama run"
	[[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

	# Extract the current and previous word from completion arguments
	local cur prev
	_get_comp_words_by_ref -n : cur prev

	# Check if the 'ollama' command exists before proceeding
	if ! command -v ollama &>/dev/null; then
		COMPREPLY=()
		return
	fi

	# Fetch available models from "ollama list", ignoring header lines
	local models
	models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')

	# If no models are found, exit safely without completions
	[[ -z "$models" ]] && { COMPREPLY=(); return; }

	# Generate possible completions based on the current input word
	COMPREPLY=($(compgen -W "$models" -- "$cur"))

	# Sort the completions and trim any colon prefixes for proper formatting
	COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
	__ltrim_colon_completions "$cur"
}

complete -F _ollama_completions ollama
