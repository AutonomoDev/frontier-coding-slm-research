<think>We are asked: "Create a bash-completion function for `ollama run <model>` that dynamically lists available models by parsing the output of `ollama list`." The requirements:
1. Trigger condition: Only offer completions when command is `ollama run` and user is completing after `run`.
2. Model retrieval: Invoke `ollama list` once and capture its full output into a variable. Do not pipe directly; use safe pattern.
3. Prefix filtering: Use the current word being completed (from COMP_WORDS/COMP_CWORD) to filter model names so only those matching prefix are suggested. Populate COMPREPLY correctly using compgen or manual filtering.
4. Graceful failure: If ollama list fails or errors, silently return with no completions (do not produce errors).
5. Sorting: If there are multiple matches, sort them alphabetically before assigning to COMPREPLY.
6. No external dependencies: Only use Bash built-ins; do not call jq, awk, etc.
7. Installation instructions.

We output a working, dependency-free bash-completion script for a given command. The output must be just the script with inline comments plus very brief installation/activation instructions at the end. Do not include any extra explanation.

Let's write a function: "ollama_run_completion()". It should check if we are completing after "run" argument, i.e. $COMP_CWORD and $COMP_WORDS array. Possibly using "$COMP_WORDS[1]"? Actually careful:

We need to complete command "ollama run <model>" So when user types `ollama run`, then the number of words is 3 (if model is present) else if we haven't provided model, word count equals 2 maybe, but it's always triggered after the command "run".

Maybe check: if [ "$COMP_CWORD" -eq 2 ] then the previous argument is 'run'? Actually let’s do this:
```
ollama_run_completion() {
    # Only complete if at least two words are provided and second word equals run
    local cur prev words count output models sorted_models i
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    if [ "$prev" != "run" ]; then
        return 0
    fi
}
```
But careful: The prompt said "when completing after run". So the last command word is always the model. However, what's the trigger? Possibly when the user types "ollama run", then COMP_CWORD equals 2 if they type a space at end? But it's not clear how to check trigger.

We could simply check: if [ ${COMP_WORDS[1]} != "run" ]; then return; else proceed.
But what about the case where model is not complete or not provided. We can do:
```
if [ "${COMP_CWORD}" -eq 2 ] ; then # user typed 'ollama run' and now completing first argument after run
   ...
fi
```
But careful: Actually, we need to check that "run" is the second word. So we have:
```
if [ "$COMP_WORDS[1]" != "run" ]; then return; fi
```
This ensures the completion function only triggers if command line has "ollama run".

Then retrieve models using a variable capturing output of `ollama list`:
```
models_output=$(ollama list 2>/dev/null)
if [ $? -ne 0 ] || [ -z "$models_output" ]; then
   return  # silently fail on error.
fi
```
But wait: requirement says "silently return with no completions if ollama list fails or errors, do not produce errors". So best is:
```
models=$(ollama list)
if [ $? != 0 ] || [ -z "$models" ]; then
   return
fi
```

Then parse models. Requirement: "Assume `ollama list` prints model names one per line or separated by whitespace." So we can use a space-splitting using read. But careful: We must store the output in variable and then iterate over it.
We want to split lines into an array? Use "mapfile" but that's built-in?
Actually "readarray" is not guaranteed on all shells, so better to do: 
```
models_array=()
for model in $models; do
    models_array+=("$model")
done
```
But careful: if the output is separated by whitespace, splitting on space might break multi-word names? But maybe we assume each model name is a single word. The prompt says "Assume ... prints model names one per line or separated by whitespace." So yes.

After that, get prefix to complete from current word being completed:
```
prefix=${COMP_WORDS[2]}
```
But careful: if user hasn't typed any characters after run, then prefix might be empty. But we want only matches of the prefix.
Now filter models_array for those starting with $prefix:

We can do manual filtering using a loop and "case" or parameter expansion.

For each model in models_array, check if "$model" starts with prefix: 
```
if [[ "$model" == ${prefix}* ]]; then
   match_models+=("$model")
fi
```

