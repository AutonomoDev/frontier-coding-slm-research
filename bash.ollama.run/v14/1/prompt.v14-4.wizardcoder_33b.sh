# [[HUMAN COMMENTED-OUT]]
# Here's a simple Bash completion script that meets your requirements. Remember to source the file after defining it in your .bashrc or similar:

_ollama_completions() {
    local cur prev words cword split
    
    # Check if command is "ollama run" 
    [[ ${COMP_WORDS[0]} != "ollama" || ${COMP_WORDS[1]} != "run" ]] && return
    
    _get_comp_words_by_ref -n : cur prev words cword split
    
    # Try to list models from ollama and generate completions
    if command -v ollama &>/dev/null; then
        local models=$(ollama list 2>/dev/null | awk 'NR > 1 {print $1}')  # Skip header, extract first column
        COMPREPLY=($(compgen -W "$models" -- "$cur"))  
    else
        echo "Error: ollama command not found. Make sure it's installed and in your PATH." >&2
        return 1
    fi
    
    __ltrim_colon_completions "$cur" # Fix colon display issue
}
complete -F _ollama_completions ollama

# [[HUMAN COMMENTED-OUT]]
# This script checks if the first and second words in COMP_WORDS are "ollama" and "run" respectively. If they aren't, it returns without doing anything (avoiding unnecessary processing). It uses `_get_comp_words_by_ref -n :` to handle colons properly, then extracts model names from ollama list. Finally, it generates completions based on the current word and sets them using compgen. After generating completions, it calls `__ltrim_colon_completions "$cur"` to fix the colon display issue. If ollama is not installed or can't be found in PATH, it prints an error message to stderr.
