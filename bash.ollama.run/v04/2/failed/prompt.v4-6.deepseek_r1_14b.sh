#Thinking...
#Okay, I need to create a Bash completion script for the `ollama run` command. The goal is when someone types `ollama run` and presses Tab, it should suggest available models based on what they've typed so far.
#
#First, let me understand the requirements. The script must only activate when the second word after 'ollama' is 'run'. So I'll check if ${COMP_WORDS[1]} equals 'run'.
#
#Next, I need to parse the output of `ollama list`. This command gives a table with model names, IDs, sizes, etc. The first column has the model names, like 'llama3:latest'. I should extract these names, skipping the header.
#
#I'll run `ollama list` and process its output. Using `awk '{print $1}'` seems efficient because it will take the first field of each line. But I need to skip the first line which is the header starting with 'NAME'.
#
#Then, for filtering, when the user types something like 'co', only models starting with that string should appear. So I'll compare each model name against the typed part and suggest those that match.
#
#I must ensure no filename fallback happens. If nothing matches, provide no suggestions. Also, avoid duplicates by using `sort -u` or checking before adding to COMPREPLY.
#
#Now, structuring the script: It should be a function called _ollama_run which is triggered when 'run' is the second word. The script will execute ollama list, parse the names, filter them based on the current word, and set COMPREPLY with the results.
#
#Testing scenarios: When typing just Tab, all models are listed. When typing part of a model name, only matching ones appear. If nothing matches, no output.
#
#Potential issues to consider: What if `ollama list` isn't available? But since it's part of the command, assuming it's installed correctly.
#
#I'll structure the script step by step:
#
#1. Check if the second word is 'run'. If not, return.
#2. Get the current word being completed (COMP_CURRENT).
#3. Run ollama list and extract model names, skipping the header.
#4. Filter these names to match those starting with COMP_CURRENT.
#5. Set COMPREPLY with the filtered list.
#
#I'll make sure all variables are correctly referenced and that only standard bash is used without any unnecessary functions.
#...done thinking.

# Bash completion script for `ollama run` command
# This script provides autocompletion for model names when typing `ollama run`

complete -F _ollama_run ollama

function _ollama_run() {
    # Only trigger if the word being completed is exactly 'run' (second word)
    if [[ ${COMP_WORDS[1]} != "run" ]]; then
        return
    fi

    # Get the current word being typed
    local cur="${COMP_WORDS[COMP_CWORD-1]}"
    
    # Extract model names from ollama list output, skipping header
    local models=$(ollama list | tail -n +2 | awk '{print $1}')

    # Filter models based on the current word
    local suggestions=$(echo "$models" | grep "^${cur}")

    # Set the completion results
    COMPREPLY=($(printf "%s\n" "$suggestions"))
}
