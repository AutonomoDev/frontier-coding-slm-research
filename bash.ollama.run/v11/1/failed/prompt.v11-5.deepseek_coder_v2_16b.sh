if ! _get_comp_words_by_ref -n : cur prev; then
    COMPREPLY=()
    return 1
fi

if [[ "${prev}" != "run" ]]; then
    COMPREPLY=()
    return 0
fi

# Fetch model names using ollama list command
local models=$(ollama list | awk 'NR>1 {print $1}')

# Generate completion replies based on fetched models
COMPREPLY=($(compgen -W "${models}" -- ${cur}))

# Handle colon-separated completions properly
__ltrim_colon_completions "$cur"

