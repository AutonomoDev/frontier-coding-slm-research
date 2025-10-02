#Thinking...
#Alright, I need to create a Bash completion script for the `ollama run` command. The goal is to provide model name suggestions when the user presses Tab after typing `run`. Let me break down the problem and figure out how to approach this.
#
#First, I should understand what the user is asking for. They want autocompletion specifically for the model names following `run`. So, whenever someone types `ollama run` and then hits Tab, a list of available models should pop up. If they type part of a model name, like `co`, only matching models should be suggested.
#
#I remember that Bash completion uses functions in `/etc/bash_completion` or other files. The function starts with `_complete_command`. So I'll need to write a function named `_ollama_run_completions`.
#
#Let me outline the steps:
#
#1. **Check if the command is `ollama run`:**
#   - Use `COMP_WORDS` array. The first word should be `ollama`, and the second should be `run`. If not, return nothing.
#
#2. **Parse `ollama list` to get model names:**
#   - Run `ollama list` to get the output.
#   - Skip the header line (the one starting with NAME).
#   - Extract the first column which contains model names.
#
#3. **Filter models based on the user's input:**
#   - The current word being completed is in `COMP_WORDS[COMP_CWORD-1]`. Wait, no—since the command structure is `ollama run <model>`, after `run` comes the model name. So `COMP_CWORD` points to the position of the word being completed. For example, if the user types `ollama run c<TAB>`, `COMP_CWORD` would be 2 (0-based? Or maybe it's 1-based; I need to check Bash documentation).
#
#Wait, let me think about how `COMP_WORDS` works. The array starts from the first word. So for `ollama run model`, `COMP_WORDS[0]` is 'ollama', [1] is 'run', and [2] is 'model'. When completing after 'run', which would be at position 2, but since the user hasn't typed the model yet, perhaps the current word index is 2. Or wait, no: when you press Tab after typing `run`, the next word (position 2) is where completion occurs.
#
#So in the function, I need to check if the second word (index 1) is 'run'. If it's not, return nothing.
#
#Once that's confirmed, get the current model being typed. That would be `COMP_WORDS[COMP_CWORD]` or perhaps the previous word? Wait, no: when completing after `run`, the next word is the one we're completing, so `COMP_CWORD` points to that position.
#
#Wait, in Bash, `COMP_CWORD` gives the index of the current word being completed. So for example:
#
#- Command line: `ollama run <TAB>`
#  - `COMP_WORDS` = ['ollama', 'run']
#  - `COMP_CWORD` is 2 (since it's the third word if starting from 0). Wait, no—indexes are zero-based in arrays but I'm not sure about Bash. Let me clarify: In Bash, `COMP_CWORD` is set to the index of the current word in the `COMP_WORDS` array.
#
#So for `ollama run <TAB>`, the command so far is two words (ollama and run), and the next word is being completed. So `COMP_CWORD` would be 2 if it's zero-based? Or maybe it's one-based? Wait, no—Bash uses zero-based indexes. So in this case, `COMP_WORDS[0]` = ollama, [1] = run, and the next word is at index 2.
#
#But when you press Tab, the shell is trying to complete the third part (index 2). So in the completion function, we need to see if the second word (index 1) is 'run'—if not, don't do anything. Then, get the string being typed so far for the model name.
#
#Wait, perhaps a better way: check that the command starts with `ollama run`, and then the next part is where completion is needed.
#
#So in the function:
#
#- Check if ${COMP_WORDS[1]} == 'run'. If not, return.
#- Then, get the current word being completed: that's at index $COMP_CWORD. So for example, when the user types `ollama run c`, and then Tab, COMP_CWORD is 2 (assuming zero-based), so the word to complete is 'c'.
#
#Wait no—when you're typing `run` and press Tab, the next word is being completed. So in that case, after `run`, the next part is the model name.
#
#So for example:
#
#- User types: ollama run <TAB>
#  - COMP_WORDS = ['ollama', 'run']
#  - COMP_CWORD is 2 (if zero-based), but since it's beyond the array length, perhaps it's set to the position where completion is happening. Hmm, this might require testing.
#
#Alternatively, perhaps I should get the word being completed as ${COMP_WORDS[COMP_CWORD]}, which would be an empty string or partial model name.
#
#Wait, let me refer to the Bash completion documentation. The `COMPREPLY` variable holds the list of possible completions. The function is called with the current command line and cursor position, and it's responsible for generating the possible completions.
#
#In our case, we need to generate suggestions only when the previous word is 'run'. So in the function:
#
#if [[ ${COMP_WORDS[1]} != "run" ]]; then
#    return
#fi
#
#Then, get the model names from `ollama list`, parse them, and filter based on the current partial model name.
#
#So next step: parsing `ollama list`.
#
#The output of `ollama list` is:
#
#NAME                            ID              SIZE    MODIFIED
#llama3:latest                   a7320c749969    4.7 GB  3 weeks ago
#codellama:7b-instruct           2b9b6e83e370    4.7 GB  2 months ago
#deepseek-coder-v2:16b-lite      278b4081325b    9.3 GB  2 weeks ago
#
#We need to extract the first column, skipping the header.
#
#Using `awk` is possible, but the user specified that we shouldn't use external tools like awk if possible, and prefer coreutils.
#
#So, how can I parse this without awk? Let me think.
#
#I can use `cut -d $'\t' -f 1`. The output is tab-separated. So:
#
#model_names=$(ollama list | cut -d $'\t' -f 1 | tail -n +2)
#
#Wait, let's test this:
#
#The first line starts with 'NAME', so the second and subsequent lines are model names.
#
#But wait, when I run `cut -d $'\t' -f 1`, each line will give me the first column. So for the sample output:
#
#NAME                            ID...
#llama3:latest                   a7320c749969...
#codellama:7b-instruct           2b9b6e83e370...
#deepseek-coder-v2:16b-lite      278b4081325b...
#
#cut -f 1 would output:
#
#NAME
#llama3:latest
#codellama:7b-instruct
#deepseek-coder-v2:16b-lite
#
#So to skip the first line, I can use tail -n +2.
#
#So model_names=$(ollama list | cut -d $'\t' -f 1 | tail -n +2)
#
#Yes, that works. So now, we have all model names in an array.
#
#Then, get the current word being completed: current_model="${COMP_WORDS[COMP_CWORD]}"
#
#Wait, no—because COMP_CWORD is the index of the current word. If the user types `ollama run co`, then `run` is at index 1, and the next word (index 2) is 'co'. So the partial model name is 'co'.
#
#So in the function:
#
#current_model="${COMP_WORDS[COMP_CWORD]}"
#
#Wait no—because COMP_CWORD could be beyond the current array. Wait, let me think about it.
#
#When the user types `ollama run co<TAB>`, the command line has three parts: ['ollama', 'run', 'co'], so COMP_WORDS is an array of these three elements. So COMP_CWORD is 2 (zero-based), and the current word is 'co'.
#
#But in reality, after typing 'run' and pressing Tab, the next part hasn't been filled yet—so when the user presses Tab after 'run', COMP_CWORD would be 2, but COMP_WORDS[2] is empty.
#
#Wait no—I think I'm getting confused. Let me try to find an example.
#
#In Bash, when you're completing a command, `COMP_WORDS` contains all the words up to the current point, and `COMP_CWORD` is the index of the word being completed.
#
#So for example:
#
#If the user types 'ollama run c<TAB>', then:
#
#- COMP_WORDS = ['ollama', 'run', 'c']
#- COMP_CWORD = 2
#- The function will be called with this context, and it's supposed to generate completions for the third word (index 2).
#
#So in the function, I can safely get the current partial model name as `COMP_WORDS[COMP_CWORD]`.
#
#Wait no—because when you press Tab after 'run', the next part is being filled. So before pressing Tab, the command line has two words: 'ollama' and 'run'. The next word hasn't been typed yet; so in this case, COMP_WORDS would be ['ollama', 'run'], and COMP_CWORD would point to position 2, which is beyond the array.
#
#Wait no—I think that when you press Tab after the second word (run), Bash will call the completion function with `COMP_WORDS` as ['ollama', 'run'] and `COMP_CWORD` set to 2 (the index of the next word). So in this case, the current partial model name is empty.
#
#Hmm, perhaps I should get the previous word. Alternatively, perhaps it's better to use `_get_comp_words_by_ref`, but the user said that if it's missing, we should fallback to using COMP_WORDS and COMP_CWORD.
#
#So perhaps, first, try to use `_get_comp_words_by_ref` to get the current word (cur) and previous words (prev). If that doesn't work, manually set cur and prev from COMP_WORDS and COMP_CWORD.
#
#Wait, but in this case, we don't need the previous words beyond 'run'. Because our logic is: only when the second word is 'run', then suggest models. So perhaps it's better to not use `_get_comp_words_by_ref` at all, as per one of the requirements.
#
#The user said that if using `_get_comp_words_by_ref`, include a fallback, but perhaps we can avoid it by directly checking COMP_WORDS and setting cur ourselves.
#
#So, in code:
#
## Check if the second word is 'run'
#if [[ ${COMP_WORDS[1]} != "run" ]]; then
#    return
#fi
#
#current_model="${COMP_WORDS[COMP_CWORD]}"
#
#Wait, no—if the user hasn't typed anything after run yet, COMP_CWORD would be 2 (zero-based?), and in that case, `COMP_WORDS` array has only two elements: ['ollama', 'run'], so index 2 is beyond.
#
#So perhaps, when completing, the current word is the one at position `COMP_CWORD`, which could be greater than or equal to the length of COMP_WORDS. So for example:
#
#When user types ollama run and presses Tab, COMP_WORDS is ['ollama', 'run'], and COMP_CWORD is 2.
#
#So in this case, the current model being typed is empty string? Or perhaps it's the next word.
#
#Wait, maybe a better approach is to construct the command so far as a string, split into words, then see where we are.
#
#But perhaps it's easier to check if the second word is 'run', and then proceed. Then, get all model names, filter those that start with the current partial model name (if any), else return all models.
#
#So steps in code:
#
#1. Check if the command is `ollama run`. If not, return.
#   - So, check if ${COMP_WORDS[0]} == 'ollama' and ${COMP_WORDS[1]} == 'run'. Because the function could be called for commands with more words, but we only want to complete when the next word after run is a model name.
#
#Wait no—the command could have more subcommands beyond run, but in our case, `run` takes one argument which is the model name. So perhaps any other subcommand after run would not be part of the model list.
#
#But according to the user's requirements, the completion should only activate for the word immediately following 'run', so we must ensure that the second word is 'run' and that we're completing the third word.
#
#So in code:
#
## Check if the second word is 'run'
#if [[ ${COMP_WORDS[1]} != "run" ]]; then
#    return 0
#fi
#
## Now, get all model names
#model_names=$(ollama list | cut -d $'\t' -f 1 | tail -n +2)
#
## Split into an array
#models=($model_names)
#
## Get the current partial model name
#current_model="${COMP_WORDS[COMP_CWORD]}"
#
## Filter models starting with current_model
#completions=()
#for model in "${models[@]}"; do
#    if [[ $model == "$current_model"* ]]; then
#        completions+=("$model")
#    fi
#done
#
## Remove duplicates (though ollama list shouldn't have duplicates)
#completions=($(printf "%s\n" "${completions[@]}" | sort -u))
#
## Set COMPREPLY
#COMPREPLY=( $(printf "%s\n" "${completions[@]}") )
#
#Wait, but this may not work correctly if current_model is empty. Because then, all models would be suggested.
#
#Yes.
#
#But we should also consider case sensitivity? I think `ollama` commands are case-sensitive, so perhaps no need to handle that unless specified.
#
#Another thing: the user's system might have aliases or other factors, but as per our code, we can safely assume that the output of `ollama list` is as described.
#
#Now, about the function:
#
#The function should be named _ollama_run_completions and installed with `complete -F`.
#
#Wait, perhaps it's better to write a generic Bash completion function.
#
#Alternatively, the user may have provided a system message where we can generate code for this.
#
#So putting all together, the function would look like:
#
#_ollama_run_completions() {
#    # Check if the second word is 'run'
#    local cur prev
#    _get_comp_words_by_ref -n 2 -c cur prev
#    if [[ ${prev[1]} != "run" ]]; then
#        return 0
#    fi
#
#    local model_names=$(ollama list | cut -d $'\t' -f 1 | tail -n +2)
#    local models=($model_names)
#
#    # Filter models
#    completions=()
#    for model in "${models[@]}"; do
#        if [[ $cur == "$model"* ]]; then
#            completions+=("$model")
#        fi
#    done
#
#    COMPREPLY=(($(compgen -W "$(printf "%s\n" "${completions[@]}")" -- "$cur"))))
#}
#
#But wait, in the code above, `_get_comp_words_by_ref` is used to get the current word and previous words. But if it's not available (e.g., in some shells), we should fall back.
#
#Alternatively, as per the user's instructions, include a fallback if `_get_comp_words_by_ref` is not available.
#
#But perhaps for simplicity, given that this function is only triggered when completing `run`, we can directly check the second word.
#
#So another approach:
#
#_ollama_run_completions() {
#    # Check if the command is 'ollama run' and we're completing the next word
#    local words=("${COMP_WORDS[@]}")
#    if [[ ${words[1]} != "run" ]]; then
#        return 0
#    fi
#
#    # Get all model names
#    local models=$(ollama list | cut -d $'\t' -f 1 | tail -n +2)
#    models=($(echo "$models"))
#
#    # Current partial model name
#    local current_model="${words[COMP_CWORD]}"
#
#    # Filter models that start with current_model
#    completions=()
#    for model in "${models[@]}"; do
#        if [[ $model == "$current_model"* ]]; then
#            completions+=("$model")
#        fi
#    done
#
#    COMPREPLY=( $(printf "%s\n" "${completions[@]}") )
#}
#
#But wait, this could have issues with word arrays. For example, when `COMP_WORDS` is empty or not long enough.
#
#Alternatively, perhaps a safer approach is to use `_get_comp_words_by_ref` if available, else fall back.
#
#So:
#
#_ollama_run_completions() {
#    # Use _get_comp_words_by_ref if available
#    if command -v _get_comp_words_by_ref &> /dev/null; then
#        _get_comp_words_by_ref -n 2 -c cur prev
#    else
#        # Fallback: manually set cur and prev from COMP_WORDS and COMP_CWORD
#        local index=1
#        while [[ $index -le ${#COMP_WORDS[@]} && $index -lt 2 ]]; do
#            prev[$index]=${COMP_WORDS[index]}
#            ((index++))
#        done
#        cur=${COMP_WORDS[COMP_CWORD]}
#    fi
#
#    # Check if the second word is 'run'
#    if [[ ${prev[1]} != "run" ]]; then
#        return 0
#    fi
#
#    # Get all model names
#    local models=$(ollama list | cut -d $'\t' -f 1 | tail -n +2)
#    models=($(echo "$models"))
#
#    # Filter models that start with cur
#    completions=()
#    for model in "${models[@]}"; do
#        if [[ $model == "$cur"* ]]; then
#            completions+=("$model")
#        fi
#    done
#
#    COMPREPLY=( $(printf "%s\n" "${completions[@]}") )
#}
#
#But this is getting complicated. Alternatively, perhaps we can write it without relying on `_get_comp_words_by_ref`.
#
#Let me think again: our function is to complete the model names after 'run', so we only need to process when the previous word is 'run'.
#
#So, in code:
#
#_ollama_run_completions() {
#    # Get the previous words up to 'run'
#    local words=("${COMP_WORDS[@]}")
#    if [[ ${#words[@]} -lt 2 || ${words[1]} != "run" ]]; then
#        return 0
#    fi
#
#    # Get all model names
#    local models=$(ollama list | cut -d $'\t' -f 1 | tail -n +2)
#    models=($(echo "$models"))
#
#    # Current partial model name: it's the word at COMP_CWORD
#    local current_model="${words[COMP_CWORD]}"
#
#    # Filter models that start with current_model
#    completions=()
#    for model in "${models[@]}"; do
#        if [[ $model == "$current_model"* ]]; then
#            completions+=("$model")
#        fi
#    done
#
#    COMPREPLY=( $(printf "%s\n" "${completions[@]}") )
#}
#
#But this approach assumes that COMP_WORDS includes all the words up to the current point, and that the second word is 'run'. So in cases where there are more than two words (e.g., ollama run model_name extra), it would still process, but since we're checking if the second word is 'run', any further processing beyond that is irrelevant.
#
#But wait, for example:
#
#If the command is `ollama run model_name extra`, then COMP_WORDS will be ['ollama', 'run', 'model_name', 'extra'], and the function would be called with COMP_CWORD=3 (if the cursor is after 'model_name'). Then, since words[1] is 'run', we proceed. current_model is 'extra'. But 'extra' doesn't match any model names, so nothing is suggested.
#
#Which is correct because the command `ollama run` takes only one argument—the model name. So completing beyond that shouldn't occur unless the user makes a mistake.
#
#But perhaps this function should only be triggered when exactly two words are present (i.e., ollama run) or three words with the third being partially typed.
#
#Hmm, this may complicate things further.
#
#Alternatively, perhaps we can always process the model names regardless of how many words are present beyond 'run', but only if the previous word is 'run'.
#
#So in the function:
#
#if [[ ${words[1]} != "run" ]]; then
#    return 0
#fi
#
#Then proceed to get all models and filter based on current_model, which is at COMP_CWORD.
#
#I think that's acceptable.
#
#Now, about performance: running `ollama list` every time a completion is triggered could be slow. But since the list of models doesn't change often (unless new models are added), perhaps we can cache it or find another way.
#
#But for simplicity, and given the constraints, let's proceed with this approach.
#
#Another point: handling empty lines or errors in `ollama list`? For example, if ollama isn't installed, but the function is still called. But as per the user's context, we can assume that the function is being used within an environment where 'ollama' is available and properly set up.
#
#Now, putting it all together, the function `_ollama_run_completions` would be:
#
#_ollama_run_completions() {
#    # Get all words
#    local words=("${COMP_WORDS[@]}")
#
#    # Check if at least two words are present and the second is 'run'
#    if [[ ${#words[@]} -lt 2 || ${words[1]} != "run" ]]; then
#        return 0
#    fi
#
#    # Get model names from ollama list, skipping the header
#    local models=$(ollama list | cut -d $'\t' -f 1 | tail -n +2)
#    models=($(echo "$models"))
#
#    # Current partial model name to complete
#    local current_model="${words[COMP_CWORD]}"
#
#    # Collect all models starting with current_model
#    completions=()
#    for model in "${models[@]}"; do
#        if [[ $model == "$current_model"* ]]; then
#            completions+=("$model")
#        fi
#    done
#
#    # Set the list of possible completions
#    COMPREPLY=( $(printf "%s\n" "${completions[@]}") )
#}
#
#Then, to install this completion:
#
#complete -F _ollama_run_completions run
#
#Wait no—the function is named `_ollama_run_completions`, and it's triggered when completing the command 'run'? No, because in our case, 'run' is a subcommand of ollama.
#
#Ah, right. So the function should be triggered when completing after 'ollama run'.
#
#So we need to bind this function to the 'run' subcommand of 'ollama'.
#
#In Bash, you can do that with:
#
#complete -o default -F _ollama_run_completions ollama
#
#But I'm not entirely sure. Alternatively, perhaps it's better to write a completion function for the entire command.
#
#Alternatively, perhaps using `compctl` or another method.
#
#Wait, in modern Bash, the preferred way is to use the `complete` command with `-F` (function) and specify the command name.
#
#So for example:
#
#complete -F _ollama_run_completions ollama
#
#But this would apply the function to all completions related to 'ollama', which may not be desired. Instead, we need to make it only trigger when completing after 'run'.
#
#Hmm, perhaps a better approach is to write a completion function that is triggered when the last word is 'run' and the previous word is 'ollama'.
#
#Alternatively, in Bash, you can specify that completions are handled for a specific command. For example:
#
#complete -F _ollama_run_completions ollama
#
#But then, how to make sure it only completes after 'run'? Perhaps within the function itself.
#
#Wait, perhaps inside `_ollama_run_completations`, we can check if the last word is 'run' and that the previous words include 'ollama'.
#
#Alternatively, since the function is called for every possible completion, including when typing 'ollama', 'run', etc., but in our case, we only want to trigger when completing after 'run'.
#
#Wait, perhaps a better approach is to use `compopt` or another method.
#
#Alternatively, I found that using:
#
#complete -F _ollama_run_completions ollama:run
#
#But I'm not sure if the syntax supports that. Alternatively, perhaps it's better to write the function as a generic one and rely on the context within the function.
#
#Wait, in the function `_ollama_run_completions`, we can check whether the current command is 'ollama' and the previous word is 'run'.
#
#Alternatively, perhaps it's easier to trigger this function when the last word is 'run', regardless of the command. But that may not be correct.
#
#I think a better approach is to make sure that the completion only happens for 'run' as a subcommand of 'ollama'. So, we can use:
#
#complete -F _ollama_run_completions ollama
#
#And within the function, check if the last word is 'run'.
#
#Wait, no. The function will be called when completing any command named 'ollama', which may not be desirable.
#
#Alternatively, perhaps it's better to write a shell completion function that only triggers for the 'run' subcommand.
#
#I found that in Bash, you can specify the context with `complete -C`, but I'm not sure. Alternatively, perhaps using an associative array or other methods.
#
#But perhaps this is getting too complicated, and given time constraints, it's better to proceed with the function as above, assuming that 'ollama run' is being completed.
#
#So, in conclusion, the final code would be:
#
#_ollama_run_completions() {
#    local words=("${COMP_WORDS[@]}")
#    if [[ ${#words[@]} -lt 2 || ${words[1]} != "run" ]]; then
#        return 0
#    fi
#
#    # Get all models from ollama list, skipping the header
#    local models=$(ollama list | cut -d $'\t' -f 1 | tail -n +2)
#    models=($(echo "$models"))
#
#    local current_model="${words[COMP_CWORD]}"
#
#    completions=()
#    for model in "${models[@]}"; do
#        if [[ $model == "$current_model"* ]]; then
#            completions+=("$model")
#        fi
#    done
#
#    COMPREPLY=( $(printf "%s\n" "${completions[@]}") )
#}
#
#complete -F _ollama_run_completions run
#
#Wait, but this would bind the function to 'run' as a standalone command. Not as a subcommand of 'ollama'.
#
#So perhaps we need to make it trigger when the last word is 'run', regardless of the parent command.
#
#Alternatively, perhaps using:
#
#complete -F _ollama_run_completions ollama
#
#But then, how to check if the current context is after 'run'?
#
#Within `_ollama_run_completions`, COMP_WORDS will contain all words in the command line. So for example, when typing 'ollama run m', COMP_WORDS would be ['ollama', 'run', 'm'].
#
#So in the function:
#
#if [[ ${#words[@]} -lt 2 || ${words[1]} != "run" ]]; then
#    return 0
#fi
#
#This checks if at least two words are present, and the second is 'run'. So for 'ollama run m', it would proceed.
#
#Wait no: in this case, words would be ['ollama', 'run', 'm'], so ${#words[@]} is 3. The condition checks if the number of words is less than 2 OR the second word is not 'run'—so for our example, since words[1] is 'run', it proceeds.
#
#Wait no: because in that case, the function would proceed regardless of how many words are present beyond two, as long as the second is 'run'.
#
#Which is correct, because we want to complete model names after 'run'.
#
#So perhaps this approach works.
#
#Another example:
#
#If the user types 'ollama run', then COMP_WORDS will be ['ollama', 'run'], and function proceeds.
#
#But for 'ollama something else', where words[1] != 'run', it returns 0.
#
#Thus, this should correctly handle the case when completing after 'run'.
#
#So putting all together:
#
#_ollama_run_completions() {
#    local words=("${COMP_WORDS[@]}")
#    if [[ ${#words[@]} -lt 2 || ${words[1]} != "run" ]]; then
#        return 0
#    fi
#
#    # Get models
#    local models=$(ollama list | cut -d $'\t' -f 1 | tail -n +2)
#    models=($(echo "$models"))
#
#    local current_model="${words[COMP_CWORD]}"
#
#    completions=()
#    for model in "${models[@]}"; do
#        if [[ $model == "$current_model"* ]]; then
#            completions+=("$model")
#        fi
#    done
#
#    COMPREPLY=( $(printf "%s\n" "${completions[@]}") )
#}
#
#complete -F _ollama_run_completions ollama
#
#But wait, when `complete` is called with 'ollama', it will apply the function to all completions for 'ollama'. So within the function, we need to check that the command is 'run'.
#
#Wait no: the function is named `_ollama_run_completions`, and when completing 'ollama', COMP_WORDS will be ['ollama'], so in the first line of the function:
#
#words=("${COMP_WORDS[@]}"), which would be just ['ollama'].
#
#Then, ${#words[@]} is 1, less than 2, so return 0. Thus, nothing happens for 'ollama' alone.
#
#Only when completing after 'run', e.g., when typing 'ollama run m', the function proceeds.
#
#Thus, this should be correct.
#...done thinking.

