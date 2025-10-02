#Thinking...
#We need produce bash script with function _ollama_completions. Use bash-completion functions. Use local variables. Ensure fallback.
#
#Need to check if ollama command exists: command -v ollama > /dev/null 2>&1 || return
#
#Implement retrieving model names: maybe use output of `ollama list --format json`? But sample output is table. Use awk '/^$/ {next} NR>1 {print $1}' to get names.
#
#Need to handle colons: _get_comp_words_by_ref -n : cur prev. fallback else.
#
#Use compgen -W "$sorted_matches" -- "$cur".
#
#__ltrim_colon_completions "$cur" after COMPREPLY.
#
#Finally register.
#
#Ensure function name _ollama_completions.
#
#Let's craft.
#
#Need to consider when the current word is after 'run', we want model names. If prev is 'run', or cur preceded by 'run'? Actually typical completion: ollama run <model>. So we want prev word is "run" and cur is model being typed.
#
#If prev not "run" but command maybe like "ollama run something", we need to check if we are completing second word after run? If user typed 'ollama run ' then prev is 'run'. Good.
#
#Also handle colon. Use _get_comp_words_by_ref -n : cur prev; This splits on colon too.
#
#Edge: If _get_comp_words_by_ref not found, fallback.
#
#We also need to check if cur empty or not.
#
#Implementation details:
#
#```
#_ollama_completions()
#{
#    local cur prev words cword
#    # early exit if not ollama or not run subcommand
#    if [[ "${COMP_WORDS[0]}" != "ollama" ]]; then
#        return 0
#    fi
#
#    # Check if subcommand run present
#    # Use _get_comp_words_by_ref if available
#    if ! _get_comp_words_by_ref -n : cur prev; then
#        # fallback
#        cur="${COMP_WORDS[COMP_CWORD]}"
#        prev="${COMP_WORDS[COMP_CWORD-1]}"
#    fi
#
#    # Only proceed if previous word is run
#    if [[ "$prev" != "run" ]]; then
#        COMPREPLY=()
#        return 0
#    fi
#
#    # Ensure ollama command exists
#    if ! command -v ollama >/dev/null 2>&1; then
#        COMPREPLY=()
#        return 0
#    fi
#
#    # Retrieve model names
#    local models_output
#    models_output=$(ollama list 2>/dev/null)
#    local -a models
#    if [[ -n "$models_output" ]]; then
#        while IFS= read -r line; do
#            # Skip header
#            [[ "$line" == NAME* ]] && continue
#            # Extract first column (model name)
#            models+=("${line%%[[:space:]]*}")
#        done <<< "$models_output"
#    fi
#
#    if [[ ${#models[@]} -eq 0 ]]; then
#        COMPREPLY=()
#        return 0
#    fi
#
#    # Filter matches
#    local -a matches
#    for m in "${models[@]}"; do
#        if [[ "$m" == $cur* ]]; then
#            matches+=("$m")
#        fi
#    done
#
#    # Sort matches
#    IFS=$'\n' sorted=$(printf '%s\n' "${matches[@]}" | sort)
#    unset IFS
#
#    COMPREPLY=($(compgen -W "$sorted" -- "$cur"))
#    __ltrim_colon_completions "$cur"
#    return 0
#}
#complete -F _ollama_completions ollama
#```
#
#Need to define local variables and handle if compgen fails.
#
#Also need to make sure __ltrim_colon_completions is defined; part of bash completion library.
#
#Ok.
#
#Let's produce final code.
#...done thinking.

_ollama_completions() {
    # Function to provide bash completions for the 'ollama' command,
    # specifically completing model names after the 'run' subcommand.
    local cur prev words cword

    # Only proceed if the command being completed is 'ollama'.
    # COMP_WORDS[0] contains the command name.
    if [[ "${COMP_WORDS[0]}" != "ollama" ]]; then
        return 0
    fi

    # Retrieve the current word (what the user is typing) and the previous word.
    # Use the bash-completion helper _get_comp_words_by_ref if available.
    # The '-n :' flag tells it to treat colons as part of the word instead of word separators.
    if ! _get_comp_words_by_ref -n : cur prev; then
        # Fallback for systems that do not have the bash-completion library loaded.
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # We only want to complete after the 'run' subcommand.
    if [[ "$prev" != "run" ]]; then
        COMPREPLY=()
        return 0
    fi

    # Ensure the external 'ollama' binary is available before invoking it.
    if ! command -v ollama >/dev/null 2>&1; then
        COMPREPLY=()
        return 0
    fi

    # Grab the list of available models by running 'ollama list'.
    # Suppress any error messages (e.g., if the server is unreachable) by redirecting stderr.
    local models_output
    models_output=$(ollama list 2>/dev/null)

    # Parse the output to extract the model names (first column).
    # The output typically looks like:
    # NAME ID SIZE MODIFIED
    # <model_name> ...
    # Skip the header line that starts with 'NAME'.
    local -a models
    if [[ -n "$models_output" ]]; then
        while IFS= read -r line; do
            [[ "$line" == NAME* ]] && continue   # Skip header
            # The first field before any whitespace is the model name.
            models+=("${line%%[[:space:]]*}")
        done <<< "$models_output"
    fi

    # If we couldn't retrieve any model names, exit gracefully.
    if [[ ${#models[@]} -eq 0 ]]; then
        COMPREPLY=()
        return 0
    fi

    # Build a list of matches that start with the current word.
    local -a matches
    for m in "${models[@]}"; do
        if [[ "$m" == $cur* ]]; then
            matches+=("$m")
        fi
    done

    # If there are no matches, clear the completion list.
    if [[ ${#matches[@]} -eq 0 ]]; then
        COMPREPLY=()
        return 0
    fi

    # Sort the matches alphabetically.
    local sorted
    IFS=$'\n' sorted=$(printf '%s\n' "${matches[@]}" | sort)
    unset IFS

    # Generate the final completion list using compgen.
    COMPREPLY=($(compgen -W "$sorted" -- "$cur"))

    # Trim any leading colon from completions so that 'codellama:' is displayed correctly.
    # __ltrim_colon_completions is provided by the bash-completion library.
    __ltrim_colon_completions "$cur"
    return 0
}
complete -F _ollama_completions ollama
