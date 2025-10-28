Thinking...
Okay, I need to create a bash completion script for the command `ollama run <model>`. Let's go through this step by step.

First, the function name is `_ollama_completions()`. That seems straightforward.

Next, I have to check if the command is indeed `ollama run`. So, I'll look at the second word. If either the first word isn't "ollama" or the second isn't "run", I should return early with an empty COMPREPLY. Also, I need to ensure that we're completing exactly when there are two words so far. So, I'll check if COMP_CWORD is not equal to 2 and return if that's the case.

Handling colons is tricky. I remember from the guidelines that using `_get_comp_words_by_ref -n :` helps split the words correctly around colons. I need to set `cur` and `prev` variables properly. If the function exists, use it; otherwise, fall back to getting the last two words.

Parsing the models: I have to run `ollama list`, skip the header (which is the first line), and extract the model names from the second column. Using `tail -n +2` skips the header, and `awk '{print $1}'` gets the first field of each remaining line. So, I'll store these in an array called models.

Sorting the models before completion ensures that the suggestions are in order. I can sort them using `sort` after collecting all model names.

For completions, I should use `compgen -W` with the sorted models and pass the current word to filter matches. This avoids manual loops or filters which could introduce bugs.

Finally, I need to handle colons correctly by trimming them using `__ltrim_colon_completions` after generating the completions.

I also need to make sure that all edge cases are handled, like when ollama isn't installed or no models are listed. The script should return nothing in those cases to prevent errors during completion.

Putting it all together, I'll structure the function step by step, ensuring each part is correctly implemented according to the guidelines.
...done thinking.

```bash
_ollama_completions() {
    # Check if command is "ollama run"
    [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]] && {
        COMPREPLY=();
        return 0;
    };
    [[ $COMP_CWORD -ne 2 ]] && return 0;

    # Handle colons and set current/previous words
    local cur prev;
    if type _get_comp_words_by_ref &>/dev/null; then
        _get_comp_words_by_ref -n : cur prev;
    else {
        cur="${COMP_WORDS[COMP_CWORD]}";
        prev="${COMP_WORDS[COMP_CWORD-1]}";
    };

    # Parse models from ollama list output
    local models=();
    if command -v ollama &>/dev/null; then
        models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}');
        IFS=$'\n' models=($(sort <<<"${models[*]}")); unset IFS;
    fi;

    # Generate completions
    COMPREPLY=( $(compgen -W "${models[*]}" -- "$cur") );

    # Handle colons in completions
    if type __ltrim_colon_completions &>/dev/null; then
        __ltrim_colon_completions "$cur";
    fi;
}
# Register completion function for ollama command
complete -F _ollama_completions ollama
```

