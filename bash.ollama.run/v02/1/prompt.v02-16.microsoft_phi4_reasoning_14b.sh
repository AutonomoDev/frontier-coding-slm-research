<think>We are asked: "Create a bash-completion function for `ollama run <model>` that dynamically lists available models by parsing the output of `ollama list`. Assume `ollama list` prints model names one per line or separated by whitespace. Requirements exactly:

1. Trigger condition: Only offer completions when command is `ollama run` and user is completing after `run`.
2. Model retrieval: Invoke `ollama list` once, capture its full output into a variable. Do NOT pipe ollama list directly to while read loop, because that creates subshell and loses populated arrays; use safe pattern.
3. Prefix filtering: Use current word being completed (from COMP_WORDS/COMP_CWORD) to filter model names so only those matching the prefix are suggested. Populate COMPREPLY correctly using compgen or manual filtering.
4. Graceful failure: If ollama list fails or errors, silently return with no completions (do not produce errors or break shell).
5. Sorting: if there are multiple matches, sort them alphabetically before assigning to COMPREPLY.
6. No external dependencies: Only use Bash built-ins; do not call jq, awk, etc.
7. Installation instructions at bottom.

The output format should include a complete bash-completion function wired to ollama (e.g., `complete -F ... ollama`), comments explaining key parts, and installation/activation snippet at the end.

We need only the script and brief installation instructions in code block.

We need to write just one script file that includes these things. The script should be dependency-free and only use Bash builtins. So no AWK or grep; but we can use read, IFS splitting maybe using internal shell loop over string variable.

Plan: Write a function named _ollama_completion, which is triggered by "complete -F _ollama_completion ollama". But requirement says that the command is `ollama run <model>`. So if the first argument is "run", then we provide completions for second word. Let's check COMP_WORDS array and COMP_CWORD variable.

We want to do this: 
- Check if length of COMP_WORDS (maybe $COMP_CWORD) equals 2? Actually, since command is `ollama run <model>`, so first two words are "ollama" and "run", then third is the model. So we should check if number of words is equal to 3, or maybe just check that second argument equals "run"? We need to trigger completion only after "run".
- For safety: If $COMP_WORDS[1] is "run"? Let's check: Actually, note: In bash completions, COMP_WORDS is an array with the entire command. index 0: "ollama", index 1: "run". So condition if [ "$COMP_CWORD" -eq 2 ]? But then we want to complete model names only when user typed "ollama run <something>".
- Wait note: There's possibility that the completions are being triggered for argument after run. That means COMP_WORDS length equals 3, so $COMP_WORDS[0]="ollama", [1]="run" and [2] is partially typed prefix.

We need to check if "$COMP_CWORD" -eq 2? But then our model position is the second word is run? Wait: How does bash completion indexing work?
- COMP_WORDS index: The number of words equals count. If we have "ollama run abc", then COMP_WORDS length is 3. So $COMP_WORDS[0] = ollama, $COMP_WORDS[1]=run, and $COMP_WORDS[2] is the current incomplete word.
- The variable COMP_CWORD gives index of currently being completed word. It's usually equal to the number of arguments minus one (if you're completing last argument). So if we have 3 words then COMP_CWORD=2? Because indices: 0,1, and current is index2.

We want to trigger completions when command equals "ollama" and second argument equals "run". So check if [ "${COMP_WORDS[1]}" = "run" ] maybe. But careful: In bash completion function, COMP_WORDS is an array that starts at index 0. Use ${COMP_WORDS[*]}.
- Condition: If "$COMP_CWORD" is not equal to 2? Actually, let's consider:
-- When we type "ollama run ", then there are two words, and the currently being completed word is the model name (the third argument) with index $COMP_CWORD = 2. But what if user types only "ollama"? Then COMP_CWORD=0 and it wouldn't match.
- So to trigger our function, check: If "$COMP_WORDS[1]" equals run then complete. Alternatively, we can check the number of words length is at least 3 (or equals exactly 3). But what if user types more than three words? Not likely.
- So condition: if [ "${COMP_WORDS[1]}" != "run" ]; then return; fi.

Now retrieving models:
We want to run `ollama list` and capture its full output in a variable. We want safe pattern that doesn't pipe directly into while read loop. Option 1: Use command substitution capturing result into a variable, e.g., "models=$(ollama list)".
- But caution: If ollama list fails, then we silently do nothing.

