```bash
#!/usr/bin/env bash

## 🚫 Do Not:
# - Add COMP_CWORD or fallback logic.
# - Check for `_get_comp_words_by_ref` or `__ltrim_colon_completions` existence.
# - Use arrays for models.
# - Sort input models.

## ✅ Must Do (Exact Steps)

# 1. Function
_ollama_completions() {

    # 2. Validate command
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && return

    # 3. Extract word info
    local cur prev
    _get_comp_words_by_ref -n : cur prev

    # 4. Fetch models
    if ! command -v ollama &>/dev/null; then return; fi
    local models
    models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
    [[ -z "$models" ]] && return

    # 5. Generate completions
    COMPREPLY=($(compgen -W "$models" -- "$cur"))

    # 6. Sort + trim
    COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
    __ltrim_colon_completions "$cur"
}

complete -F _ollama_completions ollama
```

