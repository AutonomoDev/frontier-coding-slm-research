#Thinking...
#Alright, I need to create a bash completion script for the `ollama run` command. Let's break down what's required and how to approach this step by step.
#
#First, the core requirement is that when the user types `ollama run` followed by a tab, it should suggest available model names. The models are obtained by running `ollama list`, whose output includes headers and model details.
#
#I'll start by ensuring that the completion only triggers when the second word after `ollama` is exactly `run`. So, I'll check if `${COMP_WORDS[1]}` equals `run`. If not, there's nothing to do here.
#
#Next, I need to parse the output of `ollama list`. The script should skip the header line and extract only the model names from the first column. Using `awk` or `cut` is suggested, but since awk might not be allowed (depending on the setup), maybe using `sed` and `cut` would be better.
#
#I'll capture the output of `ollama list`, remove the first line (header), and then extract the first field from each remaining line. This will give me all model names.
#
#Then, I need to filter these models based on what the user is typing. For example, if they've typed 'co', only models starting with 'co' should appear. So, I'll take the current word being completed (from `COMP_WORDS[COMP_CWORD-1]`), and match each model name against it.
#
#I must ensure that the suggestions are unique, so I'll use `sort -u` to eliminate duplicates.
#
#Also, if there's no matching model names, the script should provide no suggestions. No fallback to filenames or anything else.
#
#Now, structuring the script:
#
#1. Check if the command is `ollama run`. If not, return.
#2. Get the list of models by running `ollama list` and parsing the output.
#3. Extract the current word being completed.
#4. Filter model names that start with the current word.
#5. Sort and suggest these filtered names.
#
#I should also handle cases where `_get_comp_words_by_ref` isn't available, so I'll manually set `cur` and `prev` using `COMP_WORDS` and `COMP_CWORD`.
#
#Putting it all together, the script will:
#
#- Verify the command is `run`.
#- Fetch model names.
#- Filter based on the user's input.
#- Generate unique suggestions.
#
#I need to make sure that each step is correctly implemented, especially handling cases where commands are not available or outputs vary. Testing with different scenarios (like typing 'l', 'co', or non-matching strings) will ensure it works as expected.
#...done thinking.

# Bash completion script for ollama run command

# Check if we're completing the second word after "ollama", which should be "run"
if [[ ${COMP_WORDS[1]} != "run" ]]; then
    return
fi

# Get the current word being completed (the model name prefix)
cur=${COMP_WORDS[COMP_CWORD-1]}

# Run ollama list and extract only model names, skipping headers
models=$(ollama list | sed '1d' | cut -d$'\t' -f1)

# Generate completion suggestions based on the current word
completions=$(echo "$models" | grep "^${cur}")

# Output unique suggestions, sorted alphabetically
COMPREPLY=( $( echo "$completions" | sort ) )

# No duplicate suggestions
COMPREPLY=( $( echo "${COMPREPLY[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ') )

# Bash completion script for ollama run command

# Check if the current command is "ollama" and second word is "run"
if [[ ${COMP_WORDS[1]} != "run" ]]; then
    return
fi

# Get the list of available models from ollama list, skipping headers and extracting names only
models=$(ollama list | sed '1d' | cut -d$'\t' -f1)

# If no model matches, exit with no completions
if [[ "$cur" != "" ]]; then
    # Filter models that start with the current word being typed
    completions=$(echo "$models" | grep "^${cur}")
else
    completions="$models"
fi

# Output unique suggestions, sorted alphabetically and removing duplicates
COMPREPLY=( $( echo "$completions" | sort -u ) )

