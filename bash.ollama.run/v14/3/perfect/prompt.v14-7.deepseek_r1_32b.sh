#Thinking...
#Okay, so I need to create a Bash completion script for the `ollama run` command. Let me think through how to approach this step by step.
#
#First, I remember that Bash completions involve writing a function that sets the COMPREPLY variable based on the current input. The function is triggered when the user presses Tab after typing part of a command.
#
#The task specifies that the completion should only activate for `ollama run`, so I need to check if the first two words are "ollama" and "run". That means checking COMP_WORDS[0] == "ollama" and COMP_WORDS[1] == "run". If not, just return without setting anything.
#
#Next, handling model names with colons is crucial. By default, Bash splits on colons, which can cause issues. I recall that using `_get_comp_words_by_ref -n :` helps prevent this splitting. So I should use that to get the current and previous words correctly.
#
#Parsing the output of `ollama list` is another important step. The output has a header line with "NAME ID SIZE MODIFIED", so I need to skip the first line. Then, extract only the first column which contains the model names, including those with colons. Using `awk '{print $1}'` should handle that.
#
#I also need to ensure that if the `ollama` command isn't found, the script handles it gracefully by returning early.
#
#Putting this together, the function will:
#
#1. Check if the command is `ollama run`.
#2. Use `_get_comp_words_by_ref` to handle colons properly.
#3. Run `ollama list`, parse the output to get model names.
#4. Filter these models based on the current input (cur).
#5. Sort the results and set COMPREPLY using compgen.
#
#Finally, I must call `__ltrim_colon_completions "$cur"` at the end to ensure that completions after a colon are handled correctly.
#
#I should also make sure that all edge cases are covered, like when there are no models installed or if `ollama` isn't available. Testing each part would help catch any issues, but since I'm writing this from scratch, I'll have to be thorough in the code.
#...done thinking.

_ollama_completions() {
    # Check if command is "ollama run"
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }

    # Handle colon in model names
    local cur prev
    _get_comp_words_by_ref -n : cur prev || {
        cur="${COMP_WORDS[2]}"
        prev="${COMP_WORDS[1]}"
    }

    # Check if ollama command exists
    command -v ollama &>/dev/null || { COMPREPLY=(); return; }

    # Get list of models from ollama
    local models
    models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}')

    # Filter and sort models matching current input
    local candidates
    candidates=($(compgen -W "$models" -- "$cur"))

    # Apply colon trimming to show completions correctly
    COMPREPLY=("${candidates[@]}")
    __ltrim_colon_completions "$cur"
}

# Register completion function for ollama command
complete -F _ollama_completions ollama
