# Bash Completion Generator — 

Generate a *single Bash function* that enables tab completion for `ollama`:
You need each of these...

  serve
  create      IMAGE_FILE --file Modefile, -q --quantize string
  show        <MODEL>
  run         <MODEL>
  stop        <MODEL>
  pull        
  push        <MODEL>
  signin      
  signout     
  list        
  ps          
  cp          <MODEL>
  rm          <MODEL>
  help        

Code in BASH not Python.
NEVER CODE IN PYTHON (!!!) ONLY BASH

---

## 🚫 Do Not:
- Add COMP_CWORD or fallback logic.
- Check for `_get_comp_words_by_ref` or `__ltrim_colon_completions` existence.
- Use arrays for models.
- Sort input models.

---

## ✅ Must Do (Exact Steps)

1. **Function**
   ```bash
   _ollama_completions() {
   ```

2. **Validate command**

substitute {{COMMAND}} with the actual command.
   ```bash
   [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "{{COMMAND}}" ]] && { COMPREPLY=(); return; }
   ```

3. **Extract word info**
   ```bash
   local cur prev
   _get_comp_words_by_ref -n : cur prev
   ```

4. **Fetch models**
   ```bash
   if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
   local models
   models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
   [[ -z "$models" ]] && { COMPREPLY=(); return; }
   ```

5. **Generate completions**
   ```bash
   COMPREPLY=($(compgen -W "$models" -- "$cur"))
   ```

6. **Sort + trim**
   ```bash
   COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
   __ltrim_colon_completions "$cur"
   }

   complete -F _ollama_completions ollama
   ```

---

## 📋 Output Rules
- Output **only Bash code**, no markdown.
- Inline comments for key logic.
- Must handle:
  - No `ollama` command
  - Empty model list
  - Colons (`codellama:<TAB>`)

---

## ✅ Verification Checklist
- [ ] Checks only COMP_WORDS[0] and [1]
- [ ] Uses `_get_comp_words_by_ref -n :`
- [ ] `models=$(...)` scalar string
- [ ] Uses `compgen -W "$models" -- "$cur"`
- [ ] Sorts COMPREPLY via `printf | sort`
- [ ] Calls `__ltrim_colon_completions "$cur"`
- [ ] Returns safely on missing/empty models

