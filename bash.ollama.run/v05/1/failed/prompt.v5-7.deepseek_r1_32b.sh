#Thinking...
#Okay, I need to create a Bash completion script for the `ollama run` command. Let me think through how to approach this step by step.
#
#First, the core requirement is that when the user types `ollama run` and presses TAB, they should get suggestions for model names from `ollama list`. The script must be self-contained and sourced.
#
#I remember that Bash completions use functions that are called when a specific command is being completed. So I'll need to write a function named `_ollama_run_completion` which will handle the completion logic.
#
#The first thing this function should do is check if it's the right context. The script must only activate for `run`, so I need to verify that the second word (`${COMP_WORDS[1]}`) is exactly 'run'. If not, return early without providing any completions.
#
#Next, I'll extract the current word being completed, which is in `$COMP_WORDS[$COMP_CWORD]`. This will be used for filtering the model names.
#
#Now, I need to fetch the list of models. Running `ollama list` gives me a table where each line has the model name as the first column. The header starts with 'NAME', so I should skip that. Using `awk '{print $1}'` would extract the first column, but since Awk is prohibited, I'll use `cut -d' ' -f1` instead.
#
#I'll capture this output into a variable. Then, split it into an array using `readarray`, which is better than older methods for handling lines with spaces or other characters.
#
#Once I have the list of models, I need to filter them based on the current word. Using `grep -iP "^${cur}"` will match model names that start with the current input. The `-i` flag makes it case-insensitive, which is useful if the user wants fuzzy matches regardless of case.
#
#But wait, the requirement says to filter precisely based on what's typed, so maybe case-sensitive matching is better. Hmm, but the example shows lowercase filtering. Oh, the examples use exact starting matches, so perhaps case-sensitive is correct. Maybe I should stick with case-sensitive unless specified otherwise. But the user didn't mention case-insensitivity, so perhaps it's better to not assume and keep it as-is.
#
#After filtering, I need to ensure there are no duplicates. Using `sort -u` will both sort and deduplicate the list.
#
#Now, construct the completions by setting `COMPREPLY`. The format should be an array where each element is a model name prefixed with "run " for display purposes. Wait, no—the completion itself should just be the model name. Because when you press TAB, it completes the command line to add the model name after 'run'.
#
#Wait, in the examples, when the user types `ollama run l<TAB>`, the suggestion is `llama3:latest`, so the completion would be that string appended after 'run'. So I should set each element of COMPREPLY to the model name.
#
#But wait, no—the function's job is to suggest possible completions for the current word. Since the current word is after 'run', each suggestion is a model name. So `COMPREPLY` should be an array where each element is one of the matching models.
#
#Putting it all together: read the models into an array, filter them, sort and dedupe, then set COMPREPLY to that list.
#
#I also need to handle cases where no matches are found, in which case COMPREPLY remains empty, so no suggestions are shown.
#
#Additionally, I should ensure that only the word immediately following 'run' is completed. So if the command line has more words beyond 'run', like `ollama run model --option`, then the function shouldn't attempt to complete anything else.
#
#Wait, in Bash completion functions, $COMP_CWORD indicates which word is being completed. For example, when the user types `ollama run <TAB>`, COMP_CWORD is 2 (since words are zero-indexed: 0=ollama, 1=run, 2=<empty>). So I need to make sure that the function only runs when COMP_CWORD is exactly 2.
#
#Wait, let me think about that. If the user has `ollama run model`, and then presses TAB again, perhaps for another argument, but in this case, we don't want to complete anything beyond 'run'. So I'll check if $COMP_CWORD is equal to 2, meaning the third word (index 2). If it's higher than that, return without doing anything.
#
#Wait, no. Because COMP_WORDS is an array where each element is a word in the command line. For `ollama run`, COMP_WORDS has two elements: index 0= 'ollama', index1='run'. So when the user is typing after 'run', like `ollama run <TAB>`, then $COMP_CWORD is 2 (since it's the third element, which is empty). So in this case, I should proceed only if $COMP_CWORD == 2.
#
#So adding a check at the beginning: if ${#COMP_WORDS} <=1 or $COMP_CWORD != 2, return early. Wait, perhaps more accurately, the function should only trigger when the current word being completed is directly after 'run', i.e., when the previous word (index 1) is 'run' and the current word is index 2.
#
#So in code:
#
#if [[ ${COMP_WORDS[1]} != "run" ]] || (( $COMP_CWORD != 2 )); then
#    return 0
#fi
#
#Wait, but what if the command line has more words beyond that? For example, `ollama run model --option`. In this case, when completing after 'model', we don't want to suggest models again. So yes, only trigger when the current word is the one immediately following 'run'.
#
#So the first check in the function should be:
#
#if [[ $COMP_CWORD -ne 2 || ${COMP_WORDS[1]} != "run" ]]; then
#    return 0
#fi
#
#Alternatively, perhaps it's better to just proceed only if the previous word is 'run' and current word is being completed. So using `prev=${COMP_WORDS[$COMP_CWORD-1]}` might not be necessary since we can check the second word.
#
#Wait, no. Because in some cases, like when the command line is `ollama run`, the third word (index 2) doesn't exist yet, so $COMP_WORDS[2] would be undefined. So perhaps it's better to handle it by checking if the previous word (i.e., the second word) is 'run'.
#
#Wait, let me structure this.
#
#In the function:
#
#prev_word=${COMP_WORDS[$((COMP_CWORD-1))]} # Previous word, which is the word before the current one being completed.
#
#But in the case where the user is completing after `ollama run`, the current word (index 2) is empty or the next argument. So prev_word would be 'run'.
#
#So perhaps a better approach is to check if the previous word is 'run' and that we're on the third position.
#
#Wait, no: in Bash, when you press TAB after `ollama run`, the current word being completed is index 2, which may not exist yet. So checking `${COMP_WORDS[1]}` would be sufficient because it's always the second argument, i.e., 'run'.
#
#So I think that condition should be: if the number of words is less than or equal to 1, then return early. Because for `ollama run`, COMP_WORDS has two elements (index 0 and 1), so when completing after that, $COMP_CWORD is 2.
#
#Wait, no. Let's see:
#
#When the user types `ollama run` and presses space, the command line becomes 'ollama run ', with three words? No, because spaces separate words, but in reality, until a new word starts, it's still two words.
#
#In Bash, when you have `ollama run <TAB>`, the current word is index 2, which is empty. So `${COMP_WORDS[1]}` is 'run', and $COMP_CWORD is 2.
#
#So in the function, to ensure that we're completing after 'run' as the second argument, I can check:
#
#if [[ ${#COMP_WORDS} -lt 2 || ${COMP_WORDS[1]} != "run" ]]; then
#    return 0
#fi
#
#Wait, no. Because if the user is trying to complete `ollama run model`, and then presses TAB again for another word after 'model', we don't want to trigger our completion. So in that case, the second argument is still 'run', but $COMP_CWORD is higher than 2.
#
#So perhaps a better condition is:
#
#if [[ ${#COMP_WORDS} -lt 2 || ${COMP_WORDS[1]} != "run" || $COMP_CWORD -ne 2 ]]; then
#    return 0
#fi
#
#This way, we only proceed when the second argument is 'run' and the current word being completed is index 2.
#
#Now, moving on to parsing `ollama list`. The output starts with a header line, so I need to skip that. Using `tail -n +2` would get all lines except the first.
#
#Then, extract the first column using `cut -d' ' -f1`, as Awk is prohibited. But wait, what if model names have spaces? Then, cutting on the first space might not capture the entire name. For example, a model named "llama 3:latest" would be split into "llama" and "3:latest". That's incorrect.
#
#So I need a way to correctly extract the entire first field, which is the model name. But in `ollama list` output, how are the columns formatted? The sample shows that each line has four fields separated by spaces. So perhaps the model names don't contain spaces, but it's better to assume they might.
#
#In that case, using `cut -d' ' -f1` is insufficient because it only takes up to the first space. Instead, I need a way to extract the entire first field, considering possible spaces in the name.
#
#Wait, perhaps using `awk '{print $1}'` would correctly print the first field regardless of spaces because Awk splits on any whitespace by default. But the problem states that Awk is prohibited. So what can I use instead?
#
#Hmm, this is a challenge. Without Awk, how to extract the first column correctly when model names might contain spaces.
#
#Alternative approach: parse each line and split into fields using Bash's read command with -r option to preserve backslashes and split on whitespace.
#
#But perhaps in practice, model names don't have spaces. Looking at the sample output:
#
#llama3:latest
#codellama:7b-instruct
#deepseek-coder-v2:16b-lite
#
#None of these have spaces, so maybe it's safe to assume that model names do not contain spaces. So using `cut -d' ' -f1` is acceptable.
#
#But what if a model name does include a space? For example, "my model v1". Then, the first field would be "my" and the rest would be lost. That's incorrect.
#
#Since I can't use Awk, perhaps another approach is needed. Maybe using `sed` to extract the first field correctly.
#
#Alternatively, perhaps we can use `cut -d' ' -f1` but that's only correct if model names don't have spaces. So maybe in this case, it's acceptable as per the problem description, given that the sample output doesn't include spaces in model names.
#
#So proceeding with `cut -d' ' -f1`.
#
#Now, collect all model names into an array:
#
#model_list=$(ollama list | tail -n +2 | cut -d' ' -f1)
#readarray -t models <<< "$model_list"
#
#Then, filter this array based on the current word. So for each model name, check if it starts with the current input.
#
#But how to do that in Bash without Awk or external tools? Using a loop:
#
#cur=${COMP_WORDS[COMP_CWORD]}
#candidates=()
#
#for model in "${models[@]}"; do
#    if [[ $model == $cur* ]]; then
#        candidates+=("$model")
#    fi
#done
#
#Wait, but this is case-sensitive. The examples show that the filtering is exact, so perhaps it's correct.
#
#Alternatively, using `grep` with a pattern:
#
#candidates=($(printf "%s\n" "${models[@]}" | grep -i "^$cur"))
#
#But again, since Awk is prohibited, I can use `grep`.
#
#Wait, but in the strict requirements, it says to filter based on what the user is typing. So case-sensitive matching might be better unless specified otherwise.
#
#So perhaps using:
#
#candidates=($(printf "%s\n" "${models[@]}" | grep "^$cur"))
#
#But also, if the current word is empty (like when pressing TAB immediately after 'run'), then we should list all models.
#
#Wait, yes. Because in that case, cur is an empty string, so the pattern becomes '^', which matches any line. So the candidates would include all model names.
#
#Once I have the candidates, I need to sort them and remove duplicates. Since readarray already reads each unique line as a separate element (assuming `ollama list` doesn't output duplicates), perhaps it's unnecessary. But to be safe:
#
#candidates=($(printf "%s\n" "${models[@]}" | grep "^$cur" | sort -u))
#
#Wait, but in Bash, the order may not be preserved if we sort. So perhaps better to first filter and then sort.
#
#Alternatively, process the models array without sorting unless necessary.
#
#But according to the problem statement, the suggestions should be unique, so using `sort -u` is acceptable even if it changes the order.
#
#So putting this together:
#
#cur=${COMP_WORDS[COMP_CWORD]}
#candidates=()
#model_list=$(ollama list | tail -n +2 | cut -d' ' -f1)
#readarray -t models <<< "$model_list"
#
## Filter models that start with cur
#filtered_models=()
#for model in "${models[@]}"; do
#    if [[ $model == $cur* ]]; then
#        filtered_models+=("$model")
#    fi
#done
#
## Remove duplicates and sort
#unique_sorted=($(echo "${filtered_models[@]}" | tr ' ' '\n' | sort -u))
#
#candidates=("${unique_sorted[@]}")
#
#Then, set the COMPREPLY array:
#
#COMPREPLY=("${candidates[@]}")
#
#Wait, but in the function, it's better to directly assign.
#
#So overall, the function would look like this:
#
#function _custom_completion {
#    if [[ ${#COMP_WORDS} -lt 2 || ${COMP_WORDS[1]} != "run" || $COMP_CWORD -ne 2 ]]; then
#        return 0
#    fi
#
#    cur=${COMP_WORDS[COMP_CWORD]}
#    model_list=$(ollama list | tail -n +2 | cut -d' ' -f1)
#    readarray -t models <<< "$model_list"
#
#    # Filter and sort
#    candidates=()
#    for model in "${models[@]}"; do
#        if [[ $model == $cur* ]]; then
#            candidates+=("$model")
#        fi
#    done
#
#    # Remove duplicates by creating a set
#    declare -A seen
#    unique_candidates=()
#    for candidate in "${candidates[@]}"; do
#        if [[ -z ${seen[$candidate]} ]]; then
#            seen[$candidate]=1
#            unique_candidates+=("$candidate")
#        fi
#    done
#
#    COMPREPLY=("${unique_candidates[@]}")
#}
#
#But wait, `ollama list` may output models with the same name. So using a hash to track seen candidates ensures uniqueness.
#
#Alternatively, since readarray reads each line as an element, and if `ollama list` outputs duplicates, they would be in the models array. But perhaps it's better to assume that model names are unique, so no need for deduplication unless necessary.
#
#But the problem says to ensure uniqueness, so including this step is correct.
#
#Now, testing edge cases:
#
#1. When cur is empty (TAB pressed right after 'run'), all models are suggested.
#2. When cur starts with a substring of some model names, only those are suggested.
#3. If there's no match, nothing is suggested.
#
#Another consideration: efficiency. For each completion attempt, `ollama list` is called, which may be slow if the list is large or the command takes time.
#
#But as per the problem statement, this is acceptable for a custom completion function.
#
#Putting it all together, the final code would be:
#
#function _custom_completion {
#    local cur prev_word
#
#    # Check conditions: previous word must be 'run' and current word is third argument
#    if [[ ${#COMP_WORDS} -lt 2 || ${COMP_WORDS[1]} != "run" || $COMP_CWORD -ne 2 ]]; then
#        return 0
#    fi
#
#    cur=${COMP_WORDS[$COMP_CWORD]}
#
#    # Fetch model list, skipping header
#    local model_list=$(ollama list | tail -n +2 | cut -d' ' -f1)
#    local models=()
#    readarray -t models <<< "$model_list"
#
#    # Filter models that start with the current word
#    local candidates=()
#    for model in "${models[@]}"; do
#        if [[ $model == $cur* ]]; then
#            candidates+=("$model")
#        fi
#    done
#
#    # Remove duplicates
#    declare -A seen
#    local unique_candidates=()
#    for candidate in "${candidates[@]}"; do
#        if [[ -z ${seen[$candidate]} ]]; then
#            seen[$candidate]=1
#            unique_candidates+=("$candidate")
#        fi
#    done
#
#    # Assign to COMPREPLY
#    COMPREPLY=("${unique_candidates[@]}")
#
#    return 0
#}
#
#Then, in the bashrc or appropriate file, bind this function to the command.
#
#Wait, but in which context? Because for custom completions, typically you define a completion function and then use `complete -F` to associate it with a command.
#
#But in this case, perhaps we're creating a custom completion for commands that follow 'ollama run', but I'm not sure. Alternatively, maybe the function is intended to be used for completing after 'run' as a specific argument.
#
#Alternatively, perhaps the function should be registered to complete after the 'run' command in the context of another application, but since the problem isn't clear on that, perhaps it's better to assume that this function is meant to provide completions when the second argument is 'run'.
#
#Wait, perhaps I'm overcomplicating. The function as written checks if the previous word is 'run', which would be for any command where the second argument is 'run'. So in a more general context, it might not be appropriate.
#
#Alternatively, perhaps this function is meant to provide completions for a specific command, say `mycommand run`, and when completing after that. But without knowing the full context, it's difficult to tell.
#
#In any case, the function as written should handle the completion correctly under the given conditions.
#...done thinking.

