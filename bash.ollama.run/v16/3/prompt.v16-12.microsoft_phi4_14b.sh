```bash
_ollama_completions() {
    # CRITICAL: Check if completing after "ollama run"
    [[ ${COMP_WORDS[0]} != "ollama" || ${COMP_WORDS[1]} != "run" ]] && { COMPREPLY=(); return 0; }

    # Handle colons: Temporarily remove ':' from word breaks to reparse correctly
    local _old_wb=${COMP_WORDBREAKS}
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}
    _get_comp_words_by_ref -n : cur prev
    COMP_WORDBREAKS=${_old_wb}

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
```

This script is designed to provide dynamic Bash completions for the `ollama run <model>` command. It ensures that suggestions are offered exclusively after typing "ollama run" and correctly handles colons in model names, preventing common pitfalls like file fallbacks or incorrect handling of input prefixed with a colon. The code makes use of temporary changes to word break settings to accurately parse user input when colons are involved, then resets these settings before proceeding with the completion logic.

The script first checks if it is being invoked in the correct context (i.e., after "ollama run"). If not, it exits early without offering any completions. It then adjusts `COMP_WORDBREAKS` to prevent Bash from splitting input on colons and uses `_get_comp_words_by_ref` to correctly parse command-line arguments. This ensures that inputs like "codellama:13b" are handled as a single word, allowing for accurate completion suggestions.

Next, the script checks for the availability of the `ollama` command. If it's not found, completions are disabled. It then retrieves available model names using `ollama list`, ensuring that only valid entries (excluding headers) are considered. If no models are listed or an error occurs while retrieving them, it sets `COMPREPLY` to empty, avoiding incomplete suggestions.

Finally, the script generates completion options based on the parsed input (`cur`) and stored model names. It uses `compgen -W` for filtering relevant completions. To properly handle cases where users have typed a prefix like "codellama:", it calls `__ltrim_colon_completions` to adjust suggestions accordingly, ensuring that only the suffixes (like "13b" in "codellama:13b") are presented.

The script concludes by registering itself with Bash using `complete -F`, linking its functionality specifically to the `ollama` command. This ensures it is activated precisely when needed and maintains a clean separation from other completions. The result is a robust, reliable completion system that adheres closely to expected behavior for users of the `ollama run` command.

