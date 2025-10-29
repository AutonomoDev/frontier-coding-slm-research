#!/usr/bin/env bash
# Copyright (c) <year> <Your Name>. All rights reserved.
# Licensed under the MIT License. See LICENSE.txt in the project root for license information.

_ollama_completions() {
    # Check if command is "ollama run"
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && return
    
    # Load models
    local cur prev
    _get_comp_words_by_ref -n : cur prev

    if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
    local models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
    if [ -z "$models" ]; then COMPREPLY=(); return; fi
    
    # Generate completions
    COMPREPLY=($(compgen -W "$models" -- "$cur"))
    
    # Sort and trim colons
    COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
    __ltrim_colon_completions "$cur"
}

complete -F _ollama_completions ollama

# [[HUMAN COMMENTED-OUT]]
# Please replace <year> and <Your Name> with the appropriate values. The script should be tested thoroughly before being used in production.
