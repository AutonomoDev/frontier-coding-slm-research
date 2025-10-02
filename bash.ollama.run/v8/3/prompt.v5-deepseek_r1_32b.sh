#Thinking...
#Alright, I need to create a Bash completion script for the `ollama run` command. The main issue is that model names contain colons, which can break standard bash completion because colons are considered word breaks by default.
#
#First, I remember that in Bash, word breaks affect how completions work. So when a colon is present, bash might split the word incorrectly. To fix this, I need to adjust `COMP_WORDBREAKS` temporarily to remove the colon so it doesn't interfere with completion.
#
#Next, I should find where "run" appears in the command line words array (`COMP_WORDS`). The position of "run" isn't fixed, so I can't assume it's always at index 1. I need to loop through `COMP_WORDS` until I find the index where the word is "run".
#
#Once I have that index, I check if the current word being completed is exactly the next one after "run". If not, I do nothing. This ensures completion only triggers when needed.
#
#For getting the list of models, using `ollama list` outputs a table with model names in the first column. Parsing this correctly is crucial. Using `awk` to extract the first field from lines after the header seems reliable because it handles variable whitespace better than `cut -d' ' -f1`, which can fail if columns aren't space-separated properly.
#
#I also need to handle cases where a helper function like `_get_comp_words_by_ref` might not be available. So, I'll include a fallback that manually sets `cur` and `prev` variables based on `COMP_WORDS`.
#
#When generating completions, using `compgen -W` is safer than `grep` because it properly handles special characters in model names without causing issues.
#
#Finally, ensuring that the script doesn't fall back to filename completion means registering the function with `complete -F` and not including `-o default`. Also, clearing `COMPREPLY` when no matches are found prevents unexpected behaviors.
#
#Putting this all together, I'll structure the script step by step: adjust word breaks, find "run" index, extract models, handle current and previous words, generate completions safely, and restore original settings before exiting.
#...done thinking.

# Bash completion script for ollama run command
# Handles model names with colons (e.g., codellama:13b)

# Source bash-completion if not already loaded
if ! type compgen > /dev/null 2>&1; then
    source /etc/bash_completion
fi

_ollama_run_complete() {
    # Save and modify word breaks to handle colons in model names
    local old_wb="$COMP_WORDBREAKS"
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}  # Remove colon from word break characters
    
    # Find the index of "run" in COMP_WORDS array
    local run_index=-1
    local i=0
    while [[ $i -lt ${#COMP_WORDS[@]} ]]; do
        if [[ "${COMP_WORDS[$i]}" == "run" ]]; then
            run_index=$i
            break
        fi
        ((i++))
    done
    
    # Only trigger completion when at position right after "run"
    if [[ $run_index -eq -1 ]] || [[ $((run_index + 1)) -ne ${COMP_CWORD} ]]; then
        COMP_WORDBREAKS="$old_wb"  # Restore original word breaks
        return
    fi
    
    # Extract model names from ollama list output, skipping header
    local models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | awk '!seen[$0]++')
    
    # Get current and previous words for completion context
    _get_comp_words_by_ref -n : cur prev words cword 2>/dev/null || {
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    }
    
    # Generate completions using compgen with word list
    COMPREPLY=($(compgen -W "$models" -- "$cur"))
    
    # Restore original word breaks before returning
    COMP_WORDBREAKS="$old_wb"
}

# Register completion function for ollama run command
complete -F _ollama_run_complete ollama


# [[HUMAN COMMENTED-OUT]]
## Explanation:
#1. The script modifies `COMP_WORDBREAKS` to handle colons in model names, then restores it before returning.
#2. It searches for the "run" subcommand position in `COMP_WORDS`.
#3. Completes only when at the correct position after "run".
#4. Uses `awk` to reliably parse model names from `ollama list` output.
#5. Uses `_get_comp_words_by_ref` with fallback to handle word extraction.
#6. Generates completions using `compgen -W` for safe prefix matching.
#7. Properly registers the completion function without falling back to filename completion.
#
## Usage:
#1. Source this script in your shell configuration (e.g., ~/.bashrc)
#2. Run `source /path/to/script.sh`
#3. Test with ollama run <TAB>

