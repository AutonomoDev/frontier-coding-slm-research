# Declare completion function for "ollama run"
_ollama_completions() {
    # Check if the command is "ollama run"
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && return

    local cur prev
    _get_comp_words_by_ref -n : cur prev || {
        # Fallback for Bash versions without _get_comp_words_by_ref -n
        prev="${COMP_WORDS[COMP_CWORD-1]}"
        cur="${COMP_WORDS[COMP_CWORD]}"
    }

    local models=()

    # Check if "ollama" command exists
    command -v ollama >/dev/null 2>&1 && {
        # Get model names from "ollama list" output, skipping the header line
        readarray -t models < <(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
    }

    COMPREPLY=( $(compgen -W "${models[*]}" -- "$cur") )
    __ltrim_colon_completions "$cur"
}

# Register completion function for "ollama run"
complete -F _ollama_completions ollama
