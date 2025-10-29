Thinking...
We need to produce a single Bash function as described. Just code, no markdown. Add inline comments. Let's produce it. Ensure function name _ollama_completions. Steps as listed. Also need to call complete -F _ollama_completions ollama. Ensure usage of _get_comp_words_by_ref -n : cur prev. All conditions. Provide code.
...done thinking.

#!/usr/bin/env bash
_ollama_completions() {
    # Only activate for "ollama run <model>"
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

    # Extract current and previous word
    local cur prev
    _get_comp_words_by_ref -n : cur prev

    # Ensure ollama binary exists
    if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi

    # Retrieve model list from ollama
    local models
    models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
    [[ -z "$models" ]] && { COMPREPLY=(); return; }

    # Generate completions for current word
    COMPREPLY=($(compgen -W "$models" -- "$cur"))

    # Sort completions and trim any trailing colon completions
    COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
    __ltrim_colon_completions "$cur"
}
complete -F _ollama_completions ollama

