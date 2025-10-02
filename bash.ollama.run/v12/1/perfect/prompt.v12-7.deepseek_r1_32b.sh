#Thinking...
#Okay, I need to create a Bash completion script for the `ollama run` command. The goal is to have it complete model names from `ollama list`. Hmm, let me think about how to approach this.
#
#First, I remember that when dealing with colons in model names like `codellama:13b`, Bash splits words on colons by default. That can cause issues because when the user types "codellama:", Bash sees "codellama" as the previous word and an empty string as the current word. So, I need a way to handle this correctly.
#
#I recall that there's a function called `_get_comp_words_by_ref` which can help with this. It allows telling Bash not to split on colons by using `-n :`. But wait, what if the user doesn't have bash-completion version 2 or higher? I should include a fallback in case that function isn't available.
#
#Next, I need to check if the command starts with "ollama" and the previous word is "run". If not, we shouldn't provide any completions. That makes sense because we only want to complete after `ollama run`.
#
#Now, for getting the model names, I have to parse the output of `ollama list`. The sample output shows a header line with "NAME ID SIZE MODIFIED", followed by model entries. So, I need to skip that header and any empty lines.
#
#Using `awk '{print $1}'` should extract the first column, which is the model name. But wait, some models have colons in their names, so I need to ensure that when processing each line, only the first field is taken correctly. Maybe using `cut -d' ' -f1` could also work, but I think `awk` is more straightforward here.
#
#I should store these model names in an array called `models`. Then, if there are no models, set `COMPREPLY` to empty and return early.
#
#For the completion logic, when the previous word is "run", we need to find all models that start with the current word (`$cur`). So, loop through each model and check if it starts with `$cur`, adding matching ones to `matches`.
#
#Sorting the matches will help present them in a orderly manner. Using `sort` on the list of matches before passing them to `compgen` makes sense.
#
#After setting `COMPREPLY`, I must remember to call `__ltrim_colon_completions "$cur"`. This function trims any leading colon from completions, ensuring that suggestions appear correctly after a colon. Without this, no suggestions would show up when the user types a colon, which is crucial for our case.
#
#I also need to ensure that the script uses local variables and handles cases where the `ollama` command doesn't exist by checking with `command -v ollama`.
#
#Putting it all together:
#
#1. Define the function `_ollama_completions`.
#2. Check if the first word is "ollama" and the previous word is "run".
#3. Use `_get_comp_words_by_ref` to handle colons, or fall back using `COMP_WORDS`.
#4. Fetch model names from `ollama list`, skipping headers and empty lines.
#5. Collect matching models that start with `$cur`, sort them, and set `COMPREPLY`.
#6. Call `__ltrim_colon_completions` after setting `COMPREPLY`.
#7. Register the completion function with `complete -F`.
#
#I think I've covered all the bases now. Let me write this out step by step in code.
#...done thinking.

_ollama_completions() {
    # Check if the command starts with 'ollama' and previous word is 'run'
    local words cword
    if ! _get_comp_words_by_ref -n : words cword && \
       ! { COMPREPLY=() return; }; then
        return
    fi
    [[ ${words[0]} != "ollama" ]] && return
    local prev="${words[cword-1]}"
    [[ "$prev" != "run" ]] && {
        COMPREPLY=()
        return
    }

    # Handle colon correctly in completions
    if ! _get_comp_words_by_ref -n : cur prev; then
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # Only complete after 'ollama run'
    if [[ "$prev" != "run" ]]; then
        COMPREPLY=()
        return
    fi

    # Check if ollama command exists
    if ! command -v ollama &> /dev/null; then
        COMPREPLY=()
        return
    fi

    # Get list of models from 'ollama list'
    local models=()
    while IFS=$'\n' read -r line || [[ -n "$line" ]]; do
        if [[ "$line" == "NAME ID SIZE MODIFIED"* ]] || [[ -z "$line" ]]; then
            continue
        fi
        model_name=$(echo "$line" | awk '{print $1}' 2>/dev/null)
        [[ -n "$model_name" ]] && models+=("$model_name")
    done < <(ollama list 2>/dev/null)

    # No models available, return empty
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

    # Sort matches for consistent ordering
    sorted_matches=$(printf '%s\n' "${matches[@]}" | sort)

    # Set completions and handle colon correctly
    COMPREPLY=($(compgen -W "$sorted_matches" -- "$cur"))
    __ltrim_colon_completions "$cur"
}

complete -F _ollama_completions ollama
