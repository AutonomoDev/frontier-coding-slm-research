# OLLAMA Completion Script for 'ollama run' command

_ollama_completions() {
    local cur prev words cword
    local completions=()
    
    # Check if command is ollama and previous word is 'run'
    if [[ "$1" != "ollama" ]]; then
        COMPREPLY=()
        return 0
    fi
    
    # Handle colon in word breaks properly
    if ! _get_comp_words_by_ref -n : cur prev; then
        words=("${COMP_WORDS[@]}")
        cword=$COMP_CWORD
        prev="${words[cword-1]}"
        cur="${words[cword]}"
    fi
    
    # Only complete model names after 'run'
    if [[ "$prev" != "run" ]]; then
        COMPREPLY=()
        return 0
    fi
    
    # Retrieve available models from ollama list (skip first line, extract NAME column)
    if ! command -v ollama &> /dev/null; then
        COMPREPLY=()
        return 0
    fi
    
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Skip header line
        if [[ "$line" =~ ^NAME[[:space:]]ID.* ]]; then
            continue
        fi
        
        # Extract NAME from current line (assuming first column, space-separated)
        model=$(echo "$line" | awk '{print $1}')
        
        # Check for empty or invalid lines (unlikely but defensive coding is good)
        [[ -n "$model" ]] && completions+=("$model")
    done < <(ollama list 2>/dev/null)
    
    if (( ${#completions[@]} == 0 )); then
        COMPREPLY=()
        return 0
    fi
    
    # Filter matches based on current input (cur)
    local match_pattern="${cur}*"
    local matched_models=()
    for m in "${completions[@]}"; do
        if [[ "$m" == $match_pattern ]]; then
            matched_models+=("$m")
        fi
    done
    
    # Sort and generate completions
    IFS=$'\n' sorted_matches=($(sort <<<"${matched_models[*]}"))
    unset IFS
    
    COMPREPLY=( $(compgen -W "${sorted_matches[*]}" -- "$cur") )
    
    # Handle colon in completion display (critical)
    __ltrim_colon_completions "$cur"
}

# Register the completion function
complete -F _ollama_completions ollama

#**Explanation:**
#- The script starts by checking if the command is `ollama` and whether the previous word after parsing is `run`.
#- It uses `_get_comp_words_by_ref -n :` to properly parse colons in model names. If unavailable, it falls back to standard `COMP_WORDS` for compatibility.
#- Model names are retrieved via `ollama list`, skipping headers and extracting the first column (model name).
#- Matches against the current input (`$cur`) are filtered using wildcard matching (`"${cur}*"`) for dynamic completion.
#- Finally, `__ltrim_colon_completions "$cur"` ensures that colon-separated completions display correctly in Bash.
#
