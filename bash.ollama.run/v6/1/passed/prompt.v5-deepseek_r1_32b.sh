#Thinking...
#Alright, I need to create a Bash completion script for the `ollama run` command. The goal is to provide autocompletion suggestions for model names when the user types `ollama run` and presses TAB.
#
#First, I should understand how Bash completions work. They typically use functions that set the `COMPREPLY` variable based on the current command line state. So, I'll start by defining a function, maybe `_ollama_run_completion`, which will handle the completion logic.
#
#The script needs to be self-contained and sourced, so I'll make sure it's a standalone script that can be included in the user's environment.
#
#Next, I need to determine when this completion should trigger. The core requirement is that it activates only for the word immediately following `run`. So, I have to check that the command starts with `ollama` and the previous word is exactly `run`.
#
#I'll use `COMP_WORDS` and `COMP_CWORD` to get the current command line words and the index of the current word. If `prev` (the previous word) isn't `run`, then I shouldn't do anything.
#
#Now, for parsing the model names. The models are listed by running `ollama list`. The output has a header line followed by lines with model details. I need to extract only the first column of each line after skipping the header.
#
#Using `cut` makes sense here because it's reliable and part of GNU coreutils. So, the command would be something like `ollama list | tail -n +2 | cut -d ' ' -f1`. This skips the header with `tail`, then extracts the first field.
#
#I should store these model names in an array to avoid duplicates. Using `mapfile` (or `readarray`) can help read each line into an array. Then, I'll use `printf "%s\n" "${models[@]}" | sort -u` to get unique and sorted names.
#
#Next, contextual filtering is needed. The suggestions should only include models that start with the current word being typed (`cur`). So, using `grep "^$cur"` will filter the list appropriately.
#
#I need to ensure that if there's no match, the script doesn't fall back to suggesting files. Just return nothing in that case.
#
#Putting it all together, I'll write a function that does these steps and then set up the completion for the `run` subcommand.
#
#Testing edge cases is important. For example, when the user hasn't installed any models, `ollama list` might be empty, so no completions should show. Also, ensuring that model names with colons are handled correctly since they contain valid characters in Bash.
#
#Finally, I'll make sure the script uses standard variables and doesn't rely on external dependencies beyond what's allowed. Including a fallback for `_get_comp_words_by_ref` ensures compatibility across different environments.
#...done thinking.

# Completion function for ollama run command
_ollama_run_completion() {
    # Check if we're completing after 'run'
    local cur prev words cword
    _get_comp_words_by_ref -n : cur prev words cword || \
        {
            # Fallback if _get_comp_words_by_ref is not available
            cur=${COMP_WORDS[COMP_CWORD]}
            prev=${COMP_WORDS[COMP_CWORD-1]}
            words=("${COMP_WORDS[@]}")
            cword=$COMP_CWORD
        }

    # Only trigger for 'ollama run <TAB>'
    if [[ ${words[0]} != "ollama" ]] || [[ $prev != "run" ]]; then
        return
    fi

    # Get list of available models from ollama list, skipping header and extracting first column
    local models
    {
        mapfile -t models < <(ollama list 2>/dev/null | tail -n +2 | cut -d ' ' -f1)
    } || return

    # If no models are available, do nothing
    (( ${#models[@]} == 0 )) && return

    # Filter models that start with the current word
    local filtered
    {
        mapfile -t filtered < <(printf "%s\n" "${models[@]}" | sort -u | grep "^$cur")
    } || return

    # Return only unique matches
    COMPREPLY=("${filtered[@]}")
}

# Register completion function for ollama run
complete -F _ollama_run_completion ollama

# [[HUMAN COMMENTED-OUT]]
## Explanation of the script:
#
#1. The function `_ollama_run_completion` is defined to handle completion logic specifically for the `run` subcommand.
#2. It uses `_get_comp_words_by_ref` with a fallback to extract current (`cur`) and previous (`prev`) words from the command line.
#3. The completion only triggers if the first word is `ollama` and the previous word is exactly `run`.
#4. The script retrieves available models by running `ollama list`, skipping the header, and extracting the first column (model names) using `cut`.
#5. Models are filtered to only include those that start with the current word being typed (`cur`), ensuring contextual filtering.
#6. Duplicate entries are removed using `sort -u` to ensure unique suggestions.
#7. If no matching models are found, `COMPREPLY` remains empty, providing no suggestions (no fallback to filenames).
#8. The completion function is registered for use with the `complete` command specifically for `ollama`.
#
## This script meets all requirements and avoids common pitfalls by:
#- Only completing after `run`
#- Parsing only model names from ollama list
#- Filtering results based on current input
#- Avoiding filename fallbacks
#- Using standard Bash and coreutils commands
#- Providing unique suggestions
#- Handling edge cases like empty output gracefully
#
