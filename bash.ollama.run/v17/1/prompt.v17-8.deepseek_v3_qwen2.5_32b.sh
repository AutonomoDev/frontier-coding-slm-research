# [[HUMAN COMMENTED-OUT]]
# AI Bash Completion Expert: `ollama run` Script
# 
# ## Primary Objective
# Your sole task is to generate a single, production-quality Bash completion script for the `ollama run` command. The script must be robust, efficient, and correctly handle model names containing colons.
# 
# ## Core Challenge: The Colon Problem
# Bash completions fail with model names like `codellama:13b` because the colon (`:`) is a default word separator. This breaks the logic for identifying the current word to complete. Your script **must** implement the complete, two-part solution for this.
# 
# ### The MANDATORY Two-Part Colon Fix
# 1.  **Correctly Parse the Input:** Temporarily remove the colon from `COMP_WORDBREAKS` and use `_get_comp_words_by_ref -n :` to re-parse the command-line words. This ensures that when the user types `ollama run codellama:`, the `prev` word is `run`, not `codellama`.
# 2.  **Correctly Display the Suggestions:** After generating the list of possible completions, you **must** call the bash-completion helper function `__ltrim_colon_completions "$cur"` to ensure the suggestions are displayed correctly after a colon has been typed.
# 
# ## Implementation Requirements (Follow Precisely)
# 
# ### 1. Script Structure & Entry Point
# -   Define a single function, `_ollama_completions`.
# -   **CRITICAL:** The very first action inside the function must be to check if the command is `ollama run`. Check that `COMP_WORDS[1]` is exactly `run`. If it is not, the function must `return` immediately to prevent interference with other commands and to avoid falling back to filename completion.
# 
# ### 2. The Colon Fix Implementation
# -   Inside the `ollama run` logic block, implement the Two-Part Colon Fix as described above. Provide clear comments explaining this block.
#     -   Save original `COMP_WORDBREAKS`.
#     -   Remove `:` from `COMP_WORDBREAKS`.
#     -   Call `_get_comp_words_by_ref -n : cur prev`.
#     -   Immediately restore the original `COMP_WORDBREAKS`.
# 
# ### 3. Dynamic Model List Generation
# -   Check if the `ollama` command is available on the system (`command -v ollama &>/dev/null`).
# -   Fetch the list of models by running `ollama list`.
# -   Parse the output: skip the header line (`NAME ID...`) and extract only the first column (the model name). Use `awk 'NR>1 {print $1}'`.
# 
# ### 4. Generating and Returning Completions
# -   Use `compgen -W "<list_of_models>" -- "$cur"` to generate the completion suggestions for the current word (`$cur`).
# -   Store the result in the `COMPREPLY` array.
# -   As the final step before the function ends, call `__ltrim_colon_completions "$cur"`. This is non-negotiable.
# 
# ### 5. Registration
# -   Register the completion function for the `ollama` command using `complete -F _ollama_completions ollama`.
# 
# ## Output Format (Strictly Enforced)
# -   **CODE ONLY.** Your entire output must be a single, contiguous block of Bash code.
# -   **NO MARKDOWN, NO EXPLANATIONS, NO PREAMBLE.**
# -   Include detailed inline comments within the code to explain complex parts.
# 
# ### Example Code Skeleton

_ollama_completions() {
    # Ensure the subcommand is 'run'; exit early if not
    [[ "${COMP_WORDS[1]}" != "run" ]] && return

    # Save original COMP_WORDBREAKS and modify it to handle colon
    local orig_wb="$COMP_WORDBREAKS"
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}
    _get_comp_words_by_ref -n : cur prev
    COMP_WORDBREAKS="$orig_wb"

    # Ensure 'ollama' is available to avoid errors
    command -v ollama &>/dev/null || return

    # Fetch and parse model names, skipping the header line
    local models=($(ollama list | awk 'NR>1 {print $1}'))
    
    # Generate completions and apply colon trimming
    COMPREPLY=( $(compgen -W "${models[*]}" -- "$cur") )
    __ltrim_colon_completions "$cur"
}

# Register the completion function
complete -F _ollama_completions ollama

# [[HUMAN COMMENTED-OUT]]
# 
# ## Final Verification Checklist
# Your generated script **MUST**:
# - [ ] Check `COMP_WORDS[1]` and exit if not 'run'.
# - [ ] Modify and restore `COMP_WORDBREAKS`.
# - [ ] Use `_get_comp_words_by_ref -n :`.
# - [ ] Parse `ollama list` correctly.
# - [ ] Call `__ltrim_colon_completions "$cur"`.
