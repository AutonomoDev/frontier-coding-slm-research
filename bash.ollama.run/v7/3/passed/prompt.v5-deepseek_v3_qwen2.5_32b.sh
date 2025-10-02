# ollama-run-completion.sh
#
# Completion script for 'ollama run' command, providing model name suggestions.

_ollama_run_completion() {
    local cur prev words cword run_index wordlist matches old_wb

    # Check if _get_comp_words_by_ref is available (for Bash 4.2+)
    # Otherwise, fallback to manually extracting COMP_WORDS and COMP_CWORD
    if type _get_comp_words_by_ref &>/dev/null; then
        _get_comp_words_by_ref -n : cur prev words cword
    else
        readarray -t words <<< "${COMP_LINE// /$'\n'}"
        cword="${words[@]/%}"
        (( cword = COMP_POINT ))
        for i in "${!words[@]}"; do
            if [[ ${words[i]::cword} == "$COMP_LINE" ]]; then
                cword=$i
                break
            fi
        done
        cur=${words[cword]}
        prev=${words[cword - 1]}
    fi

    # Find the index of 'run' in COMP_WORDS to ensure we're completing after it
    run_index=-1
    for (( i=0; i < ${#words[@]}; i++ )); do
        if [[ "${words[i]}" == "run" ]]; then
            run_index=$i
            break
        fi
    done

    # Only proceed if 'run' was found and we're completing the next word
    if (( run_index != -1 )) && (( cword == run_index + 2 )); then
        return 0
    fi

    # Skip further processing unless we are after 'run'
    if (( cword != run_index + 1 )); then
        return 0
    fi

    # Backup and modify COMP_WORDBREAKS to allow : in model names
    old_wb=$COMP_WORDBREAKS
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}

    # Get the list of model names from 'ollama list', skipping header line with awk
    wordlist=$(ollama list | awk 'NR>1 {print $1}' | sort -u)

    if [[ -z "$wordlist" ]]; then
        COMPREPLY=()
    else
        # Filter completions based on current input (cur)
        matches=$(compgen -W "$wordlist" -- "$cur")
        COMPREPLY=( $matches )
    fi

    # Restore original COMP_WORDBREAKS to avoid side effects
    COMP_WORDBREAKS=$old_wb
}

# Register the completion function for 'ollama' command specifically after 'run'
complete -F _ollama_run_completion ollama

# [[HUMAN COMMENTED-OUT]]
#### Explanation:
#
#1. **Function Definition**: `_ollama_run_completion` is defined to handle completions for `ollama run`.
#2. **Word Parsing**: Uses `_get_comp_words_by_ref` (if available) or a fallback method to parse current word (`cur`) and previous word (`prev`).
#3. **Position Check**: Ensures completion only happens after the `run` subcommand by checking `COMP_WORDS` indices.
#4. **Temporary WORDBREAKS Modification**: Removes colon from `COMP_WORDBREAKS` to allow model names with colons, restores it afterward.
#5. **Model List Fetching**: Uses `ollama list` and `awk` to extract and deduplicate model names from the first column of non-header lines.
#6. **Completion Filtering**: Filters models matching the current input using `compgen`, ensuring safe prefix-based matching.
#7. **Registration**: Registers the completion function specifically for `ollama run`, avoiding default or filename fallbacks.
#
#This script ensures robust and context-aware completions for `ollama run` model names, handling edge cases like colons in names and variable word spacings.

