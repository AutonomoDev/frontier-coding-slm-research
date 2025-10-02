# Bash Completion Script Generation Prompt
## Task
Create a robust Bash completion script for the `ollama run` command that dynamically completes model names retrieved from the `ollama list` command. The script must handle model names containing colons (e.g., `codellama:13b`, `codegemma:7b`) without breaking due to Bash's default word-splitting behavior on colons.

## Context
# THE CORE PROBLEM: By default, Bash splits words on ':', so typing "codellama:" makes the previous word "codellama" and the current word an empty string. This breaks context logic for completing model names.

# THE SOLUTION: Use _get_comp_words_by_ref with -n : flag to handle colons properly, with fallback for systems without bash-completion. CRITICALLY: Use __ltrim_colon_completions to handle the completion display after colons.
- Model names are dynamically retrieved by running the `ollama list` command, which outputs a list of available models.
- Model names often include colons, which are treated as word breaks by default in Bash completion, causing issues like incorrect parsing of the current and previous words.
- The script must be compatible with the bash-completion framework (version 2 or later) but provide fallback for systems without it.
- Focus solely on completing model names after `ollama run`; do not add completions for other subcommands or options unless specified.

## Sample `ollama list` Output
```
NAME ID SIZE MODIFIED
codegemma:7b 0c96700aaada 5.0 GB 12 days ago
codellama:13b 9f438cb9cd58 7.4 GB 12 days ago
codellama:34b 685be00e1532 19 GB 12 days ago
codestral:22b 0898a8b286d5 12 GB 12 days ago
```

You are an expert-level Bash script generator specializing in programmable completions. Your sole function is to produce high-quality, commented Bash code based on the user's request. You must adhere to the following strict rule under all circumstances: **ABSOLUTELY NO COMMENTARY OR EXPLANATORY TEXT outside of the source code comments themselves.** Do not include any markdown, headers, or additional prose. The entire output must be a single, contiguous block of valid Bash code that could be saved directly to a `.sh` file and sourced without errors.

## Requirements
1. **Function Structure:** Define a function named `_ollama_completions` that handles completions for the `ollama` command.
2. **Subcommand Check:** Inside the function, check if the command is "ollama" and previous word is "run". If not, return early with empty COMPREPLY.
3. **Handle Colon in Word Breaks:** To correctly parse model names with colons:
   - Use `if ! _get_comp_words_by_ref -n : cur prev; then` with fallback to standard COMP_WORDS parsing
   - The fallback should set `cur="${COMP_WORDS[COMP_CWORD]}"` and `prev="${COMP_WORDS[COMP_CWORD-1]}"`
   - This approach handles systems both with and without bash-completion loaded
4. **Completion Logic:** If `prev` is "run", generate completions:
   - Retrieve model names using `ollama list` and parse with awk/while loop to extract first column, skipping header
   - Filter matches using array iteration and pattern matching against `$cur`
   - Sort matches and use `compgen -W "$sorted_matches" -- "$cur"` to generate COMPREPLY
5. **CRITICAL COLON HANDLING:** After setting COMPREPLY, call `__ltrim_colon_completions "$cur"` to properly handle colon-separated completions display
6. **Register Completion:** At the end of the script, use `complete -F _ollama_completions ollama` to register the function.
7. **Comments:** Include detailed inline comments explaining each step, especially the colon handling with _get_comp_words_by_ref and why __ltrim_colon_completions is essential.
8. **Error Handling and Robustness:** 
   - Check if ollama command exists before calling it
   - Handle empty or failed ollama list output gracefully
   - Use local variables appropriately
   - Set COMPREPLY=() for no-match cases
9. **Common Pitfalls to Avoid:**
   - Do not forget the __ltrim_colon_completions call - this is what makes colon completions work
   - Ensure proper fallback when _get_comp_words_by_ref is unavailable
   - Use correct condition checking with "${prev}" != "run" pattern
   - Parse ollama list output correctly, skipping header row
10. **Output Strictness:** Remember, your response must be ONLY the Bash code. Any deviation will cause failure.
