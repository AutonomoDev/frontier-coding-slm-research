#Thinking...
#Okay, I need to create a Bash completion script for the `ollama run` command. The goal is to provide autocompletion suggestions for model names when the user types `ollama run` and presses TAB. Let's break down the requirements step by step.
#
#First, the script must only activate when the second word after `ollama` is exactly `run`. So I need to check if `COMP_WORDS[1]` equals "run". If not, do nothing.
#
#Next, I have to parse the output of `ollama list` to get the model names. The command outputs a table where each line starts with the model name in the first column. I'll use `awk '{print $1}'` to extract the first field from each line except the header (which starts with "NAME"). So, running `ollama list | awk 'NR>1 {print $1}'` should give me all the model names.
#
#Then, when the user is typing after `run`, I need to filter these model names based on what they've typed so far. For example, if they type "co", only models starting with "co" should appear. So I'll take the last word being completed, which is in `COMP_WORDS[COMP_CWORD-1]` (since we're completing after `run`), and use it to filter the model list.
#
#I also need to make sure there are no duplicates, so using `unique` on the filtered list would help. Additionally, if nothing matches, the script shouldn't suggest filenames or anything else—it should just provide no suggestions.
#
#Putting this together, the script will:
#
#1. Check if the command is `ollama` and the second word is `run`.
#2. Run `ollama list`, extract model names.
#3. Filter these models based on the user's input.
#4. Set `COMPREPLY` with the filtered list, ensuring uniqueness.
#
#I should structure the script within a `complete -F` block to use the Bash completion framework correctly. Also, using `[[ ${COMP_WORDS[1]} == "run" ]]` ensures we only trigger for the right command context.
#
#Now, let's write the code step by step:
#
#- Use `complete -F _ollama_run_completion ollama` to define the function.
#- The function `_ollama_run_completion` will handle the logic.
#- Inside the function, check if the second word is "run".
#- Get model names with `ollama list | awk ...`.
#- Extract the input string being completed from `COMP_WORDS[COMP_CWORD]`.
#- Filter models starting with that string.
#- Set `COMPREPLY` to the unique results.
#
#I think I've covered all points, ensuring compliance with Bash completion standards and avoiding common pitfalls like suggesting filenames or infinite loops.
#...done thinking.

# bash-completion script for ollama run command
complete -F _ollama_run_completion ollama

_ollama_run_completion()
{
    # Only trigger when the second word is exactly 'run'
    if [[ ${COMP_WORDS[1]} != "run" ]]; then
        return
    fi

    # Get model names from ollama list output (excluding header)
    local models=$(ollama list | awk 'NR>1 {print $1}')

    # Filter models based on the word being completed
    local input=${COMP_WORDS[COMP_CWORD-1]}
    local completions=($(echo "$models" | grep "^${input}"))

    # Set unique suggestions
    COMPREPLY=( $(printf "%s\n" "${completions[@]}" | sort -u) )
}
