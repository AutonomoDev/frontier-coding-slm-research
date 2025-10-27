# [[HUMAN COMMENTED-OUT]]
# As a language model, I have analyzed the v9 and v14 versions of the prompt and understand their strengths and weaknesses. To create a robust Bash completion script for the `ollama run` command, we will follow these guidelines:
# [[HUMAN COMMENTED-OUT]]
# 1. **Synthesize, don't just add**: Instead of listing bugs, we will integrate solutions into a single, coherent "Golden Path" implementation.
# 2. **Create a unified 'Colon Solution'**: We will present the `COMP_WORDBREAKS` modification and the `__ltrim_colon_completions` call as two mandatory parts of a single, unified solution to the colon problem. This treats the cause (parsing) and the symptom (display) together.
# 3. **Provide a clear code skeleton**: Give a high-level structural example of the main function. This provides a scaffold for the LLM to build upon, reducing the chance of it generating a malformed structure.
# 4. **Emphasize early exit**: The "completes with files" error happens when the script doesn't exit correctly for non-relevant commands. We need to make the context check and early return a non-negotiable first step.
# 5. **Refine language**: Use clear, authoritative, and direct language. Organize the prompt logically from high-level goals to low-level implementation details, culminating in a final checklist for reinforcement.
# [[HUMAN COMMENTED-OUT]]
# Here is the proposed v17 prompt:
# [[HUMAN COMMENTED-OUT]]
# ---
# ### ==== bash.ollama.run/prompt.v17.md ====
# # AI Bash Completion Expert: `ollama run` Script
# [[HUMAN COMMENTED-OUT]]
# ## Primary Objective
# Your sole task is to generate a single, production-quality Bash completion script for the `ollama run` command. The script must be robust, efficient, and correctly handle model names containing colons.
# [[HUMAN COMMENTED-OUT]]
# ## Core Challenge: The Colon Problem
# Bash completions fail with model names like `codellama:13b` because the colon (`:`) is a default word separator. This breaks the logic for identifying the current word to complete. Your script **must** implement the complete, two-part solution for this.
# [[HUMAN COMMENTED-OUT]]
# ### The MANDATORY Two-Part Colon Fix
# 1.  **Correctly Parse the Input:** Temporarily remove the colon from `COMP_WORDBREAKS` and use `_get_comp_words_by_ref -n :` to re-parse the command-line words. This ensures that when the user types `ollama run codellama:`, the `prev` word is `run`, not `codellama`.
# 2.  **Correctly Display the Suggestions:** After generating the list of possible completions, you **must** call the bash-completion helper function `__ltrim_colon_completions "$cur"` to ensure the suggestions are displayed correctly after a colon has been typed.
# [[HUMAN COMMENTED-OUT]]
# ## Implementation Requirements (Follow Precisely)
# [[HUMAN COMMENTED-OUT]]
# ### 1. Script Structure & Entry Point
# -   Define a single function, `_ollama_completions`.
# -   **CRITICAL:** The very first action inside the function must be to check if the command is `ollama run`. Check that `COMP_WORDS[1]` is exactly `run`. If it is not, the function must `return` immediately to prevent interference with other commands and to avoid falling back to filename completion.
# [[HUMAN COMMENTED-OUT]]
# ### 2. The Colon Fix Implementation
# -   Inside the `ollama run` logic block, implement the Two-Part Colon Fix as described above. Provide clear comments explaining this block.
#     -   Save original `COMP_WORDBREAKS`.
#     -   Remove `:` from `COMP_WORDBREAKS`.
#     -   Call `_get_comp_words_by_ref -n : cur prev`.
#     -   Immediately restore the original `COMP_WORDBREAKS`.
# [[HUMAN COMMENTED-OUT]]
# ### 3. Dynamic Model List Generation
# -   Check if the `ollama` command is available on the system (`command -v ollama &>/dev/null`).
# -   Fetch the list of models by running `ollama list`.
# -   Parse the output: skip the header line (`NAME ID...`) and extract only the first column (the model name). `awk 'NR>1 {print $1}'` is the recommended method.
# [[HUMAN COMMENTED-OUT]]
# ### 4. Generating and Returning Completions
# -   Use `compgen -W "<list_of_models>" -- "$cur"` to generate the completion suggestions for the current word (`$cur`).
# -   Store the result in the `COMPREPLY` array.
# -   As the final step before the function ends, call `__ltrim_colon_completions "$cur"`. This is non-negotiable.
# [[HUMAN COMMENTED-OUT]]
# ### 5. Registration
# -   Register the completion function for the `ollama` command using `complete -F _ollama_completions ollama`.
# [[HUMAN COMMENTED-OUT]]
# ## Output Format (Strictly Enforced)
# -   **CODE ONLY.** Your entire output must be a single, contiguous block of Bash code.
# -   **NO MARKDOWN, NO EXPLANATIONS, NO PREAMBLE.** The output must be ready to be saved directly to a `.sh` file.
# -   Include detailed inline comments within the code to explain complex parts, especially the context check and the colon-handling logic.
# [[HUMAN COMMENTED-OUT]]
# ## Final Verification Checklist
# Your generated script absolutely **MUST**:
# - [ ] Check `COMP_WORDS[1]` to confirm the subcommand is `run` and exit otherwise.
# - [ ] Implement the `COMP_WORDBREAKS` modification and restoration.
# - [ ] Use `_get_comp_words_by_ref -n :` to get `cur` and `prev`.
# - [ ] Parse `ollama list` output correctly, skipping the header.
# - [ ] Call `__ltrim_colon_completions "$cur"` as the last step after setting `COMPREPLY`.
# - [ ] Consist of only Bash code and its internal comments.
# [[HUMAN COMMENTED-OUT]]
# ---
# I hope this revised prompt meets your expectations. Let me know if you have any further questions or concerns.