## [[HUMAN COMMENTED-OUT]]
#To create a Bash completion function that suggests model names after typing `ollama run`, follow these steps:
#
#1. **Create the Completion Function**:
#   - Define a function `_ollama_run_completions` that retrieves model names from `ollama list` and filters them based on the current input.
#
#2. **Install the Completion Function**:
#   - Use the `complete` command to bind this function to the `run` subcommand of `ollama`.
#
#Here's the code:

_ollama_run_completions() {
    local words=("${COMP_WORDS[@]}")
    if [[ ${#words[@]} -lt 2 || ${words[1]} != "run" ]]; then
        return 0
    fi

    # Get models from ollama list, skipping the header
    local models=$(ollama list | cut -d $'\t' -f 1 | tail -n +2)
    models=($(echo "$models"))

    local current_model="${words[COMP_CWORD]}"

    completions=()
    for model in "${models[@]}"; do
        if [[ $model == "$current_model"* ]]; then
            completions+=("$model")
        fi
    done

    COMPREPLY=( $(printf "%s\n" "${completions[@]}") )
}

complete -F _ollama_run_completions ollama


# [[HUMAN COMMENTED-OUT]]
#**Explanation**:
#
#- **Function Definition**: `_ollama_run_completions` is defined to handle completions for the `run` subcommand of `ollama`.
#- **Check Context**: The function checks if the current context is after typing `run` as a subcommand.
#- **Retrieve Models**: It fetches all available models using `ollama list`, processes them to skip headers, and stores them in an array.
#- **Filter Models**: Based on the current input (the word being completed), it filters and suggests matching model names.
#- **Completion Setup**: The `complete` command binds this function to the `ollama` command, ensuring it triggers when completing after `run`.
#
#This setup enhances productivity by providing autocompletion for Ollama models whenever you type `ollama run` followed by a partial model name.

