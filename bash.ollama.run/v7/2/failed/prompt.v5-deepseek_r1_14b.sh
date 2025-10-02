#Thinking...
#Okay, so I need to create a Bash completion script for the `ollama run` command. The goal is to provide autocompletion suggestions for model names when the user types `ollama run` and presses Tab.
#
#First, I remember that in Bash completion, functions are defined with `complete -F`, so I'll name mine `_ollama_run_completion`. This function will handle the completion logic.
#
#The core requirement is that the completion should activate only when the user is typing right after the `run` subcommand. So, I need to find the index of `run` in `COMP_WORDS` and check if `COMP_CWORD` is exactly one position after that. That way, it's only triggered for the argument directly following `run`.
#
#Next, parsing the models. The user mentioned using `ollama list`, whose output has a header line followed by model names in the first column. I should skip the header and extract just the model names. Using `awk 'NR>1 {print $1}'` is robust because it handles variable whitespace correctly.
#
#But wait, there's a catch with colons. Since `:` is in `COMP_WORDBREAKS`, it won't complete across colons by default. So I need to temporarily remove the colon from `COMP_WORDBREAKS` before generating completions and then restore it afterward. This ensures that model names like `codellama:32b` are treated as single words.
#
#Handling the completion logic, I'll store all model names in an array. Then, using `compgen -W`, I can filter these models based on the current word being typed (`$cur`). This is safer than regex because it avoids any potential issues with pattern matching.
#
#I also need to make sure that if no matches are found, the script exits quietly without suggesting filenames or anything else. So, after filtering, if there are no results, do nothing.
#
#Registration of the function is important too. I'll use `complete -F _ollama_run_completion ollama` to register it for the `ollama` command. But wait, actually, since we're only completing after `run`, perhaps it's better to have the function check if the current word is part of the `run` subcommand.
#
#Wait, no—the registration should be for the `ollama` command, but the function will determine if it's in the context of `run`. So I'll proceed with registering it as a completion function for `ollama`.
#
#Putting this all together, here's what the script would look like:
#
#1. Define the function `_ollama_run_completion`.
#2. Check if `COMP_WORDS` contains 'run'. If not, return.
#3. Determine the index of 'run' in `COMP_WORDS`. If `COMP_CWORD` is not one more than that, return.
#4. Run `ollama list`, parse the output with `awk` to get model names.
#5. Temporarily remove ':' from `COMP_WORDBREAKS`.
#6. Use `compgen -W` to filter models based on `$cur`.
#7. Deduplicate the results if necessary (though `compgen` might handle this).
#8. Restore `COMP_WORDBREAKS` before returning.
#9. Set `COMPREPLY` with the filtered list.
#
#I also need to handle cases where `ollama list` fails, so I'll redirect stderr to /dev/null and check if any models were found.
#
#Potential issues: What if there are no models? The script should just do nothing, which is handled by checking if the model count is zero.
#
#Another point: Using `_get_comp_words_by_ref` might be helpful for getting `cur` and `prev`, but I need to provide a fallback in case the helper function isn't available. So I'll check if `_get_comp_words_by_ref` exists; if not, set `cur` and `prev` manually from `COMP_WORDS`.
#
#Putting it all together, the script should be self-contained, handle all edge cases, and follow the strict requirements provided.
#...done thinking.

# Bash completion script for ollama run command
complete -F _ollama_run_completion ollama

# Function to complete model names after 'run' subcommand
_ollama_run_completion() {
    local cur prev run_index models
    # Get words and current word
    if ! _get_comp_words_by_ref -c cur -p prev; then
        cur=${COMP_WORDS[COMP_CWORD]}
        prev=${COMP_WORDS[COMP_CWORD-1]}
    fi

    # Find the index of 'run' in COMP_WORDS
    run_index=$(printf '%s\n' "${COMP_WORDS[@]}" | grep -n '^run$' | cut -d':' -f1)

    # Only trigger if current word is immediately after 'run'
    if [[ "$prev" != "run" ]]; then
        return
    fi

    # Get list of models from ollama list command
    models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}')

    # If no models, exit
    if [ -z "$models" ]; then
        return
    fi

    # Save old word break and remove colon to handle model names with colons
    local old_wb=$COMP_WORDBREAKS
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}

    # Generate completions for current word
    COMPREPLY=($(compgen -W "$models" -- "$cur"))

    # Restore word break settings
    COMP_WORDBREAKS=$old_wb

    return 0
}
