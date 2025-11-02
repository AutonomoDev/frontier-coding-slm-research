Thinking...
Alright, I need to create a bash-completion script for the command `ollama run <model>`. The goal is to dynamically list available models by parsing the output of `ollama list`. Let me break down the requirements and figure out how to approach this.

First, the trigger condition: the completions should only appear when the user types `ollama run` and is trying to complete after the `run` part. So, I'll need to check if the previous word in the command is exactly `run`. This can be done by checking the third element in `COMP_WORDS` because the index starts at 0. For example, if the command is `ollama run model`, then `COMP_WORDS[2]` is `model`, and we want to trigger when the user is at the position where they're typing after `run`.

Next, retrieving the models: I need to call `ollama list` once and capture its output. The output could be either one line with model names separated by whitespace or multiple lines each containing a single model name. Since I can't use external tools like jq or awk, I'll have to rely on Bash built-ins. So, I'll store the output in a variable using command substitution, like `models=$(ollama list)`.

Now, handling both cases of the output format. If it's one line with space-separated models, I can split the string into an array using `IFS=' '` which splits on spaces. If it's multiple lines, each line is a model name, so splitting by newlines would work better. So, perhaps I should first check if the output contains spaces and then decide how to split it. Alternatively, I can read each word from the output regardless of whitespace or newlines using `read -a models` which splits on any whitespace.

Wait, but `read -a` reads until EOF, so for a multi-line output, that might not capture all lines. Hmm, perhaps a better approach is to use `tr '\n' ' '` to replace newlines with spaces and then split into an array using `IFS=' '`. That way, regardless of the original format, I can get all model names in the array.

Once I have the models in an array, I need to filter them based on the current word being completed. The current word is available via `$COMP_WORDS[$COMP_CWORD]`, but since we're completing after `run`, which is at index 2, the next word is at index 3. Wait no, actually, when the user types `ollama run <tab>`, `COMP_CWORD` would be pointing to the position after `run`. So, in this case, the previous word is `run` (index 2), and we're completing the next part. So, the current word being completed is at index 3? Or maybe I need to consider that `run` is the last word before the completion. Let me think: when you type `ollama run <tab>`, `COMP_WORDS` would be [0] ollama, [1] run, and [2] is where the cursor is. So, the current word being completed is at index 2. Therefore, the prefix is `$COMP_WORDS[2]`.

Wait no, in bash completion, `COMP_CWORD` gives the index of the current word in `COMP_WORDS`. When you have a command like `ollama run model`, and you're completing after `run`, the words are [0]=ollama, [1]=run, [2]=model. So when you press tab, `COMP_CWORD` is 2, and `model` is being completed.

But in our case, since we want to trigger only after `run`, perhaps we should check if `COMP_WORDS[1]` is 'run' and the current position is after that. Alternatively, maybe it's better to check if the previous word is 'run', which would be when `COMP_CWORD` is greater than 2 or something. Hmm, perhaps I'm overcomplicating.

The key point is that the completion should only happen when the command starts with `ollama run`. So in the function, I can get the current word being completed as `$COMP_WORDS[$COMP_CWORD]`, which would be the position after 'run'. But to ensure we're in the correct context, perhaps the function should check if the previous word is 'run'.

Wait, no. The `complete` command will trigger this function every time a completion is attempted for `ollama`. So I need to make sure that the function only adds completions when the current word is the third word (after ollama and run). Alternatively, perhaps it's better to have the function handle any context where the second word is 'run'.

But according to the requirements, the trigger condition is only when the command is `ollama run` and the user is completing after `run`. So in terms of the completion function, this means that when the last word is being completed, it's supposed to be the model name.

So perhaps inside the function, I can check if `COMP_WORDS[1]` is 'run' or something like that. Wait, no, because the command could have more words after run, but in this case, the structure is ollama run <model>.

Alternatively, maybe we don't need to do any checking beyond knowing that it's for the third word (ollama, run, model). So perhaps the function can proceed as follows: when completing `ollama`, if the command is `ollama run ...`, then this function should generate completions based on the models.

Wait, but the completion function is attached to `ollama` via `complete -F`. So every time a word following `ollama` is being completed, this function will be called. But we only want it to provide completions when the second word is 'run'. Hmm.