So check if models is non-empty? But also error handling: If command fails, the $? status code will be non-zero. So we can use something like:

models_output=$(ollama list 2>/dev/null)  maybe.
But requirement says "if ollama list fails or errors, silently return with no completions". So if models_output is empty, then do nothing.

We need to iterate over the words in models_output. But note that output might be separated by newlines OR whitespace. Possibly we can split on IFS= line break characters? We can simply use `readarray` but requirement says only built-in shell features, so we can use: 
- Set IFS to newline and then read lines into an array.
- Alternatively, do something like "for model in $models_output; do ..." But careful: if models are separated by whitespace (and sometimes newlines), then for loop over "$models_output" will iterate with splitting on IFS. But requirement says not to pipe directly into while read loop. But we can use the safe pattern: assign variable and iterate using "for model in $var". But note that "ollama list" output might have spaces if printed space separated? But then for loop would treat each word as one argument.

However, there is a pitfall: what if some model name has whitespace? Possibly not needed since it's a simple completions.
We can do:
```
models_output=$(ollama list 2>/dev/null)
if [ -z "$models_output" ]; then
    return
fi
# Use an array to store models. We'll iterate over each word of the output.
mapfile -t model_array <<< "$models_output"
```
But requirement says do not use external parsing helpers: mapfile is built-in in bash? It's a bash builtin in many shells. But check if it's considered allowed? The requirement said "dependency-free" but only using Bash built-ins. mapfile is part of Bash 4+ and is built-in? Possibly yes.
Alternatively, we can do:
```
IFS=$'\n'
set -- $models_output
...
unset IFS
```
But that might conflict with global IFS. It's safer to use: "readarray -t models_array <<< "$models_output"" but then readarray is a bash builtin?
Wait, requirement says not to pipe `ollama list` directly into while read loop because that creates subshell and loses populated arrays.
We want safe pattern: store output in variable then iterate over it using shell's internal splitting. Possibly use:
```
IFS=$'\n'
models=($models_output)
unset IFS
```
Yes, that's safe.
But careful: The requirement "Do NOT pipe ollama list directly into a while read loop" might refer to not doing `ollama list | while read model ...` but using array assignment is allowed.

Now we need prefix filtering:
- Current word being completed is $COMP_WORDS[2] (the current incomplete argument). So prefix = ${COMP_WORDS[2]}.
- Then filter models that start with this prefix. We can do case-insensitive matching? Requirements do not mention case sensitivity, so maybe exact match from beginning of string?
We can use bash parameter expansion substring check: if [[ "$model" == "${prefix}"* ]]; then candidate.
But requirement said "matching the prefix". So we do exactly that.

Now sorting:
If there are multiple matches, sort them alphabetically before assigning to COMPREPLY.
- To sort array elements alphabetically in Bash without external tools: We can use "sort" command? But that is an external dependency. But maybe we can implement a simple bubble-sort or using built-in sort?
We want not to call external commands like sort. The requirement said no external dependencies, so we cannot call "sort". How do we sort alphabetically in bash with only built-ins? We have arrays. 
We can write our own sorting function using the shell built-in "printf" and then "readarray", but that would require sort command.
Alternatively, maybe we can use bash parameter expansion to compare strings lexicographically using "if [[ "$a" < "$b" ]]" but that's not reliable for alphabetical order because it uses ASCII ordering. But if models are all lowercase letters then that is fine. But sometimes uppercase? 
We need a safe built-in method.
Alternatively, we can use "sort -z" but that's external.

Maybe simpler: since number of models is likely small (a list of installed models), we can implement a simple sorting algorithm using shell built-ins. We could do bubble sort on an array. That might be acceptable because it's dependency-free and uses only bash builtins.
Alternatively, if the number of completions is low, maybe we don't need to do sorting for 2 or 3 items. But requirement says "if there are multiple matches, sort them alphabetically". 
We can implement a simple sort function in shell: iterate over array elements, and then compare two adjacent ones with "if [[ "$a" > "$b" ]]" (string comparison) but bash doesn't have built-in numeric sorting of strings. But we do have string comparison operators like < and > for lexicographical order?
Yes, Bash supports if [[ "$a" < "$b" ]] which compares as dictionary order. So that should be fine.
I can implement a simple bubble sort:
```
sorted=()
# copy matches to sorted array
for m in "${matches[@]}"; do sorted+=("$m"); done

n=${#sorted[@]}
bubble_sort: while true; do swapped=false; for ((i=0;i<n-1;i++)); do if [[ ${sorted[i]} > ${sorted[i+1]} ]]; then swap them and set swapped=true fi; done; if ! swapped; break; fi; done
```
We can use a function or inline code block.
Alternatively, we can store the matches in an array then sort using a simple loop.

