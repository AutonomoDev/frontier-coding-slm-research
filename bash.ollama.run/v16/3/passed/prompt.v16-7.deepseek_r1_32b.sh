# Thinking...
# Okay, I need to generate a Bash completion script for the command `ollama run`. The goal is to provide dynamic completions based on the models listed by `ollama list`, and handle cases where colons are involved correctly.
# 
# First, I remember that Bash completion scripts can be tricky because of how they handle word breaks and special characters like colons. From the context provided, I see that there are specific bugs to avoid, especially regarding array indexing and colon handling.
# 
# I start by outlining the structure of the function `_ollama_completions()`. The first step is to check if the command being completed is indeed `ollama run`. This is crucial because without this check, the completion might interfere with other commands or cause unintended behavior. So I include the condition:
# 
# ```bash
# [[ ${COMP_WORDS[0]} != "ollama" || ${COMP_WORDS[1]} != "run" ]] && { COMPREPLY=(); return 0; }
# ```
# 
# This ensures that the function only proceeds if the first word is `ollama` and the second is `run`.
# 
# Next, I need to handle the colon correctly. By default, Bash treats colons as word breaks, which can cause issues when completing model names that include colons. For example, typing `codellama:<tab>` should suggest `13b`, but without proper handling, `cur` might be an empty string after the colon.
# 
# To fix this, I temporarily remove the colon from `COMP_WORDBREAKS`. This allows the completion system to treat strings with colons as single words. I use `_get_comp_words_by_ref -n : cur prev` to reparse the command line with the updated word breaks. After reparsing, I restore the original `COMP_WORDBREAKS` to prevent side effects elsewhere.
# 
# Now, I check if the `ollama` command is available using `command -v ollama`. If it's not found, I set `COMPREPLY=()` and return early to avoid errors. 
# 
# Next, I extract the list of models from `ollama list`. The output includes a header line, so I use `awk 'NR>1 {print $1}'` to skip the first line and get only the model names. This is stored in the variable `models`.
# 
# If there are no models (i.e., `models` is empty), I again set `COMPREPLY=()` and return early.
# 
# For generating completions, I use `compgen -W "$models" -- "$cur"` to filter the list of models based on the current input (`$cur`). This populates `COMPREPLY` with possible matches. However, after handling colons, the completion might include the full model name (e.g., `codellama:13b`), but I want the display to show only the suffix after the colon for clarity. So, I call `__ltrim_colon_completions "$cur"` immediately after setting `COMPREPLY`.
# 
# Finally, I register the completion function with `complete -F _ollama_completions ollama` so that it's activated whenever `ollama` commands are used.
# 
# Throughout this process, I make sure to handle edge cases such as no models being available, missing `ollama`, and ensuring that the colon handling doesn't break other parts of the completion. By following these steps, the script should provide accurate completions for `ollama run <model>`, correctly handle colons, and avoid common pitfalls.
# ...done thinking.

_ollama_completions() {
    # CRITICAL: Check if completing after "ollama run"
    [[ ${COMP_WORDS[0]} != "ollama" || ${COMP_WORDS[1]} != "run" ]] && { COMPREPLY=(); return 0; }

    # Handle colons: Temporarily remove ':' from word breaks to reparse correctly
    local _old_wb=${COMP_WORDBREAKS}
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}
    _get_comp_words_by_ref -n : cur prev
    COMP_WORDBREAKS=${_old_wb}
    # Now cur/prev are correct (e.g., cur="codellama:13", prev="run")

    # Check if ollama available
    command -v ollama &>/dev/null || { COMPREPLY=(); return 0; }

    # Extract models robustly (skip header, get names only)
    local models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}')

    # If no models, empty reply
    [[ -z $models ]] && { COMPREPLY=(); return 0; }

    # Filter and set completions
    COMPREPLY=( $(compgen -W "$models" -- "$cur") )
    # MANDATORY: Fix display after colons
    __ltrim_colon_completions "$cur"
    return 0
}
complete -F _ollama_completions ollama