Alternatively, perhaps the function can check if the previous word (i.e., `COMP_WORDS[1]`) is 'run', and then proceed. Otherwise, do nothing.

Wait, no. Because in that case, for a command like `ollama someothercommand`, it would not be triggered because `COMP_WORDS[1]` isn't 'run'. So perhaps the function should check if the previous word is 'run' only when we're at the position after 'run'.

Alternatively, maybe I can structure it so that the completion happens for any command where the last part is `run`, but that might not be necessary.

Wait, perhaps a better approach: in the completion function, get all the words up to the current point. If the last word is 'run', then we need to provide completions based on models. Otherwise, do nothing. But how?

Wait, maybe I should think differently. The function will be called whenever any part of `ollama` command is being completed. So for example, when the user types `ollama r`, it's not run yet, so perhaps no completion. When they type `ollama run <tab>`, then the word after 'run' is where the completion happens.

So in the function, I can check if `COMP_WORDS[1]` is 'run', meaning that the second word is 'run'. So for example, in `ollama run model`, the words are [0]=ollama, [1]=run, [2]=model. When completing at position 2 (the current word), `COMP_CWORD` would be 2.

Wait, no, because when you're typing `run`, the previous word is 'ollama', and the next completion is after 'run'. So perhaps in that case, the function needs to check if the second word is 'run'.

Alternatively, maybe I should just proceed under the assumption that the function is only called for the third word. Hmm.

But perhaps the best way is to have the function always execute when completing `ollama` commands, but only provide models if the previous word is 'run'. So inside the function:

if [ "${COMP_WORDS[1]}" = "run" ]; then
    # proceed with model completion
else
    return
fi

But wait, what about cases where there are more than two words? For example, `ollama run foo bar`, and the user is completing 'bar'—that's not intended. So perhaps we should only trigger when the current word is the third word (after ollama and run). Therefore, in the function, check if `COMP_CWORD` equals 2, meaning that we're at the position after 'run'.

