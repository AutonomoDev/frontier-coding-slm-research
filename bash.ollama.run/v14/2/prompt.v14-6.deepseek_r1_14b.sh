#Thinking...
#Alright, I need to write a Bash completion script for the `ollama run` command. Let me think through how to approach this.
#
#First, the function should be called _ollama_completions. It's important to remember that Bash functions in completion scripts usually start with an underscore.
#
#The critical check is on COMP_WORDS[0] and [1]. So, I'll check if the first word is "ollama" and the second is "run". If not, return early with COMPREPLY set to empty.
#
#Next, handling colons. Models like codegemma:7b have colons, which can cause issues because Bash splits on them by default. To handle this, I should use _get_comp_words_by_ref -n : cur prev. This will correctly capture the current word even if it contains a colon. If that doesn't work for some reason, I'll fall back to manually extracting from COMP_WORDS.
#
#Parsing the models: I need to run `ollama list` and process its output. First, check if ollama is installed using command -v. If not, just return. Then, redirect stderr to /dev/null when running ollama list to suppress errors.
#
#For parsing, skip the header line which says "NAME ID SIZE MODIFIED". After that, extract the first column of each line as the model name. Using awk '{print $1}' should do that.
#
#Once I have all the models in an array, I need to generate completions based on the current word (cur). So, filter the models that start with cur, sort them, and use compgen to set COMPREPLY.
#
#Finally, call __ltrim_colon_completions to handle any leading colons in the model names so they display correctly.
#
#Registering the function is done with complete -F _ollama_completions ollama.
#
#I should also make sure that all edge cases are handled: no models available, ollama not installed, etc. The script should be robust and not crash even if these conditions occur.
#
#Putting it all together, I'll structure the function step by step, ensuring each part is correctly implemented and commented for clarity.
#...done thinking.

# Bash completion function for 'ollama run'
# Must be named _ollama_completions to match registration

function _ollama_completions() {
    # Critical index check: Ensure command is exactly 'ollama run'
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && {
        COMPREPLY=()
        return
    }

    local cur prev
    _get_comp_words_by_ref -n : cur prev

    # Check if 'ollama' is installed
    command -v ollama &>/dev/null || {
        COMPREPLY=()
        return
    }

    # Get list of models
    local models=()
    ollama list 2>/dev/null | awk '{if (NR > 1) print $1}' | while read -r model; do
        models+=("$model")
    done

    # Generate completions matching current word
    COMPREPLY=( $(compgen -P "$cur" -- "${models[@]}") )

    # Sort results alphabetically
    [[ ${#COMPREPLY[@]} -gt 0 ]] && {
        IFS=$'\n' COMPREPLY=(`printf '%s\n' "${COMPREPLY[@]}" | sort`)
        unset IFS
    }

    __ltrim_colon_completions "$cur"
}

# Register the completion function for 'ollama'
complete -F _ollama_completions ollama
