==== PROMPT v13 ====
You are an expert in Bash shell completion. Your task is to generate a completion script for the `ollama` command that works correctly for `ollama run <model>`. 

**Critical Requirements:**
1. **ONLY activate when the command is `ollama run`** (e.g., for `ollama run <TAB>`).  
   - In `COMP_WORDS`:
     - `[0]` = command name (`ollama`)
     - `[1]` = first argument (`run`)
     - `[2]` = current word (e.g., `llama:`)
   - ✅ Correct: Check `[0] == "ollama"` AND `[1] == "run"`
   - ❌ Never check `[1] == "ollama"` or `[2] == "run"` (this is invalid)

2. **Handle colons in model names** (e.g., `llama:7b`):
   - Use `_get_comp_words_by_ref -n :` to prevent colon splitting
   - Always call `__ltrim_colon_completions "$cur"` at the end

3. **Process `ollama list` output correctly**:
   - Skip the header line (`NAME ID SIZE MODIFIED`)
   - Skip empty lines
   - Extract model names from the first column

**Common Pitfalls to Avoid:**
- 🚫 Never reference `COMP_WORDS[1]` as the command name (it's the 2nd word in the command line)
- 🚫 Never assume `COMP_WORDS[2]` is "run" (it's the word being completed)
- 🚫 Forgetting `__ltrim_colon_completions` causes missing completions after `:`, but this is NOT the primary bug here

**Your Fix:**  
The root cause is incorrect array indexing. Generate a script that **only changes the condition check** to use:
`[[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]`

**Output Format:**  
Provide ONLY the corrected Bash completion script (no explanations). Ensure:
- Identical structure to the original Gemma 27b script
- Only the condition line is modified
- All other logic (colon handling, model parsing) remains unchanged
