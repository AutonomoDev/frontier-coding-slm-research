**Proposed v17 Prompt**

```markdown
### ==== bash.ollama.run/prompt.v17.md ====
# AI Bash Completion Expert: `ollama run` Script

## Primary Objective
Your sole task is to generate a single, production-quality Bash completion script for the `ollama run` command. The script must be robust, efficient, and correctly handle model names containing colons.

## Core Challenge: The Colon Problem
Bash completions fail with model names like `codellama:13b` because the colon (`:`) is a default word separator. This breaks the logic for identifying the current word to complete. Your script **must** implement the complete, two-part solution for this.

### MANDATORY Two-Part Colon Fix
1. **Correctly Parse Input:** Temporarily remove `:` from `COMP_WORDBREAKS` and use `_get_comp_words_by_ref -n :` to re-parse command-line words.
   - Example: `codellama:` → `prev = "run"`, not `codellama`.
2. **Correctly Display Suggestions:** Call `__ltrim_colon_completions "$cur"` after generating completions.

## Implementation Requirements (Follow Precisely)

### 1. Script Structure & Entry Point
- Define a function `_ollama_completions`.
- **First Action:**
   - Check if `COMP_WORDS[1]` is exactly `"run"`. If not, return immediately to prevent interference with other commands and avoid filename completions.

### 2. Colon Fix Implementation (Comments Required)
Inside the `run` logic:
1. Save original `COMP_WORDBREAKS`.
2. Remove `:` from it.
3. Use `_get_comp_words_by_ref -n : cur prev`.
4. Restore original `COMP_WORDBREAKS`.

### 3. Dynamic Model List Generation
- Check if `ollama` exists (`command -v ollama &>/dev/null`).
- Fetch models via `ollama list | awk 'NR>1 {print $1}'`.

### 4. Generate Completions
- Use `compgen -W "<list_of_models>" -- "$cur"` → store in `COMPREPLY`.
- Call `__ltrim_colon_completions "$cur"` as the final step.

### 5. Registration
- Register completion: `complete -F _ollama_completions ollama`.

## Output Format (Strictly Enforced)
- **CODE ONLY** → no markdown, explanations, or preambles.
- Include inline comments for complex parts.

## Final Verification Checklist
Your script must:
- Check `COMP_WORDS[1]` and exit if not `run`.
- Modify/restore `COMP_WORDBREAKS`.
- Use `_get_comp_words_by_ref -n :`.
- Parse `ollama list` correctly.
- Call `__ltrim_colon_completions "$cur"` after setting `COMPREPLY`.

### Example Code Structure
```bash
_ollama_completions() {
    # Exit early if not 'ollama run'
    [[ ${COMP_WORDS[1]} != "run" ]] && return

    local cur="${COMP_WORDS[COMP_CWORD]}"
    local prev=""

    # Save and modify COMP_WORDBREAKS
    local orig_COMP_WORDBREAKS="$COMP_WORDBREAKS"
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}
    
    _get_comp_words_by_ref -n : cur prev

    # Restore original COMP_WORDBREAKS
    COMP_WORDBREAKS="$orig_COMP_WORDBREAKS"

    if command -v ollama > /dev/null 2>&1; then
        local models=$(ollama list | awk 'NR>1 {print $1}')
        COMPREPLY=( $(compgen -W "$models" -- "$cur") )
        __ltrim_colon_completions "$cur"
    fi
}
complete -F _ollama_completions ollama
```

**Note:** Ensure the code includes all checks and is production-ready.
```

