# Bash Completion Script Generation Prompt

## Task
Create a robust Bash completion script for the `ollama run` command that handles model names containing colons (e.g., `codellama:13b`, `codegemma:7b`).

## Context
- Model names are retrieved via `ollama list` command
- Model names often contain colons which break standard bash completion
- The script must work with bash-completion framework v2

## Sample `ollama list` Output
```
NAME                            ID              SIZE    MODIFIED
codegemma:7b                    0c96700aaada    5.0 GB  12 days ago    
codellama:13b                   9f438cb9cd58    7.4 GB  12 days ago    
codellama:34b                   685be00e1532    19 GB   12 days ago    
codestral:22b                   0898a8b286d5    12 GB   12 days ago    
```

## Critical Requirements

### 1. Colon Handling (MOST IMPORTANT)
```bash
# MUST save and restore COMP_WORDBREAKS in ALL code paths
local old_wb="$COMP_WORDBREAKS"
COMP_WORDBREAKS=${COMP_WORDBREAKS//:}  # Remove colon
# ... completion logic ...
COMP_WORDBREAKS="$old_wb"  # ALWAYS restore before ANY return/exit
```

### 2. Position Detection
- Find the exact position of "run" in `COMP_WORDS` array
- Only trigger completion when `COMP_CWORD == run_index + 1`
- Do NOT assume fixed positions

### 3. Robust Data Parsing
```bash
# CORRECT: Handle variable whitespace
models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | awk '!seen[$0]++')

# WRONG: Fragile to spacing
models=$(ollama list 2>/dev/null | cut -d' ' -f1)
```

### 4. Helper Function Fallback
```bash
_get_comp_words_by_ref -n : cur prev words cword 2>/dev/null || {
    # Manual fallback when helper unavailable
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
}
```

### 5. Safe Filtering
```bash
# PREFERRED: Safe prefix matching
COMPREPLY=($(compgen -W "$models" -- "$cur"))

# AVOID: Regex issues with special characters
COMPREPLY=($(echo "$models" | grep "^$cur"))
```

### 6. No Filename Fallback
- Register with: `complete -F _function_name ollama` (no `-o default`)
- Clear `COMPREPLY=()` when not providing model completions

## Expected Behavior Examples
```bash
$ ollama run <TAB>
codellama:13b  codellama:34b  codegemma:7b  codestral:22b

$ ollama run code<TAB>
codellama:13b  codellama:34b  codegemma:7b  codestral:22b

$ ollama run codellama:<TAB>
codellama:13b  codellama:34b

$ ollama run xyz<TAB>
# (no output - no matching models)
```

## Output Requirements
- Provide ONLY the complete bash script
- Include clear comments explaining each section
- Ensure every non-code line starts with `#`
- Script must be ready to source immediately