Plan: 
- Create an array for matches.
- For each model in models array (which is from "ollama list" output), if it begins with the prefix (maybe case sensitive?), then add it to matches.
- Then perform bubble sort on the matches array.
- Then assign COMPREPLY array as sorted matches.

But note: Use compgen? The instructions said "Populate COMPREPLY correctly using compgen or manual filtering." But we want a dynamic completion that uses our own filter. But maybe we can use compgen -W if we generate a string of sorted completions joined by space, but requirement says "sort them alphabetically" so best to create array and then sort it.

I can do: 
```
matches=()
for model in "${models[@]}"; do
    prefix=${COMP_WORDS[2]}
    if [[ "$model" == $prefix* ]]; then
         matches+=("$model")
    fi
done

# Bubble sort the matches array:
n=${#matches[@]}
swapped=true
while $swapped; do
  swapped=false
  for ((i=0;i<n-1;i++)); do
    if [[ "${matches[$i]}" > "${matches[$((i+1))]}" ]]; then
       tmp="${matches[$i]}"
       matches[$i]="${matches[$((i+1))]}"
       matches[$((i+1))]="$tmp"
       swapped=true
    fi
  done
done

COMPREPLY=("${matches[@]}")
```
That should work.

But wait: If ollama list fails, then models_output is empty. So we need to check if "models" array is empty and return. But also if there's an error with command substitution? Possibly we can capture the exit code of $(ollama list 2>/dev/null) but in bash command substitution, the exit code is not preserved. Actually, command substitution returns 0 even if the command fails? Let me check: In bash, command substitution returns the exit status of the command if it's successful. But if ollama list fails, then maybe models_output would be empty. So we can do:
```
models=$(ollama list 2>/dev/null)
if [ -z "$models" ]; then
    return 0
fi
```
Yes.

We also need to store the completions in COMPREPLY variable. The function should end with: COMPREPLY=... then return 0.

Also instructions require wiring the completion using "complete -F _ollama_completion ollama".

Then include installation instructions as a comment at the bottom:
For example:
```
# Save this file as /etc/bash_completion.d/ollama or ~/.bash_completion, and source it in your .bashrc.
# For immediate activation: source /path/to/this/file
```

I'll produce a single script that includes the function definition _ollama_run_completion (or maybe _ollama_completion?) and then "complete -F _ollama_completion ollama" at bottom.

I must include in-line comments explaining key parts, especially prefix filtering and failure handling. Also instructions on where to save it and how to activate immediately.

Now I'll produce a script:

```
#!/bin/bash
# Bash completion function for 'ollama run <model>'
_ollama_run_completion() {
    # Check if the second word is "run"
    local cur prev words cword
    COMPREPLY=()
    cur=${COMP_WORDS[2]}
    # If not running "ollama run", return silently.
    if [ "${COMP_WORDS[1]}" != "run" ]; then
        return 0
    fi

    # Retrieve models from 'ollama list'; capture output into variable.
    local model_list out models=()
    # Run the command and redirect stderr to /dev/null for graceful failure.
    model_list=$(ollama list 2>/dev/null)

    # If ollama list failed or returned empty, exit silently.
    if [ -z "$model_list" ]; then
        return 0
    fi

    # Split the output into an array. Use IFS to split on newline.
    # Save original IFS.
    local IFS_old=$IFS
    IFS=$'\n'
    models=($model_list)
    IFS=$IFS_old

    # Filter models based on current prefix (cur).
    local matches=()
    for m in "${models[@]}"; do
        if [[ "$m" == $cur* ]]; then  # match if model starts with the prefix.
            matches+=("$m")
        fi
    done

    # Sort the matches array alphabetically using a simple bubble sort (only built-ins).
    local n=${#matches[@]}
    local swapped=true
    while $swapped; do
        swapped=false
        for (( i=0; i<n-1; i++ )); do
            if [[ "${matches[i]}" > "${matches[$((i+1))]}" ]]; then
                # Swap elements.
                tmp="${matches[i]}"
                matches[i]="${matches[$((i+1))]}"
                matches[$((i+1))]="$tmp"
                swapped=true
            fi
        done
    done

    COMPREPLY=("${matches[@]}")
}

complete -F _ollama_run_completion ollama
```
But note: In bash completion functions, the variable names are sometimes used as:
```
_ollama_run_completion() {
   local cur=${COMP_WORDS[2]}
}
```
I must ensure correct indexing. COMP_WORDS is an array of words in the current command line.
The first element (index 0) is the command name (ollama), index1 is run, index2 is the argument for the model.

