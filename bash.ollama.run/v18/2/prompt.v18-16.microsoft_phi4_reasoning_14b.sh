<think>We need to produce a script for bash completion of `ollama run` command. The provided instructions are as follows:

Task: "Make script for ollama run <model>:
- Activates only for ollama run.
- Handles colons (e.g., codellama:13b).
- Parses ollama list correctly.
- Completes only model arg"

The steps given in the specification:

1. Define function `_ollama_completions()`
2. Check if COMP_WORDS[0] != "ollama" or COMP_WORDS[1]!= "run", if so, set COMPREPLY=() and return 0.
3. Also check that `COMP_CWORD` is equal to 2, i.e., argument number is exactly after the command name (i.e. only one parameter is provided).
4. Handle colons by setting local variables: cur and prev
   If _get_comp_words_by_ref is available then do `_get_comp_words_by_ref -n : cur prev`, else fallback to using COMP_WORDS[COMP_CWORD] for cur, and previous word for prev.
5. Parse: get list of models from the output of `ollama list` command by piping tail -n +2 | awk '{print $1}'.
   But if command "ollama" is not available then handle empty array.
6. Completions:
   Sort models before compgen (with sort). Then use `compgen -W "${models[*]}" -- "$cur"` to generate completions and assign them to COMPREPLY.
7. Fix colons using __ltrim_colon_completions if available, passing the $cur parameter.
8. Register: call complete with `-F _ollama_completions ollama` command.

Now check checklist:
- Must include inline comments for key parts.
- Code should be only bash code (without extra text).
- Handle edges: if no "ollama" or models then nothing returns.

We need to produce script accordingly. We'll output a complete bash file with the _ollama_completions function and a call to complete command.

I must generate bash code that meets these requirements, including inline comments lines.

Now I'll produce the following code:

```
_ollama_completions() {
    # Only activate for "ollama run"
    if [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]; then
        COMPREPLY=()
        return 0
    fi

    # Ensure exactly one argument after the command (i.e., COMP_CWORD equals 2)
    if [[ $COMP_CWORD -ne 2 ]]; then
        return 0
    fi

    # Setup variables for colon completion
    local cur prev
    if type _get_comp_words_by_ref &>/dev/null; then
        _get_comp_words_by_ref -n : cur prev
    else
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # Get list of models from "ollama list"
    local models=()
    if command -v ollama &>/dev/null; then
        # Exclude header line and get first column (model names)
        models=( $(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}') )
    fi

    # Sort models to ensure consistent order
    IFS=$'\n'
    models=($(sort <<<"${models[*]}"))
    unset IFS

    # Generate completions using compgen with the sorted model names.
    COMPREPLY=( $(compgen -W "${models[*]}" -- "$cur") )

    # If available, adjust colon completions so only after ":" are returned
    if type __ltrim_colon_completions &>/dev/null; then
        __ltrim_colon_completions "$cur"
    fi
}
complete -F _ollama_completions ollama
```

I need to produce code with inline comments. I'll produce the final answer as above.

I'll produce script output accordingly. The answer is expected to be only bash code, so no markdown formatting instructions by default: "ONLY BASH CODE – no extras" means I must not include any extra text explanation? But in our instructions we can provide some text that is code block containing script code.

But the instruction said: Output rules: ONLY BASH CODE – no extras. So I'll produce plain bash code with inline comments, no further text.

I'll then output answer accordingly.</think>#!/bin/bash
# Bash completion for "ollama run <model>"

_ollama_completions() {
    # Only activate if the command is "ollama run"
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return 0; }
    
    # Ensure we are completing only the model argument (only one extra word)
    [[ $COMP_CWORD -ne 2 ]] && return 0

    # Handle colon completion if _get_comp_words_by_ref is available
    local cur prev
    if type _get_comp_words_by_ref &>/dev/null; then
        _get_comp_words_by_ref -n : cur prev
    else
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # Get list of models from "ollama list", skipping header and extracting first column.
    local models=()
    if command -v ollama &>/dev/null; then
        models=( $(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}') )
    fi

    # Sort the models for consistent order (compgen does not sort)
    IFS=$'\n'
    models=($(sort <<<"${models[*]}"))
    unset IFS

    # Generate completions using compgen with the sorted list of models
    COMPREPLY=( $(compgen -W "${models[*]}" -- "$cur") )

    # Adjust colon completions if __ltrim_colon_completions is available
    if type __ltrim_colon_completions &>/dev/null; then
        __ltrim_colon_completions "$cur"
    fi
}

complete -F _ollama_completions ollama

