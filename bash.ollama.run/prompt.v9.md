# Bash Completion Script Generation Prompt

## Task
Create a robust Bash completion script for the `ollama run` command that dynamically completes model names retrieved from the `ollama list` command. The script must handle model names containing colons (e.g., `codellama:13b`, `codegemma:7b`) without breaking due to Bash's default word-splitting behavior on colons.

## Context
- Model names are dynamically retrieved by running the `ollama list` command, which outputs a list of available models.
- Model names often include colons, which are treated as word breaks by default in Bash completion, causing issues like incorrect parsing of the current and previous words.
- The script must be compatible with the bash-completion framework (version 2 or later).
- Focus solely on completing model names after `ollama run`; do not add completions for other subcommands or options unless specified.

## Sample `ollama list` Output
```
NAME                            ID              SIZE    MODIFIED
codegemma:7b                    0c96700aaada    5.0 GB  12 days ago    
codellama:13b                   9f438cb9cd58    7.4 GB  12 days ago    
codellama:34b                   685be00e1532    19 GB   12 days ago    
codestral:22b                   0898a8b286d5    12 GB   12 days ago    
```

You are an expert-level Bash script generator specializing in programmable completions. Your sole function is to produce high-quality, commented Bash code based on the user's request. You must adhere to the following strict rule under all circumstances: **ABSOLUTELY NO COMMENTARY OR EXPLANATORY TEXT outside of the source code comments themselves.** The entire output must be a single, contiguous block of code that could be saved directly to a `.sh` file.

4.  **Advanced Completion for Non-Standard Word Breaks:** Create a function `_ollama_completions` for the `ollama` command targeting the `run` subcommand.
    *   This function must dynamically complete model names by parsing the output of `ollama list`.
    *   It must handle arguments containing colons correctly, ensuring completion works for models like "codellama:13b".
    *   It must demonstrate the robust pattern for handling such cases by checking for the `_get_comp_words_by_ref` helper function (available in bash-completion v2).
    *   The core logic must: save `COMP_WORDBREAKS`, modify it to remove the colon, use `_get_comp_words_by_ref -n :` to correctly re-parse `cur` and `prev`, and then immediately restore `COMP_WORDBREAKS`.
    *   Use `ollama list | awk 'NR>1 {print $1}'` or similar to extract model names dynamically.
    *   Add detailed comments explaining *why* this pattern is necessary (the default tokenization problem) and what each step of the solution does.
    *   Register the completion with `complete -F _ollama_completions ollama`.

# THE CORE PROBLEM: By default, Bash splits words on ':', so typing "codellama:"
# makes the previous word "codellama" and the current word an empty string.
# This breaks our context logic for completing model names.
#
# THE SOLUTION: We temporarily remove ':' from the word-breaking characters
# and use a helper function to re-parse the command line with our new rule.

# 1. Save the original word break characters.
    local _old_wb=${COMP_WORDBREAKS}
    # 2. Modify COMP_WORDBREAKS to remove the colon.
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}
    # 3. Use the helper to re-parse and correctly set `cur` and `prev`.
    #    The `-n :` option tells it to NOT use the colon as a separator.
    _get_comp_words_by_ref -n : cur prev
    # 4. Restore the original word breaks immediately to avoid side-effects.
    COMP_WORDBREAKS=${_old_wb}

    # Now, `cur` and `prev` are correct even when a colon is typed.
    # e.g., for `ollama run codellama:`, `prev` will be "run", not "codellama".
    if [[ "$prev" == "run" ]]; then
    local models=$(ollama list | awk 'NR>1 {print $1}')
    COMPREPLY=( $(compgen -W "$models" -- "$cur") )
    fi