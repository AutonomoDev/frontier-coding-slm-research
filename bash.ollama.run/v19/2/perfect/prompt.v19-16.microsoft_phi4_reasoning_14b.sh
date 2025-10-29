# <think>We are Phi. The user instructs to generate a bash completion script for `ollama run` command based on instructions. The problem text is a long prompt explaining what the script should do.
# 
# I'll now produce a complete script in Bash that meets all requirements exactly. I will output BASH code only, with inline comments. I must not include markdown formatting. And include no markdown headers. So I output plain text code.
# 
# Let's check steps: "Generate script for `ollama run <model>`" with instructions:
# 
# We need to produce a bash function `_ollama_completions()`. Inside it do:
# 1. Check if COMP_WORDS[0] != "ollama" or COMP_WORDS[1] != "run", then return COMPREPLY empty.
# 2. Then assign local cur, prev variables using _get_comp_words_by_ref -n : cur prev. Use that exactly.
# 
# 3. Parse models: first check if command `ollama` exists (using command -v). If not, then set COMPREPLY=() and return.
# 
# 4. Then define variable models as:
#    local models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
#    And if [ -z "$models" ] then COMPREPLY=(); return.
#    
# 5. Next, get completions from compgen with: 
#    COMPREPLY=($(compgen -W "$models" -- "$cur"))
# 
# 6. Then sort them using:
#    COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
# 
# 7. After sorting, call __ltrim_colon_completions "$cur". But note: the instructions say "Call __ltrim_colon_completions without check after sorting." I need to do that exactly.
# 
# 8. Then register completions with complete -F _ollama_completions ollama.
# 
# I'll produce code. I must output only bash code, no markdown formatting. So it will be a plain text file containing the function and registration line. The inline comments should explain critical sections.
# 
# Let me now generate a script that is robust:
# - It's production ready.
# - Possibly also include error handling if compgen returns nothing? But instructions don't mention that because empty COMPREPLY is acceptable.
# - We need to check if command "ollama" exists: if not, then return empty. And similarly if models variable is empty.
# 
# I'll now produce code:
# </think>
_ollama_completions() {
    # Activate only for 'ollama run'
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

    # Get current and previous word references with colon support
    local cur prev
    _get_comp_words_by_ref -n : cur prev

    # Check if 'ollama' command exists, exit if not found
    if ! command -v ollama &>/dev/null; then
        COMPREPLY=()
        return
    fi

    # Parse models from 'ollama list', skipping header line with tail -n +2 and using awk for first column
    local models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
    
    # If no models found, exit completion function.
    if [ -z "$models" ]; then
        COMPREPLY=()
        return
    fi

    # Generate completions using compgen with model names matching the current word input
    COMPREPLY=($(compgen -W "$models" -- "$cur"))

    # Sort completions alphabetically by printing each on a new line and piping to sort
    COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))

    # Trim the colon prefix from completion entries if necessary
    __ltrim_colon_completions "$cur"
}

complete -F _ollama_completions ollama
