Thinking...
Okay, so I need to create a Bash completion script for the `ollama run` command. Let me think through how to approach this step by step.

First, I remember that Bash completions involve writing a function that gets called when you press Tab. This function will generate the possible completions based on the current input.

The task is specifically for `ollama run <model>`, so the script should activate only when the user types `ollama run` and then presses Tab. That means I need to check if the first two words are "ollama" and "run". Also, since we're completing the model name which is the third word, I should ensure that `COMP_CWORD` is 2 because Bash counts words starting from 0.

Next, handling colons in model names like `codellama:13b` is important. From the notes, using `_get_comp_words_by_ref -n :` helps set `cur` correctly when dealing with colons. This function splits the word at the colon and sets `cur` to include it, which is necessary for proper completion after a colon.

Parsing the output of `ollama list` is another step. The output includes headers, so I need to skip the first line. Using `tail -n +2` will get all lines except the header. Then, using `awk '{print $1}'` extracts just the model names from each line. This gives me an array of models.

I should sort these models alphabetically for consistent and easier completion. Without sorting, the order might be unpredictable, which isn't user-friendly.

For generating completions, I'll use `compgen -W` with the sorted list of models. This command takes the word list and the current word (`$cur`) to produce matches. It's better than manually filtering because it handles more cases correctly.

After generating completions, I need to handle colons again by trimming them if necessary. The function `__ltrim_colon_completions` does this, ensuring that when a user tabs after a colon, the colon isn't duplicated or left hanging.

I also need to make sure that edge cases are handled. For example, if `ollama` isn't installed, the script should gracefully handle it by not providing completions. Similarly, if there are no models listed, nothing should be suggested.

Putting it all together, I'll structure the function step by step: check the command words and position, set up `cur` and `prev`, parse the model list, sort them, generate completions, and then adjust for colons before returning the results.

I think I've covered all the points from the task and the notes. Now, I'll translate this into code, making sure each part is correctly implemented and that all edge cases are handled.
...done thinking.

```bash
_ollama_completions() {
    # Check if command is 'ollama run'
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return 0; }
    # Only complete for the model argument (third word)
    [[ $COMP_CWORD -ne 2 ]] && return 0

    local cur prev
    # Handle colon completion properly
    if type _get_comp_words_by_ref &>/dev/null; then
        _get_comp_words_by_ref -n : cur prev
    else
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    local models=()
    # Parse model names from 'ollama list'
    if command -v ollama &>/dev/null; then
        models=($(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}'))
    fi

    # Sort models alphabetically for consistent completion order
    IFS=$'\n' models=($(sort <<<"${models[*]}"))
    unset IFS

    # Generate completions using compgen
    COMPREPLY=( $(compgen -W "${models[*]}" -- "$cur") )

    # Trim colon from completions if necessary
    if type __ltrim_colon_completions &>/dev/null; then
        __ltrim_colon_completions "$cur"
    fi
}

# Register the completion function for 'ollama'
complete -F _ollama_completions ollama
```

