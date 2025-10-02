==== PROMPT v14 ====

# Bash Completion Script Generation for `ollama run`

## 🚨 CRITICAL BUGS TO AVOID (READ FIRST!)

### Bug #1: Array Indexing (MOST COMMON ERROR)
- ✅ **CORRECT:** Check `COMP_WORDS[0] == "ollama"` AND `COMP_WORDS[1] == "run"`
  - `[0]` = command name (`ollama`)
  - `[1]` = first argument (`run`)
  - `[2]` = current word being completed
- ❌ **WRONG:** Never check `[1] == "ollama"` or `[2] == "run"` (this breaks everything!)

### Bug #2: Colon Handling (BREAKS COMPLETIONS)
- **MUST DO:** Call `__ltrim_colon_completions "$cur"` after setting COMPREPLY
- **WHY:** Without this, NO suggestions appear after typing `:` in model names like `codellama:`
- **ALSO:** Use `_get_comp_words_by_ref -n :` to prevent Bash from splitting on colons

### Bug #3: Parsing `ollama list` Output
- 🚫 Don't use raw output - it includes headers and extra columns
- ✅ Skip header line "NAME ID SIZE MODIFIED"
- ✅ Extract ONLY the first column (model name) using `awk '{print $1}'`

## Task
Generate a robust Bash completion script for `ollama run <model>` that:
1. ONLY activates for the specific command `ollama run`
2. Correctly handles model names with colons (e.g., `codellama:13b`)
3. Parses `ollama list` output properly to get model names

## Context & Technical Details

### The Colon Problem
- Bash splits words on `:` by default
- If user types `codellama:`, Bash sees `prev="codellama"` and `cur=""` (empty)
- Solution: Use `_get_comp_words_by_ref -n :` and `__ltrim_colon_completions`

### Sample `ollama list` Output
```
NAME                    ID              SIZE    MODIFIED
codegemma:7b           0c96700aaada    5.0 GB  12 days ago
codellama:13b          9f438cb9cd58    7.4 GB  12 days ago
codellama:34b          685be00e1532    19 GB   12 days ago
```

## Requirements (Follow Exactly)

1. **Function Declaration:** Create `_ollama_completions()`

2. **Array Index Check (CRITICAL):**
   ```bash
   # Check if command is "ollama run"
   [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }
   ```

3. **Handle Colons:**
    - Try: `_get_comp_words_by_ref -n : cur prev`
    - Fallback: Manual extraction from COMP_WORDS

4. **Parse Models:**
    - Check `ollama` exists: `command -v ollama &>/dev/null`
    - Run: `ollama list 2>/dev/null`
    - Parse line-by-line, skip header, extract first column
    - Build array of model names

5. **Generate Completions:**
    - Filter models matching current prefix
    - Sort results
    - Set COMPREPLY using `compgen`

6. **Fix Colon Display (MANDATORY):**
   ```bash
   __ltrim_colon_completions "$cur"  # NEVER SKIP THIS!
   ```

7. **Register:** `complete -F _ollama_completions ollama`

## Output Instructions
- **OUTPUT ONLY BASH CODE** - no markdown, no explanations, no headers
- Include inline comments explaining critical sections
- Make it production-ready and robust
- Handle all edge cases (no models, command not found, etc.)

## Verification Checklist
Your script MUST:
- [ ] Check COMP_WORDS[0] and [1] correctly (not [1] and [2])
- [ ] Call __ltrim_colon_completions at the end
- [ ] Parse ollama list output properly
- [ ] Handle missing ollama command gracefully
- [ ] Work with model names containing colons
