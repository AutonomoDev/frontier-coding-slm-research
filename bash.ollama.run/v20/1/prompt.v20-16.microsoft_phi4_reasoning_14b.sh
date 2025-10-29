# [[HUMAN COMMENTED-OUT]]
#<think>We have to generate a single Bash function that enables tab completion for `ollama run <model>`. The instructions require to produce a single Bash function with the name `_ollama_completions` which does certain validations and completion. There is some specific code that must be included exactly, steps 1 through step 6. Let's re-read carefully:
#
#Task: "Generate a *single Bash function* that enables tab completion for `ollama run <model>`." Steps to follow:
#- Must define `_ollama_completions() { ... }`
#- Validate command: 
#[[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }
#- Extract word info using `_get_comp_words_by_ref -n : cur prev`
#- Fetch models:
#if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
#local models
#models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
#[[ -z "$models" ]] && { COMPREPLY=(); return; }
#- Generate completions: 
#COMPREPLY=($(compgen -W "$models" -- "$cur"))
#- Sort and trim:
#COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
#__ltrim_colon_completions "$cur"
#}
#complete -F _ollama_completions ollama
#
#Note that the code should be in Bash. There is a "verification checklist", and all instructions must be included exactly as required.
#
#We must output only Bash code, with inline comments for key logic.
#And no markdown formatting. So I'll produce plain text code that meets instructions. The function must check if command name equals "ollama run". It must check the number of words maybe? But the instructions say to validate COMP_WORDS[0] and [1]. But we must include condition as given: `[[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }` So that's required.
#
#I'll produce a single function:
#
#_ollama_completions() {
#    # Validate command is exactly "ollama run"
#    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }
#    
#    # Extract current word and previous word for completion context
#    local cur prev
#    _get_comp_words_by_ref -n : cur prev
#
#    # Check if 'ollama' command exists, if not exit gracefully.
#    if ! command -v ollama &>/dev/null; then 
#      COMPREPLY=()
#      return
#    fi
#    
#    # Fetch models from the output of "ollama list"
#    local models
#    models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
#    
#    # If no models were returned, exit gracefully.
#    [[ -z "$models" ]] && { COMPREPLY=(); return; }
#    
#    # Generate completions from the fetched model names.
#    COMPREPLY=($(compgen -W "$models" -- "$cur"))
#    
#    # Sort the completions and trim colon based prefixes if present.
#    COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
#    __ltrim_colon_completions "$cur"
#}
#
## Register completion function with 'complete'
#complete -F _ollama_completions ollama
#
#I'll check each line:
#
#- Function name: `_ollama_completions() { ... }`
#- Validate command using COMP_WORDS[0] and [1]. It's exactly as required.
#- Extract word info using `_get_comp_words_by_ref -n : cur prev`
#- Check for existence of `ollama` command using if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
#- Define variable models: local models, and get output of "ollama list" with tail -n +2 and awk. This returns the model names from the second line onward (skipping header).
#- If models is empty, then exit gracefully.
#- Generate completions via compgen command, which generates word completions using provided word list `$models`.
#- Then sort completions by printing them sorted via printf | sort.
#- Call __ltrim_colon_completions "$cur" to trim any leading colons in the completion suggestion (for codellama:<TAB>).
#- End function and then register it with complete command.
#
#We must not use arrays for models, sorting input models. We should output completions sorted via printf | sort.
#The code is exactly as required by instructions.
#
#Now check "No ollama command" handling: if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi works.
#
#Check empty model list: after fetching models, if it's empty, then do COMPREPLY=() and return. Done.
#
#The inline comments are added for key logic lines.
#
#I'll output this code as plain text with no markdown formatting (just plain text). We'll produce the code as final answer in a code block maybe. But instructions say "Output only Bash code". So I must ensure that I don't add markdown formatting, and no additional commentary aside from inline comments inside code. However, "no markdown" means we must not use triple backticks but rather just output plain text.
#
#But instructions specify: "Output **only Bash code**, no markdown." So I should produce only the raw code. But then instructions say "inline comments for key logic."
#
#So I'll produce a final answer as:
#
#_ollama_completions() {
#    # Validate command is exactly 'ollama run'
#    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }
#    
#    # Extract current and previous words for context
#    local cur prev
#    _get_comp_words_by_ref -n : cur prev
#    
#    # Check if 'ollama' command is available
#    if ! command -v ollama &>/dev/null; then 
#      COMPREPLY=()
#      return
#    fi
#    
#    # Retrieve the list of models from the 'ollama list' command output
#    local models
#    models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
#    
#    # If no models are found, exit completion function
#    [[ -z "$models" ]] && { COMPREPLY=(); return; }
#    
#    # Generate completions based on the current word fragment and available model names
#    COMPREPLY=($(compgen -W "$models" -- "$cur"))
#    
#    # Sort completions and trim any leading colons for proper display
#    COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
#    __ltrim_colon_completions "$cur"
#}
#
#complete -F _ollama_completions ollama
#
#I'll produce final answer.</think>
_ollama_completions() {
  # Validate command is exactly "ollama run"
  [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

  # Extract current and previous words for context
  local cur prev
  _get_comp_words_by_ref -n : cur prev

  # Check if 'ollama' command exists, exit if not found
  if ! command -v ollama &>/dev/null; then 
    COMPREPLY=()
    return
  fi

  # Fetch models from the output of "ollama list" (skip header)
  local models
  models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
  
  # If no models are returned, exit gracefully
  [[ -z "$models" ]] && { COMPREPLY=(); return; }

  # Generate completions based on the current word fragment from the model list
  COMPREPLY=($(compgen -W "$models" -- "$cur"))

  # Sort the completions and trim any leading colons (e.g. for "codellama:<TAB>")
  COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
  __ltrim_colon_completions "$cur"
}

complete -F _ollama_completions ollama