I'll include comments explaining prefix filtering and graceful failure handling.

Then I add installation instructions as a comment at bottom:
```
# Installation: Save this file to ~/.bash_completion.d/ollama_completion.sh or /etc/bash_completion.d/ollama_completion.sh.
# Then, ensure it's sourced in your .bashrc, e.g., by adding: if [ -f /etc/bash_completion ]; then . /etc/bash_completion; fi
```
That should be enough.

I'll produce the script text. We want to output exactly a script with no markdown formatting because instructions said "By default do not use markdown unless requested." But instructions said "by default do not reply with markdown formatting", but now I'm allowed to produce plain text code block maybe.

I must include in-line comments and installation instructions at end.
I'll produce final answer.</think>#!/bin/bash
# This bash completion function provides dynamic completions for the command:
#   ollama run <model>
#
# It only triggers when "ollama run" is used, and it dynamically retrieves the list
# of available models by running "ollama list". The output is then filtered based on the
# current word (the user’s partial input) and sorted alphabetically using only bash built‐ins.
#
# Installation:
#   • Save this file as ~/.bash_completion.d/ollama_completion.sh or in /etc/bash_completion.d/
#     (depending on your system configuration).
#   • Ensure that your .bashrc sources the directory; for example, add:
#         if [ -d /etc/bash_completion.d ]; then
#             for f in /etc/bash_completion.d/*; do
#                 [ -r "$f" ] && . "$f"
#             done
#         fi
#   • For immediate activation, source the file:
#         source ~/.bash_completion.d/ollama_completion.sh

_ollama_run_completion() {
    # Retrieve the current partial word (the model name so far)
    local cur=${COMP_WORDS[2]}

    # Only provide completions if the command is "ollama run"
    if [ "${COMP_WORDS[1]}" != "run" ]; then
        return 0
    fi

    # Capture the output of 'ollama list' into a variable.
    # Redirect stderr to /dev/null so that errors are handled gracefully.
    local model_list
    model_list=$(ollama list 2>/dev/null)

    # If 'ollama list' fails or returns no data, exit silently (no completions)
    if [ -z "$model_list" ]; then
        return 0
    fi

    # Split the output into an array.
    # Save original IFS and set it to newline so that splitting works correctly.
    local old_ifs="$IFS"
    IFS=$'\n'
    mapfile -t models < <(echo "$model_list")
    IFS="$old_ifs"

    # Filter models: add a model to the matches array if its name starts with the current prefix.
    local matches=()
    for m in "${models[@]}"; do
        if [[ "$m" == $cur* ]]; then
            matches+=("$m")
        fi
    done

    # Sort the filtered matches alphabetically using a simple bubble sort (using only built-in comparisons).
    local n=${#matches[@]}
    local swapped=true
    while $swapped; do
        swapped=false
        for (( i=0; i<n-1; i++ )); do
            if [[ "${matches[i]}" > "${matches[$((i+1))]}" ]]; then
                # Swap the two elements.
                tmp="${matches[i]}"
                matches[i]="${matches[$((i+1))]}"
                matches[$((i+1))]="$tmp"
                swapped=true
            fi
        done
    done

    # Populate the COMPREPLY array with sorted completions.
    COMPREPLY=("${matches[@]}")
}

# Register the completion function for the "ollama" command.
complete -F _ollama_run_completion ollama

