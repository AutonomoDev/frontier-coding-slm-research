#Thinking...
#Okay, I need to create a Bash completion script for the `ollama run` command. Let's break down what needs to be done based on the user's requirements.
#
#First, the script should only activate when the user types `run` as the subcommand after `ollama`. So, I'll check if the first word is `ollama` and the previous word is exactly `run`.
#
#Next, I need to parse the output of `ollama list` to get the model names. The command's output has a header starting with `NAME`, which I should skip. Each subsequent line has the model name in the first column. I'll use `cut -d$'\t' -f1` to extract that column, but wait, looking at the sample output, each line is separated by spaces and tabs. Hmm, maybe using `awk` would be more reliable since it can handle multi-space columns better.
#
#I should extract only the model names. So for each line after the header, I'll take the first field. Also, need to make sure that if there are no models, the script doesn't suggest anything.
#
#Then, when the user starts typing something after `run`, like 'co', I need to filter the model list to show only those starting with 'co'. So, I'll use the current word being typed (COMP_CURRENT) and match each model name against it using a case-insensitive comparison. Wait, but in the example, the completion is case-sensitive as per the output.
#
#Wait, no, in the sample, when user types 'cod', the models suggested are 'codellama:17b' and 'codellama:32b'. So, the match is on the model name starting with the current word. I'll need to filter the model names that start with the current string.
#
#But how do I get the current string? It's stored in `COMP_CURRENT`, but sometimes it might be better to use `CUR` variable, which could be set by `_get_comp_words_by_ref`.
#
#Wait, according to the user's note, I should use standard variables like COMP_WORDS and COMP_CWORD. So perhaps I should avoid using _get_comp_words_by_ref unless necessary.
#
#Alternatively, if I can use _get_comp_words_by_ref, it simplifies getting cur and prev. But I need a fallback in case it's not available.
#
#Wait, the user specified that if `_get_comp_words_by_ref` is missing or fails, I should manually set `cur` and `prev`. So, first, I'll try to use _get_comp_words_by_ref, but check if it's present. If not, extract the words from COMP_WORDS and set cur and prev accordingly.
#
#So in the script, I'll start by checking if the command is `run`, then get the current word being completed.
#
#Then, I need to parse the models. So, run `ollama list` and process its output. For each line after the header, extract the first column as the model name.
#
#Once I have all the model names in an array, say models, I can filter them based on the current word.
#
#The filtering should be case-sensitive? Well, looking at the example, when user types 'co', it matches 'codellama' which starts with lowercase. So perhaps the match is exact as per the output.
#
#Wait, no: model names are in lowercase, and if the user types 'Co', would it still match? Probably not unless specified otherwise, but the requirement says to filter based on what's being typed. So I'll do a case-sensitive comparison.
#
#So, for each model name in models, check if it starts with the current word. If so, add it to suggestions.
#
#Then, make sure that the suggestions are unique and sorted. The examples show them in order as per `ollama list`, but when completing, perhaps they should be sorted alphabetically? Or maintain the order from ollama list?
#
#Wait, no: in the first example, after 'run', all models are suggested in the order they appear. But for a partial match like 'co', only the matching ones are shown.
#
#But in Bash completions, suggestions are typically sorted. Looking at the examples:
#
#When user types `ollama run co<TAB>`, the output is `codellama:17b` and `codellama:32b`. So perhaps the order doesn't matter as long as all matches are present.
#
#But to be safe, I'll sort them alphabetically for consistency.
#
#Wait, in the example when user types 'l', only 'llama3:latest' is suggested. That's correct because it's the first model.
#
#So maybe the order isn't a concern, but just ensuring that all matching models are included without duplicates.
#
#Now, steps to implement:
#
#1. Check if the command starts with `ollama run`. So, in the completion function, check if COMP_WORDS[0] is 'ollama' and COMP_WORDS[COMP_CWORD-1] is 'run'. Because when completing after 'run', the previous word is 'run'.
#
#Wait, no: let's think about it. The command line could be like 'ollama run model...', so COMP_CWORD would be 2 (0-based index?), or maybe not.
#
#Actually, in the completion function, when the user is at the position where they're typing after 'run', COMP_WORDS[COMP_CWORD] would be the current word being completed. So, the previous word is at COMP_CWORD -1, which should be 'run'.
#
#Wait, perhaps better to think of it as: if the current word's index is such that the previous word is 'run' and the first word is 'ollama', then proceed.
#
#So in code:
#
#if [[ ${COMP_WORDS[0]} != "ollama" || ${COMP_WORDS[${COMP_CWORD}-1]} != "run" ]]; then
#    return
#fi
#
#This ensures that the command is `ollama run` followed by something, and we're completing on the third word (the model name).
#
#Next, get the current string being completed, which is in COMP_CURRENT. Or wait: maybe it's better to use _get_comp_words_by_ref to get CUR and PREV.
#
#Wait, but I can't rely on _get_comp_words_by_ref because it's not available in all environments. So, perhaps the safest way is to extract the current word being completed as $COMP_WORDS[$COMP_CWORD], or if that's empty, perhaps use other variables.
#
#Alternatively, let me try:
#
## Get the current and previous words
#cur="${COMP_WORDS[${COMP_CWORD}]}"
#prev="${COMP_WORDS[${COMP_CWORD}-1]}"
#
#if [[ "$prev" != "run" || "$COMP_WORDS[0]" != "ollama" ]]; then
#    return 0
#fi
#
#But wait, if COMP_CWORD is the index of the current word. For 'ollama run model', when completing on 'model', COMP_CWORD would be 2 (assuming 0-based). So yes.
#
#So in that case, prev is 'run'.
#
#Once that's confirmed, proceed to generate the suggestions.
#
#Now, parse the models:
#
#Run `ollama list` and read each line. For each line after the header, extract the first column as model name.
#
#In code:
#
#models=()
#while IFS=$'\n' read -r line; do
#    # Skip the header
#    if [[ "$line" == "NAME"* ]]; then
#        continue
#    fi
#    # Extract the first field (model name)
#    model=$(awk '{print $1}' <<< "$line")
#    models+=("$model")
#done < <(ollama list)
#
#Wait, but using `cut` is recommended. So maybe:
#
#models=()
#while IFS=$'\n' read -r line; do
#    if [[ "$line" == "NAME"* ]]; then
#        continue
#    fi
#    model=$(echo "$line" | cut -d$'\t' -f1)
#    models+=("$model")
#done < <(ollama list)
#
#Wait, but the output might have spaces or tabs in between. Looking at the sample output:
#
#The first line is NAME followed by other columns, which may include multiple spaces and then tab.
#
#Alternatively, perhaps using `awk '{print $1}'` would be better to get the first column regardless of separators.
#
#So in code:
#
#models=()
#while IFS=$'\n' read -r line; do
#    if [[ "$line" == "NAME"* ]]; then
#        continue
#    fi
#    model=$(echo "$line" | awk '{print $1}')
#    models+=("$model")
#done < <(ollama list)
#
#Yes, this should extract the first column correctly.
#
#Once I have the models array, I need to filter it based on the current word being completed (cur).
#
#So:
#
#suggestions=()
#for model in "${models[@]}"; do
#    if [[ "$model" == "$cur"* ]]; then
#        suggestions+=("$model")
#    fi
#done
#
#But wait, cur could be empty. If the user just types `ollama run` and presses tab, cur is an empty string, so all models should be suggested.
#
#So in that case, the condition would include all models because any model starts with empty string.
#
#Then, we need to make sure the suggestions are unique. But since ollama list outputs each model once, the models array shouldn't have duplicates. But perhaps it's safer to process them through `sort -u` or something similar.
#
#Wait, but in this case, the models are being read in order from ollama list, so duplicates would be unlikely unless there are duplicate names, which I assume isn't possible.
#
#But to ensure uniqueness, we can use an associative array or sort and uniq:
#
#suggestions=($(printf "%s\n" "${models[@]}" | grep "^${cur}" | sort))
#
#Wait, but this could be done with:
#
#suggestions=$(printf '%s\n' "${models[@]}" | grep -x "^$cur" | sort)
#
#But perhaps it's better to loop through and check for each model.
#
#Another approach: in the loop, add the model to suggestions only if it starts with cur, then after that, make sure there are no duplicates by using `sort` and `uniq`.
#
#Wait, but even without that, the models array is built from ollama list, which shouldn't have duplicates. So perhaps not necessary.
#
#But in any case, let's proceed to collect all matching models.
#
#After collecting the suggestions, we need to output them as possible completions.
#
#In Bash completion, you set COMPREPLY to an array of possible completions.
#
#So:
#
#COMPREPLY=($(printf '%s\n' "${models[@]}" | grep "^${cur}" | sort))
#
#Wait, but this is a string with newlines. To capture it correctly, perhaps better to process each model and add if starts with cur.
#
#But in the code earlier, I have the loop that builds suggestions. So after building the suggestions array, which may be empty or have multiple entries, we can set COMPREPLY to it.
#
#So:
#
#COMPREPLY=("${suggestions[@]}")
#
#Wait, but when using `printf` and `grep`, perhaps an alternative is better.
#
#Alternatively, use a process substitution to read the models and filter them.
#
#But regardless, after generating suggestions, set COMPREPLY.
#
#Putting it all together.
#
#Now, think about the function structure:
#
#The completion function is called _ollama_run.
#
#So, in the script:
#
#complete -F _ollama_run ollama
#
#And then define the function.
#
#Inside the function:
#
#Check if the previous word is 'run' and first word is 'ollama'.
#
#If not, return 0 (no completions).
#
#Else, parse the models from ollama list.
#
#Filter based on current word (cur), which could be empty.
#
#Then set COMPREPLY to the filtered model names.
#
#So, code outline:
#
#function _ollama_run {
#    local cur prev
#    # Get words around the cursor using _get_comp_words_by_ref if available
#    if command -v _get_comp_words_by_ref &> /dev/null; then
#        _get_comp_words_by_ref -c cur -p prev || return 0
#    else
#        # Fallback to manual extraction
#        local cword="${COMP_CWORD}"
#        cur="${COMP_WORDS[$cword]}"
#        if [[ "$cword" -gt 0 ]]; then
#            prev="${COMP_WORDS[$cword-1]}"
#        else
#            prev=""
#        fi
#    fi
#
#    # Check if the command is 'ollama run ...'
#    if [[ "${COMP_WORDS[0]}" != "ollama" || "$prev" != "run" ]]; then
#        return 0
#    fi
#
#    # Get available models from ollama list
#    local models=()
#    while IFS=$'\n' read -r line; do
#        if [[ "$line" == "NAME"* ]]; then
#            continue
#        fi
#        model=$(echo "$line" | awk '{print $1}')
#        models+=("$model")
#    done < <(ollama list)
#
#    # Filter models based on current word
#    local suggestions=()
#    for model in "${models[@]}"; do
#        if [[ "$model" == "$cur"* ]]; then
#            suggestions+=("$model")
#        fi
#    done
#
#    # Set the completions
#    COMPREPLY=( $(printf '%s\n' "${suggestions[@]}" | sort) )
#}
#
#Wait, but when using `COMPREPLY`, it's better to have an array of strings. So, after collecting suggestions, perhaps we can sort them and assign.
#
#But in the code above, I used `sort` with a pipeline, which would output each suggestion on separate lines. Then, putting into COMPREPLY as an array.
#
#Alternatively:
#
#suggestions=$(printf '%s\n' "${models[@]}" | grep "^${cur}" | sort)
#COMPREPLY=( $suggestions )
#
#Wait, but in the function, `suggestions` is a variable with newlines, so when we do `$(...)`, it splits into an array correctly?
#
#Hmm, perhaps better to process as:
#
#COMPREPLY=()
#while IFS=$'\n' read -r suggestion; do
#    COMPREPLY+=("$suggestion")
#done < <(printf '%s\n' "${models[@]}" | grep "^${cur}" )
#
#Wait, that's more efficient.
#
#Alternatively, let's process the models and only include those starting with cur:
#
#COMPREPLY=( $(printf '%s\n' "${models[@]}" | grep "^$cur" ) )
#
#But this could include duplicates if any, but as discussed earlier, it's unlikely.
#
#So in code:
#
## Filter the models based on current word
#filter_models() {
#    local cur="$1"
#    shift
#    local model
#    for model; do
#        [[ "$model" == "$cur"* ]] && echo "$model"
#    done
#}
#
#suggestions=$( filter_models "$cur" "${models[@]}" )
#COMPREPLY=( $suggestions )
#
#But in the function, this would generate an array of suggestions.
#
#Alternatively, another approach is to build the COMPREPLY directly:
#
#COMPREPLY=()
#for model in "${models[@]}"; do
#    if [[ "$model" == "$cur"* ]]; then
#        COMPREPLY+=("$model")
#    fi
#done
#
#Yes, that's more efficient and avoids the subshell.
#
#So, putting it all together:
#
#function _ollama_run {
#    # Get current and previous words using _get_comp_words_by_ref if available
#    local cur prev
#    if command -v _get_comp_words_by_ref &> /dev/null; then
#        _get_comp_words_by_ref -c cur -p prev || return 0
#    else
#        local cword="${COMP_CWORD}"
#        cur="${COMP_WORDS[$cword]}"
#        prev=""
#        if [[ "$cword" -gt 0 ]]; then
#            prev="${COMP_WORDS[$cword-1]}"
#        fi
#    fi
#
#    # Check if the command is 'ollama run ...'
#    if [[ "${COMP_WORDS[0]}" != "ollama" || "$prev" != "run" ]]; then
#        return 0
#    fi
#
#    # Get available models from ollama list
#    local models=()
#    while IFS=$'\n' read -r line; do
#        if [[ "$line" == "NAME"* ]]; then
#            continue
#        fi
#        model=$(echo "$line" | awk '{print $1}')
#        models+=("$model")
#    done < <(ollama list)
#
#    # Filter models based on current word
#    local suggestions=()
#    for model in "${models[@]}"; do
#        if [[ "$model" == "$cur"* ]]; then
#            suggestions+=("$model")
#        fi
#    done
#
#    # Set the completions
#    COMPREPLY=( "${suggestions[@]}" )
#}
#
#Wait, but when $cur is empty (user just typed 'ollama run' and pressed tab), all models should be suggested. The condition [[ "$model" == "$cur"* ]] would match any model since anything starts with an empty string.
#
#Yes.
#
#Another consideration: ollama list could return zero or multiple models. If no models are found, COMPREPLY will be empty, which is correct.
#
#Now, test the function:
#
#When user types 'ollama run' and presses tab, cur is empty. So all models should appear.
#
#If user has started typing a model name, e.g., 'll', then only models starting with 'll' are suggested.
#
#Another test case: user types 'a' but doesn't match any model; no suggestions.
#
#Edge cases:
#
#- No models installed (ollama list is empty). Then COMPREPLY is empty.
#- Models have varying cases or special characters. Since the completion is based on shell's current word, it should handle that correctly.
#
#Potential issues:
#
#1. ollama list could fail if not found in PATH. But since we're writing a completion function for 'ollama', which presumably is installed and in PATH, this shouldn't be an issue.
#
#2. Parsing models from ollama list may have issues if the output format changes. Currently, it's using the first column. So assuming that ollama list always outputs model names as the first field.
#
#But to make sure, perhaps test with a sample output:
#
#NAME    my-model  v1
#NAME    another-model  v2
#
#Then, models would be 'my-model' and 'another-model'.
#
#Yes, correct.
#
#Another possible issue is handling empty lines or malformed lines from ollama list. But assuming that ollama list works correctly, it shouldn't output such lines.
#
#Finally, the function should return 0 if no completion is found, which it does by default.
#
#So, putting all together, the complete script would be:
#
#complete -F _ollama_run ollama
#
#function _ollama_run {
#    # Get current and previous words
#    local cur prev
#    if command -v _get_comp_words_by_ref &> /dev/null; then
#        _get_comp_words_by_ref -c cur -p prev || return 0
#    else
#        local cword="${COMP_CWORD}"
#        cur="${COMP_WORDS[$cword]}"
#        prev=""
#        if [[ "$cword" -gt 0 ]]; then
#            prev="${COMP_WORDS[$cword-1]}"
#        fi
#    fi
#
#    # Ensure we are completing on 'ollama run'
#    if [[ "${COMP_WORDS[0]}" != "ollama" || "$prev" != "run" ]]; then
#        return 0
#    fi
#
#    # Fetch available models
#    local models=()
#    while IFS=$'\n' read -r line; do
#        if [[ "$line" == "NAME"* ]]; then
#            continue
#        fi
#        model=$(echo "$line" | awk '{print $1}')
#        models+=("$model")
#    done < <(ollama list)
#
#    # Filter models based on current word
#    local suggestions=()
#    for model in "${models[@]}"; do
#        if [[ "$model" == "$cur"* ]]; then
#            suggestions+=("$model")
#        fi
#    done
#
#    # Set the completions
#    COMPREPLY=( "${suggestions[@]}" )
#}
#
#Wait, but in the 'complete' command, I used -F _ollama_run ollama. So this function will be called when completing on 'ollama'.
#
#But to make sure that it's only called when the word after 'run' is being completed.
#
#In the function, we check if the previous word is 'run' and the first word is 'ollama'. If not, return 0 (no completions).
#
#So this should correctly limit the completion to the model names only when the command is 'ollama run'.
#
#Another thought: perhaps using a different approach for getting cur and prev.
#
#But overall, this should handle most cases.
#...done thinking.

