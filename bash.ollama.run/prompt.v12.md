==== PROMPT v12 ====

# Bash Completion Script Generation Prompt
## Common Pitfalls to Avoid (READ THIS FIRST!):
- **CRITICAL: Do not forget to call __ltrim_colon_completions "$cur" after setting COMPREPLY!** This is ABSOLUTELY ESSENTIAL for handling colons in model names. Without this call, suggestions will NOT appear after typing a colon, like in "codellama:", and the completion will fail completely, showing no suggestions. This is the main reason many scripts fail.
- Do not output the full `ollama list` without parsing it first; always extract ONLY the model names from the first column. If you don't parse it, the suggestions might show the entire line or wrong things, like the header or IDs.
- Do not use compgen directly on the unparsed output of `ollama list`, as this will cause entire lines (including ID, SIZE, etc.) to be suggested instead of just model names.
- Ensure the fallback for _get_comp_words_by_ref works correctly: set cur and prev using COMP_WORDS if the function is not available.
- Use the exact condition: if the first word is not "ollama" or prev is not "run", set COMPREPLY=() and return early.
- Parse `ollama list` output carefully: skip the header row "NAME ID SIZE MODIFIED" and any empty lines, and extract only the first column using awk or cut.
- Do not add extra completions for other ollama subcommands; only complete after "ollama run".
- Always check if ollama command exists before running it, to avoid errors.
- Handle cases where there are no models: set COMPREPLY=() if models array is empty.
- Sort the matches before using compgen, to make suggestions orderly.

**Important:** Check COMP_WORDS[0] == 'ollama' and COMP_WORDS[1] == 'run', not indices 1/2. Never reference [1] as command or [2] as subcommand. This ensures model listing only triggers for ollama run.

## Task
Create a simple and robust Bash completion script for the `ollama run` command. It should complete model names from `ollama list`. Model names often have colons, like `codellama:13b`, so the script MUST handle colons correctly without breaking.

## Context
# THE CORE PROBLEM (VERY IMPORTANT): Bash splits words on ':' by default. So if you type "codellama:", Bash sees "codellama" as the previous word and "" (empty) as the current word. This breaks normal completion logic.
# THE SOLUTION (MUST FOLLOW): Use `_get_comp_words_by_ref -n : cur prev` to tell Bash NOT to split on colons. If that function is not available, fall back to basic COMP_WORDS. AND ALWAYS call `__ltrim_colon_completions "$cur"` at the end to fix how suggestions display after colons. Without this, NO SUGGESTIONS WILL SHOW after a colon!
- Get model names by running `ollama list`.
- Model names have colons, which cause problems in Bash completion.
- Make the script work with bash-completion (version 2+) if available, but have a simple fallback if not.
- ONLY complete model names after `ollama run`. Nothing else.

## Sample `ollama list` Output
```
NAME ID SIZE MODIFIED
codegemma:7b 0c96700aaada 5.0 GB 12 days ago
codellama:13b 9f438cb9cd58 7.4 GB 12 days ago
codellama:34b 685be00e1532 19 GB 12 days ago
codestral:22b 0898a8b286d5 12 GB 12 days ago
```

You are a Bash script generator. Your only job is to output the Bash code. **DO NOT ADD ANY TEXT OUTSIDE THE CODE! NO MARKDOWN, NO HEADERS, NO EXPLANATIONS.** The output must be pure Bash code that can be saved as .sh and sourced.

## Requirements (Follow Step by Step):
1. **Function Structure:** Make a function called `_ollama_completions`.
2. **Subcommand Check:** In the function, check if the first word is "ollama" and the previous word is "run". If not, set COMPREPLY=() and return.
3. **Handle Colons (IMPORTANT):**
    - Try `if ! _get_comp_words_by_ref -n : cur prev; then`
    - Fallback: `cur="${COMP_WORDS[COMP_CWORD]}"` and `prev="${COMP_WORDS[COMP_CWORD-1]}"`
    - This fixes colon splitting.
4. **Completion Logic:** If prev is "run":
    - Check if `ollama` command exists with `command -v ollama &> /dev/null`. If not, set COMPREPLY=() and return.
    - Run `ollama list 2>/dev/null` and read it line by line in a while loop.
    - Skip header "NAME ID SIZE MODIFIED" and empty lines.
    - Use `awk '{print $1}'` or similar to get only the model name (first column).
    - Add to a local array called models if not empty.
    - If models array is empty, set COMPREPLY=() and return.
    - Make another array for matches: loop through models, add if it starts with "$cur".
    - Sort the matches: `sorted_matches=$(printf '%s\n' "${matches[@]}" | sort)`
    - Set COMPREPLY with `compgen -W "$sorted_matches" -- "$cur"`
5. **CRITICAL COLON FIX (DO NOT SKIP):** After COMPREPLY, ALWAYS call `__ltrim_colon_completions "$cur"`. This makes suggestions show correctly after colons.
6. **Register:** At the end, `complete -F _ollama_completions ollama`
7. **Comments:** Add comments in the code explaining each part, especially colons, parsing, and why __ltrim_colon_completions is needed.
8. **Make it Robust:**
    - Use local variables.
    - Set COMPREPLY=() when no matches.
    - Redirect errors to /dev/null.
9. **Output Rule:** ONLY OUTPUT THE BASH CODE. Nothing else!