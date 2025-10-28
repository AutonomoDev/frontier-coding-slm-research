 ```bash
# Check if command is "ollama run"
[[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

# Extract current and previous words with colons handled
local cur prev
_get_comp_words_by_ref -n : cur prev

# Check if ollama command is available
if ! command -v ollama &>/dev/null; then
    COMPREPLY=(); return;
fi

# Get the list of models
local models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
if [ -z "$models" ]; then
    COMPREPLY=(); return;
fi

# Generate completions based on models
COMPREPLY=($(compgen -W "$models" -- "$cur"))

# Sort the completions
COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))

# Handle colons by trimming them from suggestions
__ltrim_colon_completions "$cur"
```

