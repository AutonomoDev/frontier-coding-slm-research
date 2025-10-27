# [[HUMAN COMMENTED-OUT]]
# Your analysis is thorough and well-structured. The strategy for v17 aims to combine the clarity of v9 with the completeness of v14, while simplifying the structure to reduce cognitive load. Here's a refined version of the proposed v17 prompt based on your detailed plan:
# [[HUMAN COMMENTED-OUT]]
# ---
# [[HUMAN COMMENTED-OUT]]
# ### ==== bash.ollama.run/prompt.v17.md ====
# [[HUMAN COMMENTED-OUT]]
# # AI Bash Completion Expert: `ollama run` Script
# [[HUMAN COMMENTED-OUT]]
# ## Primary Objective
# [[HUMAN COMMENTED-OUT]]
# Your sole task is to generate a single, production-quality Bash completion script for the `ollama run` command. The script must be robust, efficient, and correctly handle model names containing colons.
# [[HUMAN COMMENTED-OUT]]
# ## Core Challenge: The Colon Problem
# [[HUMAN COMMENTED-OUT]]
# Bash completions fail with model names like `codellama:13b` because the colon (`:`) is a default word separator. This breaks the logic for identifying the current word to complete. Your script **must** implement the complete, two-part solution for this.
# [[HUMAN COMMENTED-OUT]]
# ### The MANDATORY Two-Part Colon Fix
# [[HUMAN COMMENTED-OUT]]
# 1.  **Correctly Parse the Input:** Temporarily remove the colon from `COMP_WORDBREAKS` and use `_get_comp_words_by_ref -n :` to re-parse the command-line words. This ensures that when the user types `ollama run codellama:`, the `prev` word is `run`, not `codellama`.
# [[HUMAN COMMENTED-OUT]]
# 2.  **Correctly Display the Suggestions:** After generating the list of possible completions, you **must** call the bash-completion helper function `__ltrim_colon_completions "$cur"` to ensure the suggestions are displayed correctly after a colon has been typed.
# [[HUMAN COMMENTED-OUT]]
# ## Implementation Requirements (Follow Precisely)
# [[HUMAN COMMENTED-OUT]]
# ### 1. Script Structure & Entry Point
# [[HUMAN COMMENTED-OUT]]
# -   Define a single function, `_ollama_completions`.
# [[HUMAN COMMENTED-OUT]]
# -   **CRITICAL:** The very first action inside the function must be to check if the command is `ollama run`. Check that `COMP_WORDS[1]` is exactly `run`. If it is not, the function must `return` immediately to prevent interference with other commands and to avoid falling back to filename completion.
# [[HUMAN COMMENTED-OUT]]
# ### 2. The Colon Fix Implementation
# [[HUMAN COMMENTED-OUT]]
# -   Inside the `ollama run` logic block, implement the Two-Part Colon Fix as described above. Provide clear comments explaining this block.
# [[HUMAN COMMENTED-OUT]]
# -   Save original `COMP_WORDBREAKS`.
# [[HUMAN COMMENTED-OUT]]
# -   Remove `:` from `COMP_WORDBREAKS`.
# [[HUMAN COMMENTED-OUT]]
# -   Call `_get_comp_words_by_ref -n : cur prev`.
# [[HUMAN COMMENTED-OUT]]
# -   Immediately restore the original `COMP_WORDBREAKS`.
# [[HUMAN COMMENTED-OUT]]
# ### 3. Dynamic Model List Generation
# [[HUMAN COMMENTED-OUT]]
# -   Check if the `ollama` command is available on the system (`command -v ollama &>/dev/null`).
# [[HUMAN COMMENTED-OUT]]
# -   Fetch the list of models by running `ollama list`.
# [[HUMAN COMMENTED-OUT]]
# -   Parse the output: skip the header line (`NAME ID...`) and extract only the first column (the model name). `awk 'NR>1 {print $1}'` is the recommended method.
# [[HUMAN COMMENTED-OUT]]
# ### 4. Generating and Returning Completions
# [[HUMAN COMMENTED-OUT]]
# -   Use `compgen -W "<list_of_models>" -- "$cur"` to generate the completion suggestions for the current word (`$cur`).
# [[HUMAN COMMENTED-OUT]]
# -   Store the result in the `COMPREPLY` array.
# [[HUMAN COMMENTED-OUT]]
# -   As the final step before the function ends, call `__ltrim_colon_completions "$cur"`. This is non-negotiable.
# [[HUMAN COMMENTED-OUT]]
# ### 5. Registration
# [[HUMAN COMMENTED-OUT]]
# -   Register the completion function for the `ollama` command using `complete -F _ollama_completions ollama`.
# [[HUMAN COMMENTED-OUT]]
# ## Output Format (Strictly Enforced)
# [[HUMAN COMMENTED-OUT]]
# -   **CODE ONLY.** Your entire output must be a single, contiguous block of Bash code.
# [[HUMAN COMMENTED-OUT]]
# -   **NO MARKDOWN, NO EXPLANATIONS, NO PREAMBLE.** The output must be ready to be saved directly to a `.sh` file.
# [[HUMAN COMMENTED-OUT]]
# -   Include detailed inline comments within the code to explain complex parts, especially the context check and the colon-handling logic.
# [[HUMAN COMMENTED-OUT]]
# ## Final Verification Checklist
# [[HUMAN COMMENTED-OUT]]
# Your generated script absolutely **MUST**:
# [[HUMAN COMMENTED-OUT]]
# - [ ] Check `COMP_WORDS[1]` to confirm the subcommand is `run` and exit otherwise.
# [[HUMAN COMMENTED-OUT]]
# - [ ] Implement the `COMP_WORDBREAKS` modification and restoration.
# [[HUMAN COMMENTED-OUT]]
# - [ ] Use `_get_comp_words_by_ref -n :` to get `cur` and `prev`.
# [[HUMAN COMMENTED-OUT]]
# - [ ] Parse `ollama list` output correctly, skipping the header.
# [[HUMAN COMMENTED-OUT]]
# - [ ] Call `__ltrim_colon_completions "$cur"` as the last step after setting `COMPREPLY`.
# [[HUMAN COMMENTED-OUT]]
# - [ ] Consist of only Bash code and its internal comments.
# [[HUMAN COMMENTED-OUT]]
# ---
# [[HUMAN COMMENTED-OUT]]
# This refined prompt should provide a clear and structured guide for generating an effective completion script while minimizing potential errors.
