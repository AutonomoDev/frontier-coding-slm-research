# Check if bash-completion is installed and can handle colons in word breaks.
if declare -F _get_comp_words_by_ref >/dev/null; then
    # If it exists, use the function to correctly parse current and previous words including those containing colon.
    _get_comp_words_by_ref() {
        local exclude i j line
        if [[ "$1" = "-n" ]]; then
            exclude=$2
            shift 2
        fi
        COMPREPLY=()
        if [[ $COMP_CWORD -gt 0 ]]; then
            for ((i=0; i < ${#COMP_WORDS[@]}-1; i++)); do
                # Skip words to the left of the current word.
                if [[ ${COMP_WORDS[i]} = "$exclude" ]]; then
                    break
                fi
            done
            (( j=i+1 ))
        else
            j=0
        fi
        while [[ $j -lt ${#COMP_WORDS[@]} ]]; do
            # Skip options.
            if [[ "${COMP_WORDS[$j]}" != -* ]]; then
                COMPREPLY+=("${COMP_WORDS[$j]}")
            fi
            (( j++ ))
        done
    }
else
    # If bash-completion isn't available, fallback to parsing current and previous words without considering colon.
    _get_comp_words_by_ref() {
      cur="${COMP_WORDS[COMP_CWORD]}"
      prev="${COMP_WORDS[COMP_CWORD-1]}"
    }
fi

# Function to handle completions for 'ollama run' command.
_ollama_completions() {
  local cur prev models sorted_matches
  
  # Check if the current command is "ollama" and previous word is "run".
  if [[ ${COMP_WORDS[0]} = "ollama" && $prev = "run" ]]; then
    # Retrieve model names using 'ollama list' command.
    models=($(ollama list | awk -F'\t' 'NR>1 {print $1}'))
    
    sorted_matches=$(printf "%s\n" "${models[@]}" | grep "^$cur.*" | sort)
    COMPREPLY=( $(compgen -W "$sorted_matches" -- "$cur") )
  else
    # If not, return empty completion.
    COMPREPLY=()
  fi
  
  # Handle colon in word breaks for correct display of completions after colons.
  __ltrim_colon_completions "$cur"
}

# Register the function to provide completions.
complete -F _ollama_completions ollama
