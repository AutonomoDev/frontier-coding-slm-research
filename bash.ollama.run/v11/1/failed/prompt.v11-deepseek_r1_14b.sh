#Thinking...
#Okay, so I need to create a Bash completion script for the `ollama run` command that handles model names with colons properly. Let me think through how to approach this.
#
#First, the main issue is that Bash by default splits words on colons, which messes up model names like `codellama:13b`. So when someone types something like `ollama run codellama:` and hits Tab, the completion should suggest models correctly without breaking.
#
#I remember that the solution involves using `_get_comp_words_by_ref` with a flag to handle colons. But I also need a fallback for systems without bash-completion installed. So I'll structure it so that if `_get_comp_words_by_ref -n : cur prev` fails, I parse the words manually.
#
#Next, the function needs to check if the command is `ollama` and the previous word is `run`. If not, it should exit early with an empty COMPREPLY. That makes sense because we only want completions for the `run` subcommand.
#
#Then, when handling model names, I'll retrieve them using `ollama list`. The output has headers, so I need to skip the first line and extract just the model names from the first column. Using awk with `$1` does that. I'll store these in an array called models.
#
#After getting the model names, I need to match against the current word (`$cur`). If there are no matches, set COMPREPLY to empty. Otherwise, sort the matches and use `compgen -W` to generate the completion options.
#
#Importantly, I must call `__ltrim_colon_completions "$cur"` after setting COMPREPLY. This ensures that when model names have colons, they're displayed correctly without leading colons messing up the display.
#
#I should also handle errors gracefully. For example, if `ollama` isn't installed or `ollama list` fails, the script shouldn't crash. So I'll use command substitution with `|| true` and check if models are populated after parsing.
#
#Finally, register the completion function using `complete -F _ollama_completions ollama`. That makes the shell know to use this function when completing `ollama` commands.
#
#Putting it all together, the function will handle both systems with and without bash-completion, parse model names correctly, and ensure that colons in model names don't cause issues.
#...done thinking.

# Bash completion script for ollama run command
# Provides model name completions retrieved from ollama list output

function _ollama_completions {
    # Only complete when the previous word is 'run'
    if [[ "${COMP_WORDS[0]}" != "ollama" || "${prev}" != "run" ]]; then
        COMPREPLY=
        return 0
    fi

    # Attempt to get words with colon handling; fall back to standard parsing
    if ! _get_comp_words_by_ref -n : cur prev; then
        local cur="${COMP_WORDS[COMP_CWORD]}"
        local prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # Get list of available models from ollama list command
    local models=()
    if command -v ollama &> /dev/null; then
        ollama list 2>/dev/null | awk 'NR > 1 { print $1 }' | while read -r model; do
            models+=("$model")
        done
    fi

    # If current word matches a model prefix, generate completions
    if [[ "${#models[@]}" -gt 0 ]]; then
        local matches=()
        for model in "${models[@]}"; do
            if [[ "$model" == "$cur"* ]]; then
                matches+=("$model")
            fi
        done

        if [[ "${#matches[@]}" -gt 0 ]]; then
            # Sort matches and generate completion output
            local sorted_matches=$(printf '%s\n' "${matches[@]}" | sort)
            COMPREPLY="$(compgen -W "$sorted_matches" -- "$cur")"
            __ltrim_colon_completions "$cur" # Critical for proper colon handling in completions
        fi
    fi

    return 0
}

# Register completion function with the shell
complete -F _ollama_completions ollama