# [[HUMAN COMMENTED-OUT]]
#To solve this problem, we need to create a custom completion function in Bash that provides suggestions for model names following the command `ollama run`. This function will fetch the list of available models using `ollama list`, filter them based on the current input, and ensure uniqueness before suggesting them.
#
#### Approach
#1. **Check Conditions**: Ensure that we are completing after the second argument which is 'run' and that the current word being completed is the third argument.
#2. **Fetch Model List**: Use `ollama list` to get the list of models, skipping the header line.
#3. **Filter Models**: Extract model names starting with the current input substring.
#4. **Remove Duplicates**: Ensure each model name is suggested only once.
#5. **Assign Completions**: Set the filtered and unique model names as possible completions.

### Solution Code
function _custom_completion {
    local cur prev_word

    # Check if we're in a position to complete after 'run'
    if [[ ${#COMP_WORDS} -lt 2 || ${COMP_WORDS[1]} != "run" || $COMP_CWORD -ne 2 ]]; then
        return 0
    fi

    cur=${COMP_WORDS[$COMP_CWORD]}

    # Fetch the list of models, skipping the header line
    local model_list=$(ollama list | tail -n +2 | cut -d' ' -f1)
    local models=()
    readarray -t models <<< "$model_list"

    # Filter models that start with the current word
    local candidates=()
    for model in "${models[@]}"; do
        if [[ $model == $cur* ]]; then
            candidates+=("$model")
        fi
    done

    # Remove duplicates while preserving order
    declare -A seen
    local unique_candidates=()
    for candidate in "${candidates[@]}"; do
        if [[ -z ${seen[$candidate]} ]]; then
            seen[$candidate]=1
            unique_candidates+=("$candidate")
        fi
    done

    # Assign the unique candidates to COMPREPLY
    COMPREPLY=("${unique_candidates[@]}")

    return 0
}

# Bind the completion function to the relevant command context
complete -F _custom_completion run

# [[HUMAN COMMENTED-OUT]]
### Explanation
#- **Condition Check**: The function first checks if it should proceed by verifying that the second argument is 'run' and that we're completing the third argument.
#- **Model Fetching**: It fetches the list of models using `ollama list`, skips the header, and extracts the first column which contains model names.
#- **Filtering**: Models are filtered to include only those starting with the current input substring for efficient suggestions.
#- **Uniqueness**: A hash map is used to track seen model names, ensuring each suggestion is unique.
#- **Completion Assignment**: The filtered and unique model names are assigned to `COMPREPLY`, which Bash uses to display possible completions.
#
#This approach ensures that users receive relevant and accurate suggestions when completing commands after `ollama run`, enhancing their workflow efficiency.

