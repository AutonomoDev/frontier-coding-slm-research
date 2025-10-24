Thinking...
Alright, I need to generate a Bash completion script for the command `ollama run`. The goal is to provide dynamic completions of model names when using `ollama run` followed by a model name. 

First, I'll start by understanding how Bash completions work. Completion functions are typically registered with the `complete` command and are called whenever the user presses Tab after typing part of a command. The function needs to determine what options are available based on the current input.

The key requirements for this script are:

1. **Completion after `ollama run`:** The script should only trigger when the user types `ollama run` followed by a space and starts typing a model name.
2. **Handling colons:** Model names can have colons, like `codellama:13b`. Bash typically treats the colon as a word separator, so I need to handle this correctly to ensure that completions work both before and after the colon.
3. **Dynamic model listing:** The script should fetch the list of available models by running `ollama list` and parsing its output.
4. **Robust error handling:** The script must gracefully handle cases where `ollama` isn't installed, no models are found, or other errors occur.

I'll break down the steps needed:

**1. Function Declaration:**
The function will be named `_ollama_completions` and will handle all the completion logic.

**2. Index Check:**
At the start of the function, I need to check if the command being completed is indeed `ollama run`. This is done by checking the first two elements of `COMP_WORDS`, which are `ollama` at index 0 and `run` at index 1. If this condition isn't met, the function exits early with an empty completion.

**3. Colon Handling:**
By default, Bash splits words at colons, which can cause issues when completing model names that include a colon. To fix this, I temporarily remove the colon from `COMP_WORDBREAKS`, reparse the input to correctly capture the current word (`cur`) and previous word (`prev`), and then restore the original word breaks.

**4. Check for `ollama`:**
Before proceeding, the script checks if `ollama` is installed. If not, it sets an empty completion and exits.

**5. Fetching Models:**
The script runs `ollama list` and uses `awk` to extract model names from the output, skipping the header line. This gives a list of models like `codellama:13b`.

**6. Generating Completions:**
Using `compgen`, the script generates possible completions based on the current input (`cur`). These completions are then adjusted using `__ltrim_colon_completions` to ensure that after a colon, only the suffix (like `13b`) is displayed.

**7. Registering the Completion:**
Finally, the script registers itself with Bash's completion system so that it triggers when `ollama` commands are being completed.

Throughout this process, I need to ensure that all possible error cases are handled, such as `ollama` not being installed, no models available, and handling partial inputs correctly. Each step must set `COMPREPLY` appropriately to provide the right suggestions without falling back to default file completions.

Testing each part as I go would help catch issues early. For example, ensuring that after typing `ollama run codellama:`, the script correctly suggests `13b`, `34b`, etc., and that it handles cases where no models are installed by providing an empty completion.

I also need to make sure that the function doesn't introduce any bugs related to word breaks or incorrect indexing, as these can cause the completions to fail silently or show incorrect suggestions. Properly resetting `COMP_WORDBREAKS` after modification is crucial to avoid affecting other parts of the shell session.

In summary, by methodically addressing each requirement and carefully handling edge cases, I can create a reliable Bash completion script for `ollama run`.
...done thinking.

```bash
_ollama_completions() {
    # CRITICAL: Check if completing after "ollama run"
    [[ ${COMP_WORDS[0]} != "ollama" || ${COMP_WORDS[1]} != "run" ]] && { COMPREPLY=(); return 0; }

    # Handle colons: Temporarily remove ':' from word breaks to reparse correctly
    local _old_wb=${COMP_WORDBREAKS}
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}
    _get_comp_words_by_ref -n : cur prev
    COMP_WORDBREAKS=${_old_wb}
    # Now cur/prev are correct (e.g., cur="codellama:13", prev="run")

    # Check if ollama available
    command -v ollama &>/dev/null || { COMPREPLY=(); return 0; }

    # Extract models robustly (skip header, get names only)
    local models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}')

    # If no models, empty reply
    [[ -z $models ]] && { COMPREPLY=(); return 0; }

    # Filter and set completions
    COMPREPLY=( $(compgen -W "$models" -- "$cur") )

    # MANDATORY: Fix display after colons
    __ltrim_colon_completions "$cur"
    return 0
}

complete -F _ollama_completions ollama
```