Sort them alphabetically. But requirement: "sort them alphabetically". Bash built-in array sorting is not trivial. We can use "sorted=($(printf '%s\n' "${match_models[@]}" | sort))", but that uses external command "sort"? The question says "no external dependencies" and only use bash built-ins, no external parsing helpers. But maybe using sort from within the script: Wait requirement states: "Only use Bash built-ins; do not call jq, awk, or any external parsing helpers." It does not explicitly say "do not call external commands", but it's ambiguous. Actually, we have to check the instructions: "No external dependencies: Only use Bash built-ins". So that means no external command like sort maybe? But sorting in bash arrays can be done by using a function or manual algorithm.

We want alphabetical order. We can implement an insertion sort manually on array of strings. Possibly write a small sort function using shell built-in "printf" and "sort"? Alternatively, since the number of models is probably not huge, we could do: "sorted=$(printf '%s\n' "${match_models[@]}" | LC_ALL=C sort)" but that uses external command sort. But requirement states "only use bash built-ins", I'm not sure if calling sort qualifies as an external dependency because it's a standard utility in GNU? The instruction says "do NOT call jq or awk, or any external parsing helpers" and doesn't mention sort. However, many completions scripts are allowed to call sort. But then "only use Bash built-ins", maybe that implies no external commands at all. Let me re-read requirement #6: "No external dependencies: Only use Bash built-ins; do not call jq, awk, or any external parsing helpers." So it's specifically against using external tools for JSON parsing? It doesn't mention sort explicitly. But I think using sort is acceptable because it is a common Unix command. However, if we are allowed to only use Bash builtins, then the safe pattern might be to iterate over match_models and do manual sorting? Alternatively, since there can be small number of models, maybe we can do: 
```
sorted=()
for model in "${match_models[@]}"; do
  sorted+=("$model")
done
# Now sort manually (e.g., using array indices)
```
But implementing a stable sort in bash is not trivial. Alternatively, use "printf '%s\n' ... | sort" which uses external command sort but is available on most systems. But requirement #6 might be interpreted as "don't call any non-Bash built-in utilities" so perhaps we must implement sorting using shell built-ins. However, instructions say: "No external dependencies", and then "Only use Bash built-ins; do not call jq, awk, or any external parsing helpers." That seems to imply that sort is not allowed if it's considered an external command.

However, I'm not 100% sure because many bash completions scripts rely on external commands like compgen. But we must check: "comp_gen" is built-in. We can do manual sorting algorithm in Bash? Possibly use bubble sort or insertion sort on array elements. The number of models might be small. Let's attempt a simple shell implementation of quicksort maybe using built-in arithmetic? But that requires recursion which might not be trivial.

Alternatively, we could use "compgen -W" to provide completions from the list and then let bash's compgen handle sorting? Actually, "compgen -A function ..." no. Alternatively, I can simply compute prefix filtering manually then use array sort algorithm using a loop for each element. For example, implement an insertion sort: 
```
sorted=()
for m in "${match_models[@]}"; do
    inserted=false
    for (( j=0; j<${#sorted[@]}; j++ )); do
         if [[ "$m" < "${sorted[j]}" ]]; then
             # Insert before element j
             sorted=( "${sorted[@]:0:j}" "$m" "${sorted[@]:j}" )
             inserted=true
             break
         fi
    done
    if [ "$inserted" = false ]; then
        sorted+=("$m")
    fi
done
```
This is a built-in method to sort array alphabetically. But that's a bit more code. And requirement states "Only use Bash built-ins; do not call jq, awk or any external parsing helpers." It doesn't mention sort specifically. I think we are allowed to use external commands like sort if necessary. However, the instructions say "dependency-free bash-completion script", so I assume no external dependency means that even if sort is present in many systems, it's not built-in. But then what do we do? The instructions require sorting alphabetically before assigning to COMPREPLY.

We can use "printf '%s\n' "${match_models[@]}" | LC_ALL=C sort" but that calls external command sort which is not allowed by requirement #6 if interpreted strictly because it says no external dependencies.

Let me re-read instruction: "No external dependencies: Only use Bash built-ins; do not call jq, awk, or any external parsing helpers." That likely means we can't use external tools like jq or awk for JSON parsing. It doesn't necessarily mean sort is forbidden, but if it's strictly no external commands then maybe we must implement our own sorting algorithm.