Alternatively, because in bash completion, `COMP_CWORD` is zero-based. So for the command `ollama run`, when you type `<tab>` after `run`, `COMP_WORDS` would be [0]=ollama, [1]=run, and `COMP_CWORD` is 2 (since it's the position where the next word is being completed). Wait, no—when you have a command like `ollama run<tab>`, the words array is [0]=ollama, [1]=run. The current word index is 2, which is an empty string or undefined? Or perhaps I'm misunderstanding.

Wait, maybe it's better to think in terms of how many words are present when the completion is triggered. For example:

- When you type `ollama run<tab>`, the command line has two words: ollama and run. The next word (third position) is being completed, so `COMP_CWORD` would be 2.

So in this case, the function should generate completions for models when `COMP_WORDS[1]` is 'run' and we're at `COMP_CWORD` 2.

Alternatively, perhaps I can just proceed to check if the previous word is 'run', regardless of position. Because if someone types `ollama run something else`, then the completion for 'else' isn't a model name, but in our case, the third word should be the model.

Wait, this is getting complicated. Maybe it's better to capture all model names and when the previous word is 'run', provide the model completions.

So, inside the function:

# Get the models
models=$(ollama list)

if [ $? -ne 0 ]; then
    # ollama list failed; return nothing
    return 1
fi

# Split into array. First, replace newlines with spaces to handle any format
models_array=( $(echo "$models") )

# Get the current word being completed
current_word=$COMP_WORDS[$COMP_CWORD]

# Check if previous word is 'run'
if [ "${COMP_WORDS[1]}" = "run" ]; then
    # Filter models starting with current_word
    matches=()
    for model in "${models_array[@]}"; do
        if [[ "$model" == "$current_word"* ]]; then
            matches+=("$model")
        fi
    done

    # Sort the matches alphabetically
    IFS=$'\n' sorted_matches=($(sort <<<"${matches[*]}"))
    unset IFS

    # Set COMPREPLY with the sorted matches
    COMPREPLY=( "${sorted_matches[@]}" )

else
    # Not in 'run' context; return nothing
    return 1
fi

Wait, but in bash, when you have `for model in $(ollama list)`, it's splitting on any whitespace, including newlines. So perhaps using the array approach is better.

But I think using `echo "$models"` ensures that newlines are treated as spaces, so all models are correctly split into the array.

Another thing to consider: if `ollama list` outputs nothing or fails, we should return early and not set any completions.

Also, for prefix filtering, we need to make sure that each model starts with the current word. Using `[[ "$model" == "$current_word"* ]]` does that.

But wait, what about case sensitivity? The problem statement doesn't specify, so I'll assume it's case-sensitive as per usual shell behavior.

Now, putting this all together into a function:

ollama_models() {
    local models current_word

    # Retrieve the list of models
    models=$(ollama list)
    if [ $? -ne 0 ]; then
        return 1
    fi

    # Split models into an array; handle any whitespace as separator
    models_array=( $(echo "$models") )

    # Get the current word being completed
    current_word=$COMP_WORDS[$COMP_CWORD]

    # Check if we're completing after 'run'
    if [ "${COMP_WORDS[1]}" = "run" ]; then
        # Filter models that start with the current word
        matches=()
        for model in "${models_array[@]}"; do
            [[ "$model" == "$current_word"* ]] && matches+=("$model")
        done

        # Sort the matches alphabetically
        IFS=$'\n' sorted_matches=($(sort <<<"${matches[*]}"))
        unset IFS

        # Set COMPREPLY to the sorted matches
        COMPREPLY=( "${sorted_matches[@]}" )
    else
        return 1
    fi
}

Then, in the complete command:

complete -F ollama_models ollama

Wait, but that would attach this function to all completions for `ollama`, which is what we want.

But wait, when you type `ollama run <tab>`, the `COMP_WORDS` array will have [0] = ollama, [1] = run, and the current word index is 2 (the position after 'run'). So in that case, the code checks if `COMP_WORDS[1]` is 'run' and proceeds.

However, what about when the user has already typed more words? For example, `ollama run model <tab>`. In this case, `COMP_WORDS[2]` is 'model', and `COMP_CWORD` is 3. But since we're checking `COMP_WORDS[1]`, which is 'run', it would still trigger the function, but `current_word` would be whatever is after 'model', which might not be a model name.

Wait no, because in that case, when completing at position 3 (after 'model'), the previous words are ollama, run, model. So the function would think we're completing the fourth word, and since `COMP_WORDS[1]` is 'run', it would proceed to try to complete with models, which isn't correct.

Hmm, that's a problem. Because after `ollama run model`, the next completion should not be for models again. So the trigger condition should only apply when the current position is directly after 'run'.

Therefore, perhaps we need to ensure that `COMP_CWORD` is 2 (meaning the third word) and `COMP_WORDS[1]` is 'run'. Because in that case, the user is typing after 'run', which is where the model name should go.

So adjusting the condition:

if [ "${COMP_WORDS[1]}" = "run" ] && [ $COMP_CWORD -eq 2 ]; then
    # proceed with model completion
else
    return 1
fi

This way, only when the user is completing the third word (position 2) after 'run' in `ollama run` will the completions be provided.

Wait, but what about commands where `run` is not the second word? For example, `ollama othercommand`, which shouldn't trigger this function. So by checking that `COMP_WORDS[1]` is 'run' and `COMP_CWORD` is 2, we ensure it's only for the case when the user is typing after `run`.

So in the function:

if [ "${COMP_WORDS[1]}" = "run" ] && [ $COMP_CWORD -eq 2 ]; then
    # proceed with model completion
else
    return 1
fi

But wait, what if the command has more than three words? For example, `ollama run --option`. In that case, `COMP_WORDS[3]` would be '--option' and `COMP_CWORD` would be 3. So in this case, the function wouldn't trigger because `COMP_CWORD` is not 2.

But in reality, `ollama run` expects the model as the third argument, so any options after that are part of the command, not model names. Therefore, the completions should only be available when completing the third word (position 2) after 'run'.

Thus, this condition seems correct.

Putting it all together:

The function will check if `COMP_WORDS[1]` is 'run' and `COMP_CWORD` is 2. If so, proceed to fetch models and provide completions. Otherwise, do nothing.

Now, considering the output format: the script should be a bash-completion function attached with `complete`, and include in-line comments explaining key parts.

So, writing the final script:

The function will start by capturing the models into a variable. If that fails, return. Then split into an array, then check if we're in the correct context (after 'run' at position 2). Then filter the models based on the current word, sort them, and set `COMPREPLY`.

Including comments for each step.

Finally, the installation instructions: save the script to a file like `/etc/bash_completion.d/ollama` or `~/.bash_completion`, ensuring it's sourced correctly. But for simplicity, the user can source their .bashrc after adding the function.

But in the final answer, the script should include all necessary parts.

Wait, but how does bash handle functions in completion scripts? The function needs to be defined before the `complete` command is processed. So the correct approach is to define the function and then attach it with `complete`.

So the full script would look like:

# Function to provide model completions for 'ollama run'
ollama_models() {
    local models current_word

    # Retrieve the list of models
    models=$(ollama list)
    if [ $? -ne 0 ]; then
        return 1
    fi

    # Split models into an array; handle any whitespace as separator
    models_array=( $(echo "$models") )

    # Get the current word being completed
    current_word=$COMP_WORDS[$COMP_CWORD]

    # Check if we're completing after 'run'
    if [ "${COMP_WORDS[1]}" = "run" ] && [ $COMP_CWORD -eq 2 ]; then
        # Filter models that start with the current word
        matches=()
        for model in "${models_array[@]}"; do
            [[ "$model" == "$current_word"* ]] && matches+=("$model")
        done

        # Sort the matches alphabetically
        IFS=$'\n' sorted_matches=($(sort <<<"${matches[*]}"))
        unset IFS

        # Set COMPREPLY to the sorted matches
        COMPREPLY=( "${sorted_matches[@]}" )
    else
        return 1
    fi
}

# Attach the function to 'ollama' command completions
complete -F ollama_models ollama

This should be added to the user's bash configuration, such as ~/.bashrc.

Now, checking if this covers all cases:

- When `ollama run` is typed and <tab> is pressed: models are shown.
- When more than one model exists with the same prefix: sorted correctly.
- If `ollama list` fails: no completions provided.
- In other contexts (not after 'run' or not at position 2): no completions.

This should fulfill all the requirements.
...done thinking.

To enable autocompletion for model names when using the command `ollama run`, you can add a bash completion function to your system. Here's how you can do it:

### Step-by-Step Explanation

1. **Create a Bash Completion Function**:
   - Define a function `ollama_models` that retrieves the list of models using `ollama list`.
   - Check if the command is in the context of `ollama run` and if the current position is after typing `run`.
   - Filter the model names based on the current input and sort them alphabetically.
   - Set the completions for the `ollama` command.

2. **Install the Completion Function**:
   - Add the function to your shell initialization file (e.g., `~/.bashrc`).
   - Ensure the function is sourced correctly by restarting your shell or running `. ~/.bashrc`.

3. **Use the Completion Feature**:
   - After setting up, type `ollama run <tab>` and the shell will provide available model completions.

### Code Solution

```bash
# Function to provide model completions for 'ollama run'
ollama_models() {
    local models current_word

    # Retrieve the list of models
    models=$(ollama list)
    if [ $? -ne 0 ]; then
        return 1
    fi

    # Split models into an array; handle any whitespace as separator
    models_array=( $(echo "$models") )

    # Get the current word being completed
    current_word=$COMP_WORDS[$COMP_CWORD]

    # Check if we're completing after 'run'
    if [ "${COMP_WORDS[1]}" = "run" ] && [ $COMP_CWORD -eq 2 ]; then
        # Filter models that start with the current word
        matches=()
        for model in "${models_array[@]}"; do
            [[ "$model" == "$current_word"* ]] && matches+=("$model")
        done

        # Sort the matches alphabetically
        IFS=$'\n' sorted_matches=($(sort <<<"${matches[*]}"))
        unset IFS

        # Set COMPREPLY to the sorted matches
        COMPREPLY=( "${sorted_matches[@]}" )
    else
        return 1
    fi
}

# Attach the function to 'ollama' command completions
complete -F ollama_models ollama
```

### Explanation

- **Function `ollama_models`**:
  - Fetches available models using `ollama list`.
  - Splits the output into an array, handling any whitespace.
  - Checks if the current context is after typing `run` and at the correct position.
  - Filters model names starting with the current input and sorts them.

- **Completion Setup**:
  - The `complete` command links the function to the `ollama` command, enabling autocompletion in shell sessions.

This setup enhances productivity by providing intelligent completions for model names when using the `ollama run` command.

