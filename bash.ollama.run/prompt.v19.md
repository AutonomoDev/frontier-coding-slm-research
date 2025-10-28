# Bash Completion Script Generation for `ollama run`

## 🚨 CRITICAL BUGS TO AVOID (READ FIRST!)

- **Indexing:** Check ONLY `COMP_WORDS[0] == "ollama"` and `COMP_WORDS[1] == "run"`. Do NOT add COMP_CWORD checks.
- **Colons:** ALWAYS use `_get_comp_words_by_ref -n : cur prev` without if type check or fallback. ALWAYS call `__ltrim_colon_completions "$cur"` without if type check, after setting and sorting COMPREPLY.
- **Parsing:** Use scalar string for models: models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}'). Do NOT use array assignment here.
- **Completions:** Use compgen -W "$models" -- "$cur". Wrap in COMPREPLY=($(compgen ... )) to make array.
- **Sorting:** Sort ONLY the COMPREPLY after compgen, using COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort)). Do NOT sort models. Do NOT use <<<"${models[*]}" or similar – that breaks sorting because it creates a single space-separated line.
- **Overcomplication:** Do NOT add unnecessary if type checks, fallbacks, or manual loops. Stick exactly to the structure – extra code causes failures at ":".

## Task
Generate a BASH_COMPLETION FUNCTION for `ollama run <model>`:
- Activates only for `ollama run`
- Handles colons (e.g., `codellama:13b`)
- Parses `ollama list` correctly

## Colon Info
- For `codellama:<TAB>`, must suggest "13b", "34b", etc.
- `_get_comp_words_by_ref -n :` sets cur="codellama:"
- compgen matches full names
- `__ltrim_colon_completions` trims prefix from COMPREPLY elements

## Sample Output
```
NAME ID SIZE MODIFIED
codegemma:7b ...
codellama:13b ...
codellama:34b ...
```

## Requirements (Follow Exactly)

1. **Function:** `_ollama_completions()`

2. **Check:**
   ```bash
   # Check if command is "ollama run"
   [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }
   ```

3. **Colons:**
   - local cur prev
   - _get_comp_words_by_ref -n : cur prev

4. **Parse Models:**
   - if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
   - local models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
   - if [ -z "$models" ]; then COMPREPLY=(); return; fi

5. **Completions:**
   - COMPREPLY=($(compgen -W "$models" -- "$cur"))

6. **Sort:**
   - COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))

7. **Fix Colons:**
   - __ltrim_colon_completions "$cur"

8. **Register:** `complete -F _ollama_completions ollama`

## Output Instructions
- **OUTPUT ONLY BASH CODE** - no markdown, no explanations, no headers
- Include inline comments explaining critical sections
- Make it production-ready and robust
- Handle all edge cases (no models, command not found, etc.)

## Verification Checklist
Your script MUST:
- [ ] Check COMP_WORDS[0] and [1] correctly (no COMP_CWORD)
- [ ] Use _get_comp_words_by_ref -n : without check
- [ ] Parse to scalar models=$(tail | awk)
- [ ] compgen -W "$models" wrapped in (())
- [ ] Sort COMPREPLY with printf | sort
- [ ] Call __ltrim_colon_completions without check, after sort
- [ ] Handle no ollama and empty models with COMPREPLY=(); return
- [ ] Work with colons (suggestions after :)
