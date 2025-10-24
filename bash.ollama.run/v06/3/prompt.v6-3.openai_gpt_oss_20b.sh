#!/usr/bin/env bash
# Bash completion script for the `ollama run` command
# Provides model name completions based on the output of `ollama list`

#Thinking...
#We need to produce a self-contained bash script that can be sourced to enable completion for ollama run. Requirements: use bash-completion framework, ensure that it triggers only when first word is 'ollama' and previous word is 'run'. Use COMP_WORDS and COMP_CWORD. Use _get_comp_words_by_ref if available with fallback.
#
#We need to parse 'ollama list' output, extract first column excluding header. Use cut -f1 maybe? But default is tab separated? The output appears tabular but separated by spaces, but we can use awk or cut. They require using standard tools like cut. We can use `cut -d' ' -f1` but multiple spaces? Might need to use `awk '{print $1}'`. But they specifically want cut. However cut with delim space might treat consecutive spaces as separate fields, but default is delimiter is a single character, not multiple. But we can use `cut -d' ' -f1`. If there are multiple spaces, fields may include empty fields, leading to wrong extraction. Better to use `awk`. But they specify use cut, maybe we can use `cut -d' ' -f1` but we also need to skip header. We can skip first line by `sed 1d`. Then use cut.
#
#But to handle names containing colons, they are fine.
#
#We need to avoid duplicates. We can sort -u.
#
#We need to filter by current word: `COMPREPLY=($(compgen -W "${models}" -- "$cur"))`. But that might produce filenames fallback. Actually `compgen -W` with -W will produce matching words, no fallback. We can use `compgen -W`. But we must not fallback to filenames. That is default behavior? If no matches, compgen returns empty. So fine.
#
#But to prevent fallback to files, we need to set `COMPREPLY=()`. That is fine.
#
#So algorithm: function _ollama_run_completion() { ... }
#
#Get cur and prev. Use _get_comp_words_by_ref cur prev if available else set.
#
#Check if $COMP_WORDS[0] == "ollama" and $prev == "run". Only then proceed.
#
#Get model names:
#
#`local models=$(ollama list | sed 1d | awk '{print $1}' | sort -u)` but use cut: `sed 1d | cut -d' ' -f1`. But if there are multiple spaces, the first column may still be correct because the first field is until first space. Actually if there are multiple spaces, cut will treat first field as first column until first space? Wait: cut with delimiter ' ' splits on single space only, not contiguous. So if there are multiple spaces, the first field might be empty. Eg: "NAME        ID" has multiple spaces. So first field might be "NAME" then second is empty? Actually `cut -d' ' -f1` will treat each space as delimiter. Consecutive delimiters produce empty fields. The first field before first delimiter is "NAME". So that works. But for "llama3:latest   a7320c...", first field is "llama3:latest". Good. So we can use cut -d' ' -f1.
#
#But there might be preceding spaces? No.
#
#So: `local models=$(ollama list | sed 1d | cut -d' ' -f1 | tr '\n' ' ')`. Then `COMPREPLY=($(compgen -W "${models}" -- "$cur"))`. Use compgen with -W to filter.
#
#Need to handle quotes properly: `compgen -W "${models}" -- "$cur"`. But ${models} is a string with spaces. The variable expansion is inside double quotes, but compgen -W expects a string of words separated by spaces. So we need to pass the string unquoted? Actually we can use compgen -W "${models}" but then quoting will preserve spaces? Actually compgen -W will treat the argument as a string of words. It will read the string and split on spaces. So quoting it is fine. But if models contains spaces, we want them to be words. So quoting it will preserve them as one argument string. That's fine.
#
#Edge: if no matches, COMPREPLY will be empty.
#
#Also need to provide unique suggestions: use sort -u.
#
#No duplicates if `sort -u`.
#
#Now we need to ensure that if _get_comp_words_by_ref fails, we fallback: `cur=${COMP_WORDS[COMP_CWORD]}`; `prev=${COMP_WORDS[COMP_CWORD-1]}`.
#
#Also we need to handle `prev` when COMP_CWORD-1 < 0? but only when word is at beginning. But we only call if prev==run, which means we are at second or later. But we can guard.
#
#The script must be self-contained, with comments lines starting with #.
#
#Also we need to register the completion: `_register` maybe. We can define `_ollama_run_completion` and then call `complete -F _ollama_run_completion ollama`.
#
#Need to include `# shellcheck`? Not necessary.
#
#We should ensure script doesn't rely on bash-completion functions unless present. But we want to use _get_comp_words_by_ref if available. We'll check: `if type -p _get_comp_words_by_ref > /dev/null; then _get_comp_words_by_ref cur prev; else ... fi`.
#
#We also need to ensure that if _get_comp_words_by_ref is missing, we fallback.
#
#Now final script:
#
#
## Bash completion script for 'ollama run' command
## Provides model name completions based on 'ollama list'
#
#_ollama_run_completion() {
#    local cur prev
#
#    # Attempt to use the bash-completion helper if available
#    if type -p _get_comp_words_by_ref > /dev/null; then
#        _get_comp_words_by_ref cur prev
#    else
#        # Fallback: manually set cur and prev
#        cur="${COMP_WORDS[COMP_CWORD]}"
#        prev="${COMP_WORDS[COMP_CWORD-1]}"
#    fi
#
#    # Only trigger when the command is 'ollama' and the previous word is 'run'
#    if [[ "${COMP_WORDS[0]}" != ollama || "$prev" != run ]]; then
#        return 0
#    fi
#
#    # Retrieve available model names from 'ollama list'
#    # Skip the header line, extract first column, sort uniquely
#    local models
#    models=$(ollama list | sed 1d | cut -d' ' -f1 | sort -u | tr '\n' ' ')
#
#    # Generate completions filtered by the current word
#    COMPREPLY=($(compgen -W "${models}" -- "$cur"))
#}
#
## Register the completion function for the 'ollama' command
#complete -F _ollama_run_completion ollama
#
#
#But we must ensure we don't use `sort` incorrectly: we need to sort before unique? We use `sort -u`. That will sort and unique.
#
#Now check that we didn't introduce file fallback. Using compgen -W will only produce matching words. No fallback to files.
#
#Edge: if models variable contains trailing space, compgen will treat it as a word. But that's fine.
#
#Better to use `models=$(ollama list | sed 1d | cut -d' ' -f1 | sort -u)` and then pass as array: `COMPREPLY=($(compgen -W "${models[*]}" -- "$cur"))`. But `${models[*]}` expands to space-separated words. But if `models` is a string, we need to handle spaces.
#
#Better to assign models to array: `readarray -t model_array < <(ollama list | sed 1d | cut -d' ' -f1 | sort -u)` and then use `COMPREPLY=($(compgen -W "${model_array[*]}" -- "$cur"))`. But readarray may not be available in older Bash? It's available in Bash 4+. We can use while read -r line; do array+=("$line"); done < <(...) . But simpler to use string.
#
#We must ensure no duplication. Using sort -u.
#
#Edge: If `ollama list` fails? It may produce error. But we ignore.
#
#Better to guard: if command fails, exit.
#
#Simplify: `models=$(ollama list 2>/dev/null | sed 1d | cut -d' ' -f1 | sort -u)`.
#
#Also, for fallback, use `prev=${COMP_WORDS[COMP_CWORD-1]}` only if COMP_CWORD > 0.
#
#Edge: If COMP_CWORD==0, but then cur would be empty and prev maybe empty. But we don't care.
#
#Also we need to ensure `complete` call only once. It's fine.
#
#Now produce final script.
#
#Make sure to comment each line.
#
#Let's produce final answer.
#...done thinking.

# Function that generates completions for `ollama run`
_ollama_run_completion() {
    local cur prev

    # Try to use the standard helper from bash-completion if it exists
    if type -p _get_comp_words_by_ref > /dev/null 2>&1; then
        _get_comp_words_by_ref cur prev
    else
        # Fallback: set cur and prev manually from COMP_WORDS
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # Only trigger when the command is `ollama` and the previous word is `run`
    if [[ "${COMP_WORDS[0]}" != ollama || "$prev" != run ]]; then
        return 0
    fi

    # Get the list of available local model names
    #   1. Run `ollama list`
    #   2. Remove the header line
    #   3. Extract the first column (model name)
    #   4. Remove duplicates
    local models
    models=$(ollama list 2>/dev/null | sed 1d | cut -d' ' -f1 | sort -u)

    # If no models were found, exit without suggestions
    if [[ -z "$models" ]]; then
        COMPREPLY=()
        return 0
    fi

    # Provide completions that match the current word (`cur`)
    # `compgen -W` filters by prefix and never falls back to filenames
    COMPREPLY=($(compgen -W "${models}" -- "$cur"))
}

# Register the completion function for the `ollama` command
complete -F _ollama_run_completion ollama

# End of script
