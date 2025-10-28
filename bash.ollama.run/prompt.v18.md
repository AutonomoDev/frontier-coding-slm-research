# Bash Completion for `ollama run`

## 🚨 Key Bugs to Avoid

- **Indexing:** Check `COMP_WORDS[0] == "ollama"` and `COMP_WORDS[1] == "run"`. Add `[[ $COMP_CWORD -ne 2 ]] && return 0`.
- **Colons:** Use `_get_comp_words_by_ref -n : cur prev`. Call `__ltrim_colon_completions "$cur"` after COMPREPLY. Without both, stops at ":".
- **Parsing:** Skip header with `tail -n +2 | awk '{print $1}'`. No raw output.
- **Completions:** Use `compgen -W "${models[*]}" -- "$cur"`. No manual loops or filters – that's redundant and buggy.
- **Sorting:** Sort models before compgen or COMPREPLY after. compgen doesn't sort.
- **Overcomplication:** Stick to basics; extra logic (e.g., wrong compgen flags) breaks colons.

## Task
Make script for `ollama run <model>`:
- Activates only for `ollama run`
- Handles colons (e.g., `codellama:13b`)
- Parses `ollama list` correctly
- Completes only model arg

## Colon Info
- For `codellama:<TAB>`, suggest after ":".
- `_get_comp_words_by_ref -n :` sets cur="codellama:".
- compgen matches full.
- `__ltrim_colon_completions` trims for insert.

## Sample Output
```
NAME ID SIZE MODIFIED
codegemma:7b ... 
codellama:13b ...
codellama:34b ...
```

## Steps (Follow Exactly)

1. Function: `_ollama_completions()`

2. Check:
   ```bash
   [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return 0; }
   [[ $COMP_CWORD -ne 2 ]] && return 0;
   ```

3. Colons:
   - local cur prev
   - `if type _get_comp_words_by_ref &>/dev/null; then _get_comp_words_by_ref -n : cur prev; else cur="${COMP_WORDS[COMP_CWORD]}"; prev="${COMP_WORDS[COMP_CWORD-1]}"; fi`

4. Parse:
   - local models=()
   - `if command -v ollama &>/dev/null; then models=($(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')); fi`

5. Completions:
   - Sort: `IFS=$'\n' models=($(sort <<<"${models[*]}")); unset IFS`
   - `COMPREPLY=( $(compgen -W "${models[*]}" -- "$cur") )`

6. Fix Colons:
   ```bash
   if type __ltrim_colon_completions &>/dev/null; then __ltrim_colon_completions "$cur"; fi
   ```

7. Register: `complete -F _ollama_completions ollama`

## Output Rules
- ONLY BASH CODE – no extras
- Inline comments for key parts
- Handle edges (no ollama, no models)

## Checklist
- [ ] Correct index check
- [ ] COMP_CWORD check
- [ ] _get_comp_words_by_ref -n :
- [ ] __ltrim_colon_completions last
- [ ] Parse with tail/awk
- [ ] compgen -W (no manual)
- [ ] Sort
- [ ] Edges handled
- [ ] Works after ":"
