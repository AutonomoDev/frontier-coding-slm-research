Thinking...
We need to output the bash code as described. The skeleton is provided with exact lines.

Make sure to wrap everything correctly. Provide function definition, inside it the checks, etc.

Also note that we need to call __ltrim_colon_completions which is part of bash completion library. We assume it's available.

We need to ensure that COMPREPLY is set in all branches. The skeleton includes that: early return sets COMPREPLY=() and return 0; also later we set COMPREPLY=( ... ) and then __ltrim and return 0. That covers all.

We must also add "local" variables to avoid issues.

Also we need to ensure that "models" variable is a string of names separated by spaces. In some cases, models might contain spaces? No, names have no spaces, but there might be newlines. Using `local models=$(...)` is fine.

Edge: When there are no models, the variable is empty string. We check `[[ -z $models ]]` and set COMPREPLY=().

We need to add a comment after colon handling maybe.

Make sure that we restore COMP_WORDBREAKS correctly.

Also note that the call to _get_comp_words_by_ref is a bash completion builtin. We need to supply correct args: -n : cur prev. That sets cur, prev.

We need to capture cur variable. In the skeleton, cur is used in the compgen.

Everything looks correct.

Let's produce final bash script:

```
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
```

Make sure to escape special characters? No, it's just bash code.

Double-check that all lines are correct. In the skeleton they had `[[ ${COMP_WORDS[0]} != "ollama" || ${COMP_WORDS[1]} != "run" ]] && { COMPREPLY=(); return 0; }` That is correct.

Check that we used local variables.

Ok. Output the script as a single block.

...done thinking.

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

