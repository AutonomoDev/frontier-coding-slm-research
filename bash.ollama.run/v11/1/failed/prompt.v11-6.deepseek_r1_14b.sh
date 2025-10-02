#Thinking...
#Okay, so I need to create a robust Bash completion script for the `ollama run` command. The main issue is that model names can have colons, like `codellama:13b`, and by default, Bash splits on colons, which messes up the word parsing.
#
#Hmm, the user mentioned using `_get_comp_words_by_ref` with the `-n :` flag to handle colons properly. I should check if that's available, but also provide a fallback for systems without bash-completion. Oh right, because not everyone might have it installed.
#
#So the function is called `_ollama_completions`. It needs to be defined and then registered with `complete`. The first step inside the function is to check if the command is `ollama` and the previous word is `run`. If not, return early. How do I get those values? Maybe using COMP_WORDS.
#
#Wait, but handling colons complicates things. So I should use `_get_comp_words_by_ref -n : cur prev`. But what if that's not available? Then fall back to parsing COMP_WORDS manually. That makes sense for compatibility.
#
#Once the current and previous words are correctly parsed, especially around colons, the next step is to generate completions when `prev` is "run". So I need to run `ollama list`, parse the output, extract model names, and then match against the current word.
#
#Parsing `ollama list` with awk seems efficient. The output has a header, so starting from the second line. The models are in the first column, but sometimes there might be extra columns or whitespace. Using `$1` should get the first field, but maybe some have spaces? Not sure, but using `awk '{print $1}'` after skipping the header is probably good.
#
#Then, I need to filter these model names that match the current word. So for each model in the list, check if it starts with `$cur`. If so, add it to COMPREPLY.
#
#But wait, colons are part of the model names. When completing, the colon might cause issues in display. Oh right, I need to call `__ltrim_colon_completions "$cur"` after setting COMPREPLY to handle this correctly.
#
#Also, error handling is important. What if `ollama` isn't installed? The script should check that first and return early. And if `ollama list` fails or returns nothing, it should handle that gracefully too.
#
#Putting it all together:
#
#1. Function starts by checking command and previous word.
#2. Uses _get_comp_words_by_ref for colon handling, with a fallback.
#3. If conditions met, runs ollama list, parses models.
#4. Filters models matching current word.
#5. Uses compgen to generate completions, sorted.
#6. Calls __ltrim_colon_completions to fix display issues.
#7. Sets COMPREPLY and handles no matches.
#
#I need to make sure all variables are correctly set and that the function is efficient, especially with large model lists. Also, comments should explain each step for clarity.
#...done thinking.

# Bash completion script for ollama run command
# Provides model name completions retrieved from ollama list

function _ollama_completions() {
    # Check if this is the 'run' subcommand and ollama exists
    if [[ "${COMP_WORDS[0]}" != "ollama" || "${prev}" != "run" ]]; then
        return 0
    }

    # Get words with proper colon handling
    if _get_comp_words_by_ref -n : cur prev; then
        :
    else
        # Fallback for systems without bash-completion
        local comp_words=("${COMP_WORDS[@]}")
        cword="${COMP_CWORD}"
        cur="${comp_words[cword]}"
        prev="${comp_words[cword-1]}"
    fi

    # Get available models and extract names
    if ! command -v ollama &> /dev/null; then
        COMPREPLY=()
        return 0
    }

    local models=$(ollama list | awk 'NR==1 {next} {print $1}')

    # Check if we have valid model names
    if [ -z "$models" ]; then
        COMPREPLY=()
        return 0
    fi

    # Filter matching models and prepare for completion
    local matches=()
    for model in $models; do
        if [[ "${model}" == *"${cur}"* ]]; then
            matches+=("${model}")
        fi
    done

    # Handle empty or no matches
    if [ ${#matches[@]} -eq 0 ]; then
        COMPREPLY=()
        return 0
    fi

    # Generate completion output and handle colons in display
    local sorted_matches=$(printf '%s\n' "${matches[@]}" | sort)
    COMPREPLY=( $(compgen -W "$sorted_matches" -- "$cur") )
    __ltrim_colon_completions "$cur"

    return 0
}

# Register completion function for ollama command
complete -F _ollama_completions ollama
