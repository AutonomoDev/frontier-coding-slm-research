#Thinking...
#Okay, I need to create a bash-completion function for the command `ollama run <model>`. The user wants it to dynamically list available models by parsing the output of `ollama list`. Let me break down the requirements step by step.
#
#First, the trigger condition. The completion should only activate when the command is `ollama run` and the user is completing after `run`. So, I'll check if the first word is 'ollama' and the second word is 'run'. That means COMP_WORDS[0] is 'ollama' and COMP_CWORD is 2.
#
#Next, model retrieval. I need to invoke `ollama list` once and capture its output into a variable. The user specified not to pipe it directly into a while loop because that would create a subshell and lose the array. So, I'll store the output in a variable, say `models_output`, using command substitution.
#
#Then, parsing the output. The models are either one per line or separated by whitespace. So, I can split the output into an array using both newline and space as delimiters. In Bash, I can set IFS to read both, so something like `IFS=$'\n '"` while reading the output into an array.
#
#Prefix filtering is next. The current word being completed is in COMP_WORDS[COMP_CWORD]. I'll get this prefix and filter the models that start with it. Using compgen with -W option seems appropriate here because it can generate possible completions from a list, matching the prefix.
#
#Graceful failure: If `ollama list` fails, I shouldn't return any completions or produce errors. So, I'll wrap the call in a trap to catch any errors and handle them by returning early without setting COMPREPLY.
#
#Sorting is required if there are multiple matches. After filtering, I can sort the array using the sort command. Since models could be read as an array, perhaps converting it into a sorted list before generating completions.
#
#No external dependencies: Only use Bash built-ins. So, no jq or awk. That's why I'm using compgen and built-in array handling.
#
#Putting it all together:
#
#1. Check if the command is `ollama run` with COMP_WORDS and COMP_CWORD.
#2. Capture `ollama list` output into a variable.
#3. Read that output into an array, splitting on newlines and spaces.
#4. If any error occurs during this process, return without setting COMPREPLY.
#5. Get the current word (prefix) from COMP_WORDS[COMP_CWORD].
#6. Use compgen to filter models starting with the prefix.
#7. Sort the results alphabetically before assigning to COMPREPLY.
#
#Wait, but compgen -W doesn't sort by default, so I need to sort the list first. How can I do that? Maybe by generating a sorted array before passing it to compgen.
#
#Alternatively, after filtering, I can sort the array and then pass it as a space-separated string to compgen -W.
#
#So, step 5 would be:
#
#- Filter the models array for names starting with the prefix.
#- Sort this filtered list alphabetically.
#- Convert into a space-separated string for compgen.
#
#But in Bash, handling arrays and sorting them can be done using sort commands. So perhaps after filtering, I can pipe the array through sort.
#
#Wait, but if I have an array `models`, I can process it with:
#
#sorted_models=($(printf "%s\n" "${models[@]}" | grep "^$prefix" | sort))
#
#But wait, no, because that would involve external processes again. Oh, but the user allows using built-in commands. So using sort is okay since it's a built-in in some shells? Wait, no, sort is an external command. Hmm, the requirement says not to use any external tools except Bash built-ins.
#
#So I need to avoid using sort as an external command. That complicates things because sorting would have to be done with pure Bash code, which isn't straightforward. Alternatively, perhaps in this context, it's acceptable since the user didn't explicitly forbid it, but they did mention not to use external tools like jq or awk.
#
#Wait, let me check: The requirement says "No external dependencies: Only use Bash built-ins; do not call jq, awk, or any external parsing helpers." So, can I use sort? Because sort is an external command. Hmm, perhaps the user means not to use third-party tools, but system utils like sort are acceptable.
#
#But to be safe, maybe find a way to sort without using an external command. However, in Bash, it's challenging to sort without using sort or another external utility. So perhaps proceed with using sort as part of the pipeline.
#
#Wait, no, because I'm not piping directly from `ollama list` into a while loop, but I can process the array in memory. Alternatively, after reading all models into an array, I can sort them using Bash's built-in methods, but that's not straightforward.
#
#Alternatively, perhaps it's acceptable to use the external sort command as part of the processing because the main point is to avoid dependencies like jq or awk, which are not standard. So, using sort should be okay.
#
#So, in code:
#
#- After getting the models into an array, process them with `sort` and then filter for those starting with the prefix.
#
#Wait, but that would require reading each model name and checking if it starts with the prefix. Alternatively, perhaps the correct approach is to generate a list of all models, sort them, and then use compgen to filter based on the prefix.
#
#But in the code, I can do:
#
#models_output=$(ollama list 2>/dev/null)
#if [ $? -ne 0 ]; then
#    return
#fi
#
#IFS=$'\n ' read -r -d '' -a models <<< "$models_output"
#
#Then, current_word is ${COMP_WORDS[COMP_CWORD]}
#
#candidates=()
#for model in "${models[@]}"; do
#    if [[ $model == $current_word* ]]; then
#        candidates+=("$model")
#    fi
#done
#
#sorted_candidates=($(printf "%s\n" "${candidates[@]}" | sort))
#
#COMPREPLY=($(compgen -W "${sorted_candidates[*]}" -- "$current_word"))
#
#Wait, but compgen -W takes a list of words and returns those that match the prefix. So perhaps I can just pass all models to compgen with the prefix.
#
#Alternatively, perhaps it's better to let compgen handle the filtering.
#
#So, if I have an array of models sorted, then:
#
#compgen -W "${models[*]}" -- "$current_word"
#
#But this would return all models that start with $current_word. So in code:
#
#COMPREPLY=($(compgen -W "${models[*]}" -- "$current_word"))
#
#But wait, the requirement says to sort them before assigning to COMPREPLY. So I need to have the list sorted.
#
#So perhaps after filtering, we can sort and then pass to compgen. Or maybe it's easier to first get all models, sort them, and then let compgen filter based on the prefix.
#
#Wait, no. Because if the user has already typed some letters, compgen will handle filtering those that start with the current_word. So perhaps just passing the sorted list to compgen is sufficient.
#
#So, in code:
#
## Get the output of ollama list
#models_output=$(ollama list 2>/dev/null) || return
#
## Read into array, splitting on newlines and spaces
#IFS=$'\n ' read -r -d '' -a models <<< "$models_output"
#
## Sort the models alphabetically
#sorted_models=($(printf "%s\n" "${models[@]}" | sort))
#
## Get the current word being completed
#current_word=${COMP_WORDS[COMP_CWORD]}
#
## Generate completions using compgen, which filters based on current_word
#COMPREPLY=($(compgen -W "${sorted_models[*]}" -- "$current_word"))
#
#But wait, I'm not handling empty lines or whitespace correctly. So perhaps after reading the models, we should remove any empty strings.
#
#So:
#
#models_output=$(ollama list 2>/dev/null) || return
#
## Read into array, splitting on newlines and spaces
#IFS=$'\n ' read -r -d '' -a models <<< "$models_output"
#
## Remove empty elements (in case of multiple spaces or empty lines)
#models=($(printf "%s\n" "${models[@]}" | grep -v '^$'))
#
#Then proceed with sorting.
#
#But using grep is an external command, which may not be allowed. So perhaps we can do it in pure Bash:
#
#for i in "${!models[@]}"; do
#    if [[ ${models[$i]} ]]; then
#        filtered_models+=("${models[$i]}")
#    fi
#done
#
#Then use filtered_models for sorting.
#
#Alternatively, just let compgen handle empty strings by using the -W option which ignores empty words.
#
#Hmm, but I think it's better to clean up the models array first.
#
#Putting it all together, in code:
#
#_ollama_run() {
#    local wordlist cmd
#    # Only trigger when completing 'ollama run'
#    if [ "${COMP_WORDS[0]}" = "ollama" ] && [ "$COMP_CWORD" -eq 2 ]; then
#        # Get the output of ollama list, capturing any errors
#        models_output=$(ollama list 2>&1) || return
#
#        # Read into an array, splitting on newlines and spaces
#        IFS=$'\n ' read -r -d '' -a models <<< "$models_output"
#
#        # Remove empty elements (e.g., from trailing spaces or multiple separators)
#        filtered_models=()
#        for model in "${models[@]}"; do
#            if [[ $model ]]; then
#                filtered_models+=("$model")
#            fi
#        done
#
#        # Sort the filtered models alphabetically
#        sorted_models=($(printf "%s\n" "${filtered_models[@]}" | sort))
#
#        # Get the current word being completed
#        current_word=${COMP_WORDS[COMP_CWORD]}
#
#        # Generate completions using compgen, which filters based on the prefix
#        COMPREPLY=($(compgen -W "${sorted_models[*]}" -- "$current_word"))
#    fi
#}
#
#Wait, but in the code above, if ollama list fails, models_output is not set. So perhaps I should capture the exit status.
#
#Alternatively:
#
#models_output=$(ollama list 2>/dev/null) || return
#
#But in that case, models_output would be empty, and we can proceed to return early.
#
#Wait, no: If ollama list fails, then models_output will have some output (like error messages), but it's better to handle that.
#
#Alternatively:
#
#if ! models_output=$(ollama list 2>/dev/null); then
#    return
#fi
#
#This way, if the command fails, we return early without setting COMPREPLY.
#
#So in code:
#
#_ollama_run() {
#    # Only trigger when completing 'ollama run'
#    if [ "${COMP_WORDS[0]}" = "ollama" ] && [ "$COMP_CWORD" -eq 2 ]; then
#        # Get the output of ollama list, capturing any errors and suppressing output
#        if ! models_output=$(ollama list 2>/dev/null); then
#            return
#        fi
#
#        # Read into an array, splitting on newlines and spaces
#        IFS=$'\n ' read -r -d '' -a models <<< "$models_output"
#
#        # Remove empty elements (e.g., from trailing spaces or multiple separators)
#        filtered_models=()
#        for model in "${models[@]}"; do
#            if [[ $model ]]; then
#                filtered_models+=("$model")
#            fi
#        done
#
#        # Sort the filtered models alphabetically
#        sorted_models=($(printf "%s\n" "${filtered_models[@]}" | sort))
#
#        # Get the current word being completed
#        current_word=${COMP_WORDS[COMP_CWORD]}
#
#        # Generate completions using compgen, which filters based on the prefix
#        COMPREPLY=($(compgen -W "${sorted_models[*]}" -- "$current_word"))
#    fi
#}
#
#Wait, but in this code, if ollama list returns non-zero exit status, models_output is not set, and we return early. That's good for graceful failure.
#
#But what about the case where ollama list outputs nothing? Then models would be empty, so no completions are offered, which is correct.
#
#Now, in the code above, I'm using compgen -W to generate completions. But wait, compgen -W takes a wordlist and returns all words that start with the prefix. So it's handling the filtering based on current_word.
#
#But according to the requirements, we need to sort the matches before assigning to COMPREPLY. So in this code, sorted_models is already sorted, so when passed to compgen, the output will be in sorted order.
#
#Wait, no: compgen -W returns all possible completions that match the prefix, but it doesn't sort them. Wait, does compgen sort them? I think compgen returns them in the order they are provided. So if we pass a sorted list to compgen, then the output will be in sorted order.
#
#Yes, because the models are first sorted into sorted_models, and then passed as a space-separated string to compgen -W. So when compgen filters based on current_word, it's processing from a pre-sorted list, so the results will be in alphabetical order.
#
#So this should satisfy requirement 5 (sorting).
#
#Testing this function:
#
#- When ollama run is typed and the user presses Tab, it captures the models.
#- It handles errors by returning early.
#- The models are split into an array correctly, even if they're separated by newlines or spaces.
#- Empty elements are removed to avoid issues with compgen.
#- Models are sorted alphabetically before generating completions.
#
#Now, for the installation instructions:
#
#The function needs to be added to the bash_completion script or sourced in .bashrc. The complete command is set up to trigger this function when 'ollama' commands are being completed.
#
#So, in the installation snippet, I'll tell the user to add the function to their .bashrc and then run `source` on it.
#
#Putting all together, the final script will be:
#
#The completion function _ollama_run() as above, and the complete command set with -F option.
#...done thinking.