We'll try implementing a simple insertion sort using built-in shell arrays and string comparisons (using [[ "$a" < "$b" ]] works in bash). That might be acceptable. But note that comparing strings with "<" operator is not portable but it's allowed in bash. I can do:
```
sorted=()
for model in "${match_models[@]}"; do
    inserted=false
    for ((i=0; i<${#sorted[@]}; i++)); do
        if [[ "$model" < "${sorted[i]}" ]]; then
            # Insert before element i.
            sorted=( "${sorted[@]:0:i}" "$model" "${sorted[@]:i}" )
            inserted=true
            break
        fi
    done
    if [ "$inserted" = false ]; then
        sorted+=( "$model" )
    fi
done
```
That will yield a sorted array in lexicographic order.

Alternatively, we can do something like:
```
sorted_models=()
for model in "${match_models[@]}"; do
   for ((i=0; i<${#sorted_models[@]}; i++)); do
       if [[ "$model" < "${sorted_models[i]}" ]]; then
         # Insert before element i.
         sorted_models=( "${sorted_models[@]:0:i}" "$model" "${sorted_models[@]:i}" )
         break
       fi
   done
   [ $i -ge ${#sorted_models[@]} ] && sorted_models+=( "$model" )
done
```
That looks fine.

After sorting, we want to assign to COMPREPLY:
```
COMPREPLY=( $(compgen -W "${sorted}" -- "$cur") )
```
But then requirement says "populate COMPREPLY correctly using compgen or manual filtering." So that's acceptable.

Then complete function returns.
At the end, include completion wiring: `complete -F ollama_run_completion ollama`

Installation instructions at bottom as comment lines.

We want just the script code with inline comments. So I'll output a single file containing the function and installation instructions.

Let's produce code:

```
#!/bin/bash
# Bash-completion for 'ollama run <model>'
# This function dynamically lists available models by parsing the output of `ollama list`.
# It only triggers completions when completing after "run".
ollama_run_completion() {
    # Only trigger completion if at least 3 words are present and second word is "run"
    local cur prev
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    
    # Check if previous argument is 'run'
    if [ "$prev" != "run" ]; then
        return 0
    fi

    # Retrieve the list of models from `ollama list` into a variable.
    # Redirect errors to /dev/null for graceful failure.
    local output models_arr match_models sorted_models i j temp
    output=$(ollama list 2>/dev/null)
    
    # If ollama list fails or returns empty output, do not offer completions.
    if [ -z "$output" ]; then
        return 0
    fi

    # Populate an array with model names from the output.
    # Splitting on whitespace (models are either one per line or separated by spaces).
    models_arr=()
    for model in $output; do
        models_arr+=("$model")
    done
    
    # Get the current word being completed (the prefix)
    local prefix="${COMP_WORDS[2]}"
    
    # Filter models that start with the prefix.
    match_models=()
    for model in "${models_arr[@]}"; do
        if [[ "$model" == ${prefix}* ]]; then
            match_models+=("$model")
        fi
    done

    # Sort matched models alphabetically using a simple insertion sort (built-in only).
    sorted_models=()
    for model in "${match_models[@]}"; do
        inserted=false
        # Iterate over the sorted_models array to find insert position.
        for ((i = 0; i < ${#sorted_models[@]}; i++)); do
            if [[ "$model" < "${sorted_models[i]}" ]]; then
                # Insert model before element i.
                sorted_models=( "${sorted_models[@]:0:i}" "$model" "${sorted_models[@]:i}" )
                inserted=true
                break
            fi
        done
        # If not inserted, append at the end.
        if [ "$inserted" = false ]; then
            sorted_models+=("$model")
        fi
    done

    # Generate completions using compgen with the sorted list as the word list.
    COMPREPLY=( $(compgen -W "${sorted_models[*]}" -- "$cur") )
}

# Register the completion function for 'ollama'
complete -F ollama_run_completion ollama

# Installation/Activation:
# 1. Save this script to a file, e.g., /etc/bash_completion.d/ollama-run.bash.
# 2. Source it in your shell or add "source /path/to/script" to your ~/.bashrc.
# 3. Reload your bash configuration (e.g., source ~/.bashrc).
```

That satisfies the requirements.

I'll now produce answer with code and then explanation? Actually instructions say: "Output just the script with inline comments plus very brief installation/activation instructions at the end." So I'll output the entire script exactly as required.

I must not provide any other additional text, aside from the instructions. Also must include "Installation/Activation snippet at bottom".

I'll now produce answer in plain text code block (but by default no markdown formatting unless requested) but instructions say: "By default do not reply with Markdown formatting" so I must output plain text.

