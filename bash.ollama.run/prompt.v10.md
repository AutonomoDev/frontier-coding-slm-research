# Bash Completion Script Generation Prompt
## Task
Create a robust Bash completion script for the `ollama run` command that dynamically completes model names retrieved from the `ollama list` command. The script must handle model names containing colons (e.g., `codellama:13b`, `codegemma:7b`) without breaking due to Bash's default word-splitting behavior on colons.

## Context
# THE CORE PROBLEM: By default, Bash splits words on ':', so typing "codellama:" makes the previous word "codellama" and the current word an empty string. This breaks context logic for completing model names.

# THE SOLUTION: Temporarily remove ':' from COMP_WORDBREAKS and re-parse the command line using _get_comp_words_by_ref with -n : to handle colons properly.
- Model names are dynamically retrieved by running the `ollama list` command, which outputs a list of available models.
- Model names often include colons, which are treated as word breaks by default in Bash completion, causing issues like incorrect parsing of the current and previous words.
- The script must be compatible with the bash-completion framework (version 2 or later).
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
2. **Subcommand Check:** Inside the function, check if the first argument (`COMP_WORDS[1]`) is "run". If not, return early.
3. **Handle Colon in Word Breaks:** To correctly parse model names with colons:
   - Save the original `COMP_WORDBREAKS` to a local variable.
   - Remove the colon from `COMP_WORDBREAKS` by using parameter expansion: `COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}`.
   - Use `_get_comp_words_by_ref -n : cur prev` to re-parse the current (`cur`) and previous (`prev`) words, ensuring colons are not treated as breaks.
   - Immediately restore the original `COMP_WORDBREAKS`.
4. **Completion Logic:** If `prev` is "run", generate completions:
   - Retrieve model names using `ollama list | awk 'NR>1 {print $1}'` or an equivalent command that extracts only the first column starting from the second line.
   - Use `compgen -W "$models" -- "$cur"` to generate the reply array `COMPREPLY`.
5. **Register Completion:** At the end of the script, use `complete -F _ollama_completions ollama` to register the function.
6. **Comments:** Include detailed inline comments explaining each step, especially the word break handling, why it's necessary, and what it does. Comments should be prefixed with `#` and placed appropriately within the code.
7. **Error Handling and Robustness:** Ensure the script does not produce syntax errors. Use local variables where appropriate. Assume `bash-completion` is loaded and `_get_comp_words_by_ref` is available.
8. **Common Pitfalls to Avoid:**
   - Do not modify `COMP_WORDBREAKS` globally; always restore it immediately after re-parsing.
   - Ensure `compgen` is used correctly with variables quoted to prevent word splitting.
   - Do not add extra echo statements, functions, or logic outside the specified completion.
   - The script must be pure Bash code; no shebang line unless necessary (omit it).
9. **Output Strictness:** Remember, your response must be ONLY the Bash code. Any deviation will cause failure.