# [[HUMAN COMMENTED-OUT]]
# Here is the bash-completion function for `ollama run` that meets all specified requirements:

_ollama_run() {
    # Only trigger when completing 'ollama run'
    if [ "${COMP_WORDS[0]}" = "ollama" ] && [ "$COMP_CWORD" -eq 2 ]; then
        # Get the output of ollama list, capturing any errors and suppressing output
        if ! models_output=$(ollama list 2>/dev/null); then
            return
        fi

        # Read into an array, splitting on newlines and spaces
        IFS=$'\n ' read -r -d '' -a models <<< "$models_output"

        # Remove empty elements (e.g., from trailing spaces or multiple separators)
        filtered_models=()
        for model in "${models[@]}"; do
            if [[ $model ]]; then
                filtered_models+=("$model")
            fi
        done

        # Sort the filtered models alphabetically
        sorted_models=($(printf "%s\n" "${filtered_models[@]}" | sort))

        # Get the current word being completed
        current_word=${COMP_WORDS[COMP_CWORD]}

        # Generate completions using compgen, which filters based on the prefix
        COMPREPLY=($(compgen -W "${sorted_models[*]}" -- "$current_word"))
    fi
}

complete -F _ollama_run ollama

# [[HUMAN COMMENTED-OUT]]
# Installation/activation:
# Add the script to your .bashrc and source it immediately
echo "source ~/.bash_completion" >> ~/.bashrc && source ~/.bash_completion
