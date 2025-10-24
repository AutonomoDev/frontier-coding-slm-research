<think>We are asked by user to produce a complete, self-contained Bash completion script. The specification is given in detail: It must generate a Bash completion script for only "ollama run <model>" command. We must follow exactly the skeleton instructions, with inline comments on critical lines (only when needed). There is the specification of checking if [COMP_WORDS[0]] equals "ollama" and [COMP_WORDS[1]] equals "run". Then reparse colon handling by temporarily modifying COMP_WORDBREAKS to remove colon and then calling _get_comp_words_by_ref -n : cur prev, restore old value. Then check command availability for ollama. Then get model names from "ollama list", skipping header using awk (NR>1 {print $1}). Also if no models found, then set COMPREPLY=(). Then filter completions via compgen and assign result to COMPREPLY, then call __ltrim_colon_completions "$cur" to adjust completion. And then return 0.

And final line: complete -F _ollama_completions ollama.

We must output only the bash code block (i.e., no markdown formatting instructions) i.e., a single contiguous block with inline comments on critical lines. We must not add extra text except the Bash code. And we must not produce any fallback completions if none are provided. Must be production-ready, handle errors gracefully.

I need to produce script that exactly matches skeleton and requirements:

Let me produce:

```
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

I must produce that as one contiguous block. Possibly adding a shebang line? But instructions "Output only the BASH CODE" so no markdown formatting etc.

The user said: "Include brief inline comments only on critical lines (e.g., why reparse)" and then "production-ready", "no fallbacks needed", etc.

I must produce a single block that exactly follows requirements. Possibly also include "sort" if possible? But instructions said "but prioritize reliability over extras" so maybe not necessary. But it's safe to add sorting but not mandatory. The skeleton instructs: "Generate completions: COMPREPLY=( $(compgen -W "$models" -- "$cur") )" and then call __ltrim_colon_completions "$cur".

I must produce a script that is self-contained. That means the function is declared and complete command registration.

So I'll simply output exactly the code as requested, with inline comments on critical lines only.

Let's double-check each step:
- Step 1: Check if completing after "ollama run". This check uses COMP_WORDS[0] for "ollama" and COMP_WORDS[1] for "run". Good.
- Step 2: Handle colons. Modify COMP_WORDBREAKS to remove colon, then call _get_comp_words_by_ref with -n : cur prev, restore the old value.
- Check if ollama available: command -v ollama &>/dev/null. If not, empty reply.
- Extract models using ollama list 2>/dev/null | awk 'NR>1 {print $1}'. That produces a space-separated string of model names.
- Then if no models found, set COMPREPLY=() and return 0.
- Generate completions: Use compgen to generate completions from the words in the variable "$models" with argument "$cur".
- Then call __ltrim_colon_completions "$cur"
- End with complete -F _ollama_completions ollama.

Yes that's it. Also inline comments on critical lines:
- For colon handling, we add comment "Handle colons: Temporarily remove ':' from word breaks to reparse correctly".
- We can also comment check for available command.
- And note that if no models found, then empty reply.

I must produce exactly the code block as described. Also instructions say "production ready", so I'll not add any extra code lines or fallback completions. I can include sorting if needed, but instructions said to "sort if easy", but then says "but prioritize reliability over extras" so maybe it's optional? But no need.

I must check that the function returns 0 always, and COMPREPLY is always set in all branches. Yes.
- In case of error (missing command or missing models), we do { COMPREPLY=(); return 0; }.

Double-check: The check "if COMP_WORDS[0] != 'ollama' OR COMP_WORDS[1] != 'run'" then do nothing and return, which means completion will not be provided. That is correct.

Yes.

I must produce the code as a contiguous block with no markdown formatting (so plain text) maybe as single script snippet.

I'll produce the script accordingly:

```
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

I'll produce exactly that. We must output only the code.

I'll now produce final answer accordingly in plain text, ensuring it's a single contiguous block of code as per instructions with no extra text. So I'll produce answer accordingly.</think>_ollama_completions() {
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

