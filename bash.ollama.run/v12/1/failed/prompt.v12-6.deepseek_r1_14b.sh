#Thinking...
#Okay, I need to create a Bash completion script for the `ollama run` command. The goal is to complete model names from the output of `ollama list`. Model names often have colons, like `codellama:13b`, so handling them correctly is crucial.
#
#First, I'll start by outlining the function structure as required. The function will be called `_ollama_completions`.
#
#Next, I need to check if the first word is "ollama" and the previous word is "run". If not, set `COMPREPLY=()` and return early to avoid processing.
#
#Handling colons in Bash can be tricky because they split words. The solution involves using `_get_comp_words_by_ref -n : cur prev`. If that function isn't available, I'll fallback by extracting the current and previous words from `COMP_WORDS`.
#
#Then, if the context is correct (i.e., after `ollama run`), I need to check if the `ollama` command exists. If not, set `COMPREPLY=()`.
#
#Assuming `ollama` exists, I'll execute `ollama list 2>/dev/null` and parse its output line by line. The first line is a header, so I'll skip it. For each subsequent line, I'll extract the model name using `awk '{print $1}'` and add it to an array called `models`.
#
#If the models array is empty, set `COMPREPLY=()` and return.
#
#I need to find matches that start with the current word (`$cur`). These matches will be sorted alphabetically. Then, use `compgen -W` to generate the completion options.
#
#After setting `COMPREPLY`, I must call `__ltrim_colon_completions "$cur"` to ensure that colons are handled correctly, preventing any issues with suggestions not appearing after a colon.
#
#Finally, I'll register the function with `complete` so it triggers for `ollama` commands.
#
#Throughout, I need to make sure I'm using local variables where possible, redirecting errors to `/dev/null`, and handling all edge cases like no models available.
#...done thinking.

# Bash completion script for ollama run command
function _ollama_completions() {
    # Check if the current command is 'ollama run'
    if [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]; then
        COMPREPLY=()
        return
    fi

    # Handle colon completion correctly
    local cur prev
    if ! _get_comp_words_by_ref -n : cur prev; then
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # Ensure ollama command exists
    if ! command -v ollama &> /dev/null; then
        COMPREPLY=()
        return
    fi

    # Get list of models and extract names
    local models=()
    while IFS= read -r line <&3; do
        # Skip header and empty lines
        if [[ "$line" == "NAME ID SIZE MODIFIED" ]]; then
            continue
        fi
        if [[ -z "$line" ]]; then
            continue
        fi
        # Extract first column (model name)
        local model=$(echo "$line" | awk '{print $1}')
        models+=("$model")
    done 3< <(ollama list 2>/dev/null)

    # No models found
    if [[ ${#models[@]} -eq 0 ]]; then
        COMPREPLY=()
        return
    fi

    # Find matches starting with current word
    local matches=()
    for model in "${models[@]}"; do
        if [[ "$model" == "$cur"* ]]; then
            matches+=("$model")
        fi
    done

    # Sort matches alphabetically
    local sorted_matches=$(printf '%s\n' "${matches[@]}" | sort)

    # Generate completion suggestions
    COMPREPLY=$(compgen -W "$sorted_matches" -- "$cur")

    # Fix colon handling in completions
    __ltrim_colon_completions "$cur"
}

# Register the completion function for ollama command
complete -F _ollama_completions ollama

# The following lines are for backward compatibility with versions older than bash 4.3
_ollama_completion() {
    local cur prev
    if ! _get_comp_words_by_ref -n : cur prev; then
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # Fallback logic for older bash versions (removed in newer versions)
    case $prev in
        run) 
            if command -v ollama &> /dev/null; then
                local models=()
                while IFS= read -r line <&3; do
                    if [[ "$line" == "NAME ID SIZE MODIFIED" ]]; then
                        continue
                    fi
                    if [[ -z "$line" ]]; then
                        continue
                    fi
                    models+= "$(echo "$line" | awk '{print $1}')"
                done 3< <(ollama list 2>/dev/null)
                COMPREPLY=$(compgen -W "${models[*]}" -- "$cur")
                __ltrim_colon_completions "$cur"
            fi
        ;;
    esac
}
complete -F _ollama_completion ollama
