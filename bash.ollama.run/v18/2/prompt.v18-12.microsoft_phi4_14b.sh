# [[HUMAN COMMENTED-OUT]]
# Here's a Bash completion script for the `ollama run` command, implementing all necessary steps to ensure it handles colons, parses outputs correctly, and manages edge cases:

_ollama_completions() {
    # Check if we're completing 'ollama run' with exactly 2 words
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return 0; }
    [[ $COMP_CWORD -ne 2 ]] && return 0

    # Use _get_comp_words_by_ref if available to handle colons properly
    local cur prev words cword
    if type _get_comp_words_by_ref &>/dev/null; then
        _get_comp_words_by_ref -n : cur prev words cword
    else
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # Fetch and parse models from 'ollama list'
    local models=()
    if command -v ollama &>/dev/null; then
        models=( $(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}') )
    fi

    # Sort the model names for better completion experience
    IFS=$'\n' models=($(sort <<<"${models[*]}")); unset IFS

    # Generate completions based on current input
    COMPREPLY=( $(compgen -W "${models[*]}" -- "$cur") )

    # Trim the leading colon if necessary, allowing insertion after colons
    if type __ltrim_colon_completions &>/dev/null; then
        __ltrim_colon_completions "$cur"
    fi
}

# Register the completion function for 'ollama'
complete -F _ollama_completions ollama

# [[HUMAN COMMENTED-OUT]]
# ### Key Features:
# 
# - **Index and Word Check**: Ensures the script only activates when completing `ollama run`.
# - **Colon Handling**: Utilizes `_get_comp_words_by_ref` to manage colons correctly, allowing for insertion after them.
# - **Model Parsing**: Extracts model names from the output of `ollama list`, skipping headers with `tail -n +2 | awk '{print $1}'`.
# - **Sorting Models**: Ensures that model suggestions are presented in sorted order for a more intuitive user experience.
# - **Completion Generation**: Uses `compgen` to create completion options based on current input, avoiding manual loops or filters.
# - **Colon Trimming**: Employs `__ltrim_colon_completions` to handle scenarios where the user is completing after a colon.
# 
# This script ensures robust and efficient Bash completions for `ollama run`, addressing potential pitfalls related to indexing, colons, parsing, sorting, and more.
