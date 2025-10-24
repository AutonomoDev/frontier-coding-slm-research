# Bash Completion Script Generation for `ollama run`
## 🚨 CRITICAL BUGS TO AVOID (READ FIRST! - BASED ON PRIOR VERSIONS)
### Bug #1: Array Indexing (MOST COMMON FAILURE - FIX FROM V14)
- ✅ **CORRECT:** Always check `COMP_WORDS[0] == "ollama"` AND `COMP_WORDS[1] == "run"` at the start of the function.
  - `[0]` = command name (`ollama`)
  - `[1]` = first argument (`run`)
  - Current completion is always at index `[2]` or later for the model.
- ❌ **WRONG:** Never check `[1] == "ollama"` or `[2] == "run"` - this causes no suggestions or file fallback!
### Bug #2: Colon Handling (KEY TO PERFECTION - COMBINE V9 + V14)
- **MUST DO (EXACTLY):** Temporarily modify `COMP_WORDBREAKS` to remove `:`, reparse with `_get_comp_words_by_ref -n : cur prev`, then restore. This fixes `cur` for prefixes like "codellama:".
- **MANDATORY FINISH:** Call `__ltrim_colon_completions "$cur"` **immediately after** setting `COMPREPLY`. Without this, suggestions vanish after typing `:` (v9 failure mode).
- **WHY:** Bash splits on `:` by default, making `cur=""` after `:`. Reparse treats "codellama:13b" as one word; ltrim displays suffixes like "13b" correctly.
### Bug #3: Parsing `ollama list` (SIMPLIFY FROM V9 FOR RELIABILITY)
- 🚫 Avoid complex line-by-line loops - small models mess them up, causing "no suggestions".
- ✅ Use simple, robust: `ollama list | awk 'NR>1 {print $1}'` to extract model names (skips header automatically).
### Bug #4: Registration & Fallbacks (NEW - PREVENTS FILE AUTOCOMPLETE)
- **MUST INCLUDE:** End with `complete -F _ollama_completions ollama` - missing this causes file suggestions in PWD!
- **ALWAYS SET `COMPREPLY`:** Even if no models or `ollama` missing, set `COMPREPLY=()` explicitly after checks. Never leave unset (triggers defaults).
## Task
Generate a **complete, self-contained** Bash completion script for **only** `ollama run <model>`. It must:
1. Activate **exclusively** after `ollama run`.
2. Dynamically complete model names from `ollama list`, handling colons perfectly (e.g., suggest "13b" after "codellama:<tab>").
3. Be robust: handle missing `ollama`, no models, errors gracefully (empty `COMPREPLY`, no crashes).
4. Produce **perfect** behavior: suggestions work before/after `:`, no stopping at `:`, no file fallbacks.
## Context & Technical Details
### The Colon Problem (V9 Solution Integrated)
- Default: Typing "codellama:<tab>" sets `prev="codellama"`, `cur=""` → no matches.
- Fix: Reparse without `:` break → `cur="codellama:"`, `prev="run"`.
- Then match full models (e.g., "codellama:13b" starts with "codellama:"), set `COMPREPLY` to full matches.
- Ltrim: Trims `COMPREPLY` to suffixes (e.g., "13b") for clean display/insertion.
### Sample `ollama list` Output
```
NAME ID SIZE MODIFIED
codegemma:7b 0c96700aaada 5.0 GB 12 days ago
codellama:13b 9f438cb9cd58 7.4 GB 12 days ago
codellama:34b 685be00e1532 19 GB 12 days ago
codestral:22b 0898a8b286d5 12 GB 12 days ago
```
- Extract: `codegemma:7b`, `codellama:13b`, etc.
## Requirements (FOLLOW THIS EXACT SKELETON - FILL IN NOTHING ELSE)
1. **Function Declaration:** `_ollama_completions() { ... }`
2. **Exact Indexing Check (Copy This):**
   ```bash
   # CRITICAL: Check if completing after "ollama run"
   [[ ${COMP_WORDS[0]} != "ollama" || ${COMP_WORDS[1]} != "run" ]] && { COMPREPLY=(); return 0; }
   ```
3. **Exact Colon Handling (Copy From V9 - ALWAYS DO THIS):**
   ```bash
   # Handle colons: Temporarily remove ':' from word breaks to reparse correctly
   local _old_wb=${COMP_WORDBREAKS}
   COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}
   _get_comp_words_by_ref -n : cur prev
   COMP_WORDBREAKS=${_old_wb}
   # Now cur/prev are correct (e.g., cur="codellama:13", prev="run")
   ```
4. **Check & Parse Models (Simple V9 Style):**
   ```bash
   # Check if ollama available
   command -v ollama &>/dev/null || { COMPREPLY=(); return 0; }
   # Extract models robustly (skip header, get names only)
   local models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}')
   # If no models, empty reply
   [[ -z $models ]] && { COMPREPLY=(); return 0; }
   ```
5. **Generate Completions:**
   ```bash
   # Filter and set completions
   COMPREPLY=( $(compgen -W "$models" -- "$cur") )
   # MANDATORY: Fix display after colons
   __ltrim_colon_completions "$cur"
   return 0
   ```
6. **Register (MANDATORY - LAST LINE):**
   ```bash
   complete -F _ollama_completions ollama
   ```
## Output Instructions
- **OUTPUT ONLY THE BASH CODE** - a single contiguous block: function + registration. No markdown, no text, no extras. Saveable as `.sh`.
- Include **brief inline comments** only on critical lines (e.g., why reparse).
- Make it **production-ready**: Handle errors, sort if easy (`| sort`), but prioritize reliability over extras.
- **NO FALLBACKS NEEDED** - the skeleton covers all cases; don't add manual parsing.
## Verification Checklist (MENTALLY CHECK BEFORE OUTPUT)
Your script MUST pass these for perfection:
- [ ] Includes exact index check at top → no file fallbacks.
- [ ] Full WORDBREAKS save/modify/reparse/restore → cur handles colons.
- [ ] Simple `awk` parsing → always gets models.
- [ ] Sets `COMPREPLY` in all branches (checks, no ollama, no models).
- [ ] Calls `__ltrim_colon_completions "$cur"` after `COMPREPLY=(...)` → suggestions after `:`.
- [ ] Ends with `complete -F _ollama_completions ollama` → activates completion.
- [ ] Works for: `ollama run <tab>` (all models), `ollama run codellama:<tab>` (tags like "13b"), `ollama run code<tab>` (full names).