I need to check if my script adheres strictly:
- It only triggers when second argument is run. But what about the case when there are fewer than three words? Actually, COMP_WORDS array indices start from 1 in many shells but in bash they start at index0 usually? Let me recall: In bash completions, COMP_WORDS[0] contains the command name (ollama) and COMP_WORDS[1] is "run", and COMP_WORDS[2] is the current argument. So if you type "ollama run" with no extra characters, then COMP_CWORD might be 2? Actually, let me check: When completing after "run", COMP_CWORD is 2 because indexing starts at 0 for command name, so that makes sense.

- In our script, we use COMP_WORDS[COMP_CWORD] and COMP_WORDS[COMP_CWORD-1]. But if COMP_CWORD is 2, then COMP_WORDS[1] is "run". So it's correct.
- However, what if there are fewer than two words? Then maybe COMP_WORDS might not exist. But that's fine.

- The output of ollama list is captured in variable output, and if it's empty, completions do nothing (return 0). That is graceful failure.

- We then populate models_arr by iterating for model in "$output". But note: $output could have newlines? Because we're using "ollama list" but that might produce one line per model. Splitting on whitespace should work if each line is a separate model, assuming no spaces in model names (which I assume).
- Then we filter match_models with prefix check.

- Then sort using insertion sort built-in. That works.
- Then assign to COMPREPLY with compgen -W "sorted_models[*]" -- "$cur". But note: Using "${sorted_models[*]}" inside single quotes might not expand because of the quotes in compgen command substitution? Actually, I'm passing it as argument to compgen in a subshell. The usage is `compgen -W "option1 option2 ..." -- "$cur"`. So I want to join sorted_models array elements with space separation. I can do that by doing: "${sorted_models[*]}".

But careful: In the command substitution, we need to have quotes around them if needed. But compgen expects a list of words separated by spaces; so I'll do: $(compgen -W "${sorted_models[*]}" -- "$cur"). That is acceptable.
- The function returns implicitly after assigning COMPREPLY.

I believe this meets requirements exactly.

I'll produce answer accordingly in plain text code block.</think>#!/bin/bash
# Bash-completion for "ollama run <model>"
# This function dynamically lists available models by parsing the output of “ollama list.”
# It only triggers completions when completing after the word "run".

ollama_run_completion() {
    # Get the current word (what's being typed) and its previous word.
    local cur prev
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    # Only offer completions if the previous argument is "run"
    if [ "$prev" != "run" ]; then
        return 0
    fi

    # Retrieve the list of models from "ollama list".
    local output models_arr match_models sorted_models model i temp inserted
    output=$(ollama list 2>/dev/null)
    
    # If "ollama list" fails or returns nothing, exit gracefully.
    if [ -z "$output" ]; then
        return 0
    fi

    # Populate an array with each model name (models are expected to be whitespace‐separated).
    models_arr=()
    for model in $output; do
        models_arr+=("$model")
    done
    
    # Get the current prefix being completed.
    local prefix="${COMP_WORDS[2]}"

    # Filter out only those model names starting with the given prefix.
    match_models=()
    for model in "${models_arr[@]}"; do
        if [[ "$model" == ${prefix}* ]]; then
            match_models+=("$model")
        fi
    done

    # Sort the matched models alphabetically using a simple insertion sort (only built-in Bash commands).
    sorted_models=()
    for model in "${match_models[@]}"; do
        inserted=false
        for ((i = 0; i < ${#sorted_models[@]}; i++)); do
            if [[ "$model" < "${sorted_models[i]}" ]]; then
                # Insert "model" before the current element.
                sorted_models=( "${sorted_models[@]:0:i}" "$model" "${sorted_models[@]:i}" )
                inserted=true
                break
            fi
        done
        if [ "$inserted" = false ]; then
            sorted_models+=("$model")
        fi
    done

    # Use compgen to generate completions from the sorted list.
    COMPREPLY=( $(compgen -W "${sorted_models[*]}" -- "$cur") )
}

# Register the completion function for the "ollama" command.
complete -F ollama_run_completion ollama

# Installation/Activation:
# 1. Save this script to a file (e.g., /etc/bash_completion.d/ollama-run.bash).
# 2. Source it in your shell or add "source /path/to/script" to your ~/.bashrc.
# 3. Reload your bash configuration (for example, run: source ~/.bashrc).

