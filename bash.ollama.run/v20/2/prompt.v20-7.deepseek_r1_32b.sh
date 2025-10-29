Thinking...
Okay, I need to generate a Bash completion function for the command `ollama run <model>`. Let me break down what needs to be done step by step.

First, I should create a function named `_ollama_completions()`. That's straightforward. 

Next, I have to validate that the command being completed is indeed `ollama run`. So, I'll check if the first word (`COMP_WORDS[0]`) is "ollama" and the second word (`COMP_WORDS[1]`) is "run". If not, I'll set `COMPREPLY` to an empty array and return. This ensures that the completion only triggers when the command starts with `ollama run`.

Then, I need to extract the current word being completed (`cur`) and the previous word (`prev`). For this, I'll use `_get_comp_words_by_ref -n : cur prev`. The `-n :` option means it will handle completions separated by colons, which is important for model names like `codellama:...`.

After that, I should check if the `ollama` command exists. If it doesn't, again, set `COMPREPLY` to empty and return. This prevents errors when the command isn't available.

Now, I need to fetch the list of models using `ollama list`. The output will have a header line, so I'll use `tail -n +2` to skip it. Then, with `awk '{print $1}'`, I extract just the model names into a scalar string variable called `models`.

If there are no models found, I'll set `COMPREPLY` to empty and return to avoid showing any completions.

Next, I generate possible completions using `compgen -W "$models" -- "$cur"`. This matches the current word against the list of models. The result is stored in `COMPREPLY`.

Since the user might have models with colons, like `codellama:llama2`, I need to handle them correctly. Using `__ltrim_colon_completions "$cur"` trims any leading colon from the current word, ensuring proper completion.

Finally, I sort the completions alphabetically for better readability by piping them through `sort`. This is done using `printf "%s\n" "${COMPREPLY[@]}" | sort`.

Putting it all together, I make sure each step is correctly implemented without using arrays for models or any forbidden logic. The function should handle edge cases like missing commands or empty model lists gracefully.
...done thinking.

```bash
_ollama_completions() {
  # Validate that the command is 'ollama run'
  [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && { COMPREPLY=(); return; }
  
  # Get current and previous word for completion
  local cur prev
  _get_comp_words_by_ref -n : cur prev
  
  # Check if ollama command exists
  if ! command -v ollama &>/dev/null; then
    COMPREPLY=()
    return
  fi
  
  # Fetch available models
  local models
  models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
  
  # Return if no models found
  [[ -z "$models" ]] && { COMPREPLY=(); return; }
  
  # Generate completions based on current word
  COMPREPLY=($(compgen -W "$models" -- "$cur"))
  
  # Sort completions and handle colon trimming
  COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
  __ltrim_colon_completions "$cur"
}

complete -F _ollama_completions ollama
```