# [[HUMAN COMMENTED-OUT]]
#To solve this problem, we need to create a bash shell completion function that suggests available models when the user types `ollama run` followed by some initial characters of a model name. The function will fetch the list of available models using the `ollama list` command and provide suggestions based on the input provided by the user.
#
#### Approach
#1. **Identify the Command Context**: Ensure that the shell completion is only triggered when the user is typing after `ollama run`. This is done by checking if the previous word is "run" and the first word is "ollama".
#2. **Fetch Available Models**: Use the `ollama list` command to retrieve all available models. The output of this command is parsed to extract model names from the first column.
#3. **Filter Models Based on Input**: Check each model name to see if it starts with the current input (substring being typed by the user). Collect all such matching models as suggestions.
#4. **Set Completions**: Set the completion results so that the shell can display the suggested model names.

### Solution Code

complete -F _ollama_run ollama

function _ollama_run {
    local cur prev
    if command -v _get_comp_words_by_ref &> /dev/null; then
        _get_comp_words_by_ref -c cur -p prev || return 0
    else
        local cword="${COMP_CWORD}"
        cur="${COMP_WORDS[$cword]}"
        prev=""
        if [[ "$cword" -gt 0 ]]; then
            prev="${COMP_WORDS[$cword-1]}"
        fi
    fi

    if [[ "${COMP_WORDS[0]}" != "ollama" || "$prev" != "run" ]]; then
        return 0
    fi

    local models=()
    while IFS=$'\n' read -r line; do
        if [[ "$line" == "NAME"* ]]; then
            continue
        fi
        model=$(echo "$line" | awk '{print $1}')
        models+=("$model")
    done < <(ollama list)

    local suggestions=()
    for model in "${models[@]}"; do
        if [[ "$model" == "$cur"* ]]; then
            suggestions+=("$model")
        fi
    done

    COMPREPLY=( "${suggestions[@]}" )
}


# [[HUMAN COMMENTED-OUT]]
#### Explanation
#- **Command Context Check**: The function first checks if the command being completed is part of `ollama run`. This ensures that completions are only provided when the user is trying to specify a model after running `ollama run`.
#- **Model Extraction**: The `ollama list` command outputs all available models, and the function extracts these names from the output.
#- **Filtering Models**: Each model name is checked against the current input (`cur`). If the model name starts with the input string, it is added to the suggestions list.
#- **Completion Setup**: The valid model suggestions are set as completions so that they can be displayed by the shell when the user presses Tab.
#
#This approach efficiently narrows down the models based on the user's input and ensures that only relevant suggestions are provided, enhancing the user experience while working with the `ollama` tool.

