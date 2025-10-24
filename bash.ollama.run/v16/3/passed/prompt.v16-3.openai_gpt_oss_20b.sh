#Thinking...
#We need to output the bash code only. Ensure skeleton exactly as given with minor modifications? The skeleton already has the correct index check and colon handling. But we must ensure COMPREPLY is set even in failure branches. They already set COMPREPLY=() in early returns. We need to handle command -v ollama. They already set COMPREPLY=(); return 0. Good.
#
#Also we must ensure that after parsing models, we set COMPREPLY and call ltrim. Must import __ltrim_colon_completions? That function is part of bash completion library. It's available in /usr/share/bash-completion/dir? But assume it's available.
#
#We must be careful about local variable models variable: Should be an array? compgen -W expects string with spaces. If models contains newline, that's okay. Should use $(...) but word splitting may treat newline as spaces. That's fine.
#
#We should also sort maybe, but optional.
#
#We need to preserve that local _old_wb assignment: local _old_wb=${COMP_WORDBREAKS} is okay. Use local _old_wb=${COMP_WORDBREAKS} but variable name with underscore maybe fine.
#
#We need to ensure COMP_WORDBREAKS modification: ${COMP_WORDBREAKS//:/} removes colon.
#
#Then _get_comp_words_by_ref -n : cur prev.
#
#Then restore COMP_WORDBREAKS.
#
#Then extract models: local models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}')
#
#If no models: [[ -z $models ]] -> COMPREPLY=(); return 0.
#
#Then COMPREPLY=( $(compgen -W "$models" -- "$cur") )
#
#Then __ltrim_colon_completions "$cur"
#
#return 0.
#
#Finally complete -F _ollama_completions ollama
#
#Let's double-check that the function is named _ollama_completions() as required. And the skeleton includes all required lines. Add comment lines maybe minimal.
#
#The skeleton's index check comment: "# CRITICAL: Check if completing after "ollama run"". We need to keep that. The rest comment lines are minimal.
#
#We must ensure not to add any extra code outside skeleton.
#
#Let's produce final code block.
#...done thinking.

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
    [[ -z $models ]] && { COMPREPLY=(); return 0; }

    # Filter and set completions
    COMPREPLY=( $(compgen -W "$models" -- "$cur") )
    __ltrim_colon_completions "$cur"
    return 0
}
complete -F _ollama_completions ollama
