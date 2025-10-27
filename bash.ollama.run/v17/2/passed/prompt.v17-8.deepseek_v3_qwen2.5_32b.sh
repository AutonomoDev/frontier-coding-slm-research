# [[HUMAN COMMENTED-OUT]]
# ### Summary of v17 Strategy
# 
# **Objective:** To create a prompt that merges the simplicity of v9 with the completeness of v14, ensuring both technical accuracy and clarity.
# 
# #### Key Adjustments:
# 1. **Unified Colon Solution**: Explicitly combine `COMP_WORDBREAKS` modification and `__ltrim_colon_completions` into a mandatory step.
# 2. **Clear Script Skeleton**: Provide a high-level structure to prevent LLMs from getting lost in details, ensuring the context check is prioritized.
# 3. **Direct Language & Checks**: Use authoritative language to reduce ambiguity, emphasizing critical steps (e.g., early exit on wrong subcommand).
# 
# ### Proposed v17 Prompt
# 
# # AI Bash Completion Expert: `ollama run` Script
# 
# ## Primary Objective
# Your sole task is to generate a single, production-quality Bash completion script for the `ollama run` command. The script must be robust, efficient, and correctly handle model names containing colons.
# 
# ## Core Challenge: The Colon Problem
# Bash completions fail with model names like `codellama:13b` because the colon (`:`) is a default word separator. This breaks the logic for identifying the current word to complete. Your script **must** implement the complete, two-part solution for this.
# 
# ### The MANDATORY Two-Part Colon Fix
# 1. **Correctly Parse the Input:** Temporarily remove `:` from `COMP_WORDBREAKS` and use `_get_comp_words_by_ref -n : cur prev` to re-parse the command-line words.
# 2. **Correctly Display Suggestions:** After generating completions, call `__ltrim_colon_completions "$cur"`.
# 
# ## Implementation Requirements (Follow Precisely)
# 
# ### 1. Script Structure & Entry Point
# - Define a single function: `_ollama_completations`.
# - **First Action:** Check if `COMP_WORDS[1]` is exactly `run`. If not, return early to prevent interference.

_ollama_completions() {
    local cur prev subcmd
    COMPREPLY=()
    _get_comp_words_by_ref -n : cur prev

    # Exit immediately if the command is not 'ollama run'
    if [[ "${COMP_WORDS[1]}" != "run" ]]; then
        return 0
    fi

    # [[HUMAN COMMENTED-OUT]]
    # ### 2. Colon Fix Implementation

    local COMP_WORDBREAKS_ORIG=$COMP_WORDBREAKS
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}
    _get_comp_words_by_ref -n : cur prev
    COMP_WORDBREAKS=$COMP_WORDBREAKS_ORIG

    # [[HUMAN COMMENTED-OUT]]
    # ### 3. Dynamic Model List Generation

    if ! command -v ollama &>/dev/null; then
        return 0
    fi

    local models=$(ollama list | awk 'NR>1 {print $1}')

    # [[HUMAN COMMENTED-OUT]]
    # ### 4. Generating Completions

    COMPREPLY=( $(compgen -W "$models" -- "$cur") )
    __ltrim_colon_completions "$cur"
}

# [[HUMAN COMMENTED-OUT]]
# ### 5. Registration

complete -F _ollama_completions ollama

# [[HUMAN COMMENTED-OUT]]
# ## Output Format (Strictly Enforced)
# - **CODE ONLY**: Your output must be a single block of Bash code with inline comments.
#   
# **Final Verification Checklist**
# - [ ] `COMP_WORDS[1]` check and early return.
# - [ ] `COMP_WORDBREAKS` fix and restoration.
# - [ ] Proper use of `_get_comp_words_by_ref -n :`.
# - [ ] Header-skipping parsing for `ollama list`.
# - [ ] Call to `__ltrim_colon_completions "$cur"`.
# 
# ### Expected Output
# 
# _ollama_completions() {
#     local cur prev subcmd
#     COMPREPLY=()
#     _get_comp_words_by_ref -n : cur prev
# 
#     # Check if the command is 'ollama run'
#     if [[ "${COMP_WORDS[1]}" != "run" ]]; then
#         return 0
#     fi
# 
#     local COMP_WORDBREAKS_ORIG=$COMP_WORDBREAKS
#     COMP_WORDBREAKS=${COMP_WORDBREAKS//:}
#     _get_comp_words_by_ref -n : cur prev
#     COMP_WORDBREAKS=$COMP_WORDBREAKS_ORIG
# 
#     if ! command -v ollama &>/dev/null; then
#         return 0
#     fi
# 
#     local models=$(ollama list | awk 'NR>1 {print $1}')
# 
#     COMPREPLY=( $(compgen -W "$models" -- "$cur") )
#     __ltrim_colon_completions "$cur"
# }
# 
# complete -F _ollama_completions ollama
# 
# This approach balances simplicity with completeness, ensuring the script handles all edge cases correctly. The high-level structure and mandatory steps should guide the LLM effectively while reducing errors.
# 
# ### Next Steps
# 
# 1. **Testing**: Evaluate v17's performance by checking if it generates perfect scripts consistently.
# 2. **Iterative Refinement**: Use feedback to adjust any ambiguities or missed steps.
# 3. **Integration into Larger Project**: Ensure this script fits seamlessly with other parts of the project, like shell setup.
# 
# This structured approach should significantly improve the success rate while maintaining readability and robustness.
