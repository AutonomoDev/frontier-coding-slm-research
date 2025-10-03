# <think>We have a prompt: " ==== PROMPT v13 ====" which instructs "You are an expert in Bash shell completion." It says generate a completion script for the command 'ollama run <model>' that works correctly. The Critical Requirements:
# 1. ONLY activate when the command is `ollama run` (i.e. first argument is "run").
# - In COMP_WORDS:
#   - [0] = command name (ollama)
#   - [1] = first argument (run)
#   - [2] = current word
# - Correct: Check `[0]=="ollama"` AND `[1]=="run"`
# - Never check `[1]=="ollama"` or `[2]=="run"`
# 
# 2. Handle colons in model names, e.g., "llama:7b". Use `_get_comp_words_by_ref -n :` to prevent colon splitting, always call `__ltrim_colon_completions "$cur"` at the end.
# 
# 3. Process `ollama list` output correctly:
# - Skip header line (NAME ID SIZE MODIFIED)
# - Skip empty lines
# - Extract model names from first column
# 
# Then "Common Pitfalls: never reference COMP_WORDS[1] as command name, etc." Then further instructions: "Your Fix:" The root cause is incorrect array indexing. Generate a script that only changes the condition check to use:
# 
# `[[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]`
# 
# The output format: Provide ONLY the corrected Bash completion script (no explanations). Ensure identical structure to original Gemma 27b script. Only the condition line is modified, all other logic remains unchanged.
# 
# So we need a bash completion script that only modifies the condition check.
# 
# Now I'm reading this carefully:
# 
# We need to generate a "completion script" for `ollama run <model>`. The instructions: "Your Fix:" It says "The root cause is incorrect array indexing." So basically there's some code and we need to change the conditional line to something like:
# ```
# [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && return
# ```
# But the original script might have a condition that looks wrong. The instructions say: generate only the corrected Bash completion script with only condition check changed.
# 
# I must ensure to handle colon splitting with `_get_comp_words_by_ref -n :` and call `__ltrim_colon_completions "$cur"` at the end.
# 
# Also process `ollama list` output by skipping the header line and empty lines and extracting the first column (model names).
# 
# End of human comment.</think>
#!/bin/bash
_ollama_run_completion() {
    local cur prev words cword
    _init_completion || return

    # Only complete if command is "ollama run"
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && return

    # Handle colons in model names
    _get_comp_words_by_ref -n ':' cur words

    # Get model names from `ollama list`, skip header and empty lines, take first column
    local models
    models="$(ollama list | sed '1d' | grep -v '^$' | awk '{print $1}')"

    COMPREPLY=( $(compgen -W "$models" -- "$cur") )

    __ltrim_colon_completions "$cur"
}
complete -F _ollama_run_completion ollama
