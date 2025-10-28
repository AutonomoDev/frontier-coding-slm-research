_ollama_completions() {
    # Check if first and second words are "ollama" and "run". If not, return without any completions.
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return 0; }
    
    # If the word count is not 2 (first and second words are "ollama" and "run"), return without any completions.
    [[ $COMP_CWORD -ne 2 ]] && return 0;
    
    # Get current and previous word using _get_comp_words_by_ref if available, otherwise set them manually.
    local cur prev
    if type  _get_comp_words_by_ref &>/dev/null; then _get_comp_words_by_ref -n : cur prev; else cur="${COMP_WORDS[COMP_CWORD]}"; prev="${COMP_WORDS[COMP_CWORD-1]}"; fi
    
    # Get all models by calling `ollama list` and filtering for the first column. 
    local models=()
    if command -v ollama &>/dev/null; then models=($(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')); fi
    
    # Sort the array of models.
    IFS=$'\n' models=($(sort <<<"${models[*]}")); unset IFS
    
    # Generate completions using compgen and assign them to COMPREPLY.
    COMPREPLY=( $(compgen -W "${models[*]}" -- "$cur") )
    
    # Trim colons if possible.
    if type __ltrim_colon_completions &>/dev/null; then __ltrim_colon_completions "$cur"; fi
}

# Register the function _ollama_completions to be called when completing words for ollama. 
complete -F _ollama_completions ollama
# [[HUMAN COMMENTED-OUT]]
# This script assumes that `sort`, `awk`, `tail` and `compgen` are available in your system's PATH, which should be the case for most modern Unix-based systems. If not, you may need to adjust the command within $(...) accordingly.
