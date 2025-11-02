<think>We have instructions from the system message: "You are a concise shell scripting assistant." We need to output a working bash-completion script for command `ollama run <model>` that dynamically lists available models by parsing the output of `ollama list` without using any external dependencies. Requirements:
- When user types `ollama run <Tab>` or partially types a model name, completion should suggest matching completions filtered by current prefix.
- No reliance on jq or third party tool; use built-in shell string manipulation and arrays.
- Handle case where `ollama list` fails (e.g., command not found or error) by silently returning no completions.
- Provide minimal but clear installation instructions: Where to drop source the script, how to activate it immediately.

Constraints:
- Only output the shell script with comments plus installation instructions. No unrelated explanation. It should be robust and idiomatic and minimal.

Let's produce a bash completion script for command "ollama run". The syntax typically uses _ollama_run function definition. We want to parse available models by calling `ollama list` which prints model names separated by whitespace or newlines. Possibly need to capture output from that, but we want to robustly check error conditions.

We can produce a bash completion function using COMP_WORDS and COMP_CWORD. For a command with syntax "ollama run <model>", the number of words should be 2 if the user typed only "ollama" then "run", or 3 if model is present. But also note that we need to complete when user types "ollama run", i.e. after the second token, so if COMP_CWORD equals 2, then completion suggestions are available for models. So script should check: if number of words is exactly equal to 2 (or less than 3?) Actually, the command is "ollama run <model>", meaning that user types "ollama run", and then tab completion should suggest possible completions from available models.

Let's produce a script function:
```
_ollama_run() {
    local cur prev words cword
    # read current word from COMP_WORDS array at index COMP_CWORD
    _get_comp_words_by_ref -n : cur prev words cword

    local available_models=()
    if ! output=$(command ollama list 2>/dev/null); then
         return 0
    fi

    # parse each line of output into an element in array
    while read -r model; do
        available_models+=("$model")
    done <<< "$output"

    local suggestions=()
    for model in "${available_models[@]}"; do
         case "$cur" in
             $model) suggestions+=( "$model" );;
             ${model%%${cur}*}) suggestions+=( "$model" );;  # pattern matching?
         esac
    done

    COMPREPLY=( $(compgen -W "$(printf "%s " "${available_models[@]}")" -- "$cur" ) )

}
complete -F _ollama_run ollama
```
But we need to check the command structure. Wait careful: the completion function should be for argument after "ollama run". But typical Bash completion functions rely on checking that COMP_WORDS[1] equals "run"? In our case, if the user typed only "ollama", then tab completion may not complete it; or when they type exactly two tokens ("ollama run"), then we want to list completions for third token. So in our function we check if length of words is 2 (or less) and if COMP_WORDS[1] equals "run"? Possibly use "if [[ $COMP_CWORD -eq 2 && ${COMP_WORDS[1]} == 'run' ]]; then" or something like that.

We want to support dynamic completions only for the subcommand "run". So our function can do:
```
_ollama_run() {
    local cur prev words cword
    _get_comp_words_by_ref -n : cur prev words cword

    # Only complete when user typed "ollama run"
    if [[ ${#words[@]} -lt 3 ]]; then
         return
    fi

    # Get list of models from ollama list. If command fails, silently no completions.
    local output
    if ! output=$(command ollama list 2>/dev/null); then
         return
    fi

    local model_list=()
    while IFS= read -r line; do
         # Remove trailing newline etc.
         [ -z "$line" ] || model_list+=("$line")
    done <<< "$output"

    COMPREPLY=( $(compgen -W "$(printf '%s ' "${model_list[@]}")" -- "$cur") )
}
complete -F _ollama_run ollama
```
But wait, we need to check if $COMP_CWORD equals 2? Actually, the command "ollama run <model>" means that after typing "ollama run", the token count is 3. But sometimes user might have typed only two tokens: "ollama run" with no third argument. But in bash completion function, if the user types "ollama run", then COMP_CWORD=2, but the last word is empty string? Actually, by default, when we complete, the current word should be blank. So our function should use $COMP_CWORD to determine which parameter we're completing. In typical pattern, you want to complete only if ${COMP_WORDS[1]} equals "run". But what's common: "if [[ ${#words[@]} -eq 2 ]]; then" means that user typed just "ollama run". Alternatively, check if the second word is "run", then we complete third argument. So logic can be:

```
_ollama_run() {
    local cur=${COMP_WORDS[COMP_CWORD]}
    # Only complete if we are on the <model> parameter (third word)
    if [[ ${#COMP_WORDS[@]} -lt 3 ]]; then
         return
    fi

    # Check that second word is "run"
    if [[ "${COMP_WORDS[1]}" != run ]]; then
         return
    fi

    local output
    if ! output=$(command ollama list 2>/dev/null); then
         return
    fi

    COMPREPLY=( $(compgen -W "$output" -- "$cur") )
}
complete -F _ollama_run ollama run
```
Wait, careful: The completion function should be registered with command "ollama", but maybe "complete -F _ollama_run ollama" and then use if condition inside to check if subcommand is "run". But the problem statement says for command "ollama run <model>", so completions are only valid when subcommand is "run".

We can also register it as: 
```
complete -F _ollama_run ollama
```
But then in function we check that if COMP_WORDS[1] != run then return.

Alternatively, we want to complete only for the specific invocation "ollama run". So we check if ${#COMP_WORDS[@]} is 2 and ${COMP_WORDS[1]} equals "run", or if it's greater than 2. But careful: When user types "ollama run <model>" with a partial model, COMP_CWORD=3. So our function should complete only when argument index (i.e., last word) is third token.

So, inside the completion function:
```
if [[ $COMP_CWORD -eq 2 ]]; then
    # When user typed "ollama run" and pressing tab completes first parameter of model name.
else if COMP_CWORD > 2
   Then still we want to complete the model name?
```
Wait check: Actually, in bash completions, when you type a command with more than one argument, the current token is always the last argument. But here "ollama run" already has two tokens. The first token is fixed "ollama", second token "run". So if user only typed "ollama run", then COMP_CWORD will be 2? Actually wait: The number of words in COMP_WORDS equals number of arguments that have been provided. When the user types "ollama run" and then hits tab, it's two tokens so far. But then we are completing for the next token (the model) which is not yet typed, so COMP_CWORD should be 2? Let's check: For example, when command is "command subcmd arg", after typing "command subcmd", what is COMP_CWORD? Usually it equals 2 if no third argument typed. But then completion function runs with COMP_WORDS[0]="ollama", COMP_WORDS[1]="run", and current word (cur) is empty string because the user hasn't provided any text for the third token yet. And COMP_CWORD equals 2, so then in our function we want to complete? Yes, we want to complete only when second argument equals "run". So condition: if [[ ${COMP_WORDS[1]} != run ]]; return. So that's the check.

Then we parse output from `ollama list` into available models array.
We can store them in an array, but it's simpler to use compgen -W "$output" -- "$cur" because $output is whitespace separated strings. But careful: Output might have newlines? But it says "prints model names one per line or separated by whitespace". We want to use built-in string manipulation. We can either call read with while read, then build an array.

But we cannot assume arrays in older shell environments that are not bash 4. But we are told to produce a working bash-completion script for a given command using Bash. So it's safe to use arrays (bash 4 required).

We need to robustly check: if "ollama list" fails, then return no completions.

So code:
```
_ollama_run() {
    local cur=${COMP_WORDS[COMP_CWORD]}
    # Only complete when second argument is 'run'
    if [[ ${#COMP_WORDS[@]} -ge 2 && "${COMP_WORDS[1]}" != "run" ]]; then
        return 0
    fi

    local models=()
    # Get output from ollama list, ignoring errors.
    local out
    if ! out=$(command ollama list 2>/dev/null); then
         return 0
    fi

    # Parse each line or whitespace token into array:
    while read -r model; do
        [ -z "$model" ] || models+=("$model")
    done <<< "$out"

    COMPREPLY=( $(compgen -W "$(printf '%s ' "${models[@]}")" -- "$cur") )
}
complete -F _ollama_run ollama run
```
That is a complete function. We can add some comments.

I need to be careful: Our script should check if the user typed only "ollama run", then COMPREPLY will contain completions for model names matching prefix empty string, which means all models from list. Alternatively, if user partially types a model name, that works as well.

Also instructions: Provide minimal but clear installation instructions at the end. So after script code, output something like:
```
# Installation Instructions:
# Save this file as ollama-completion.bash and source it in your ~/.bashrc or profile.
# Example: 
#   . /path/to/ollama-completion.bash
# Or add to your ~/.bash_completion.d directory if available.
```

We need to output only the shell script with comments plus installation instructions. So we can produce a single file that contains these lines at end.

I'll produce something like:

```
#!/usr/bin/env bash
#
# Bash completion for "ollama run <model>"
#
_ollama_run() {
    # Retrieve current word (partial argument) from COMP_WORDS.
    local cur="${COMP_WORDS[COMP_CWORD]}"
    # Only complete when user typed "ollama run"
    if [[ ${#COMP_WORDS[@]} -ge 2 && "${COMP_WORDS[1]}" != "run" ]]; then
        return 0
    fi

    # Get available models by running "ollama list", ignoring errors.
    local out
    if ! out=$(command ollama list 2>/dev/null); then
        return 0
    fi

    local models=()
    while read -r model; do
        [ -z "$model" ] || models+=("$model")
    done <<< "$out"

    COMPREPLY=( $(compgen -W "$(printf '%s ' "${models[@]}")" -- "$cur") )
}
complete -F _ollama_run ollama run

# Installation/Activation Instructions:
# 1. Save this script as "ollama-completion.bash".
# 2. Source it from your shell configuration (e.g., ~/.bashrc or ~/.profile):
#       . /path/to/ollama-completion.bash
# 3. Restart your terminal or source your configuration file to activate completions.
```
That seems sufficient.

I'll now produce final answer accordingly.

I must output the script with comments plus installation instructions in plain text. I'll now produce answer accordingly. We'll produce a solution accordingly.

I'll produce the final answer in plain text, no markdown formatting as default? The instruction says "By default do not reply using Markdown unless requested." But instructions say: "Do not add unrelated explanation" so we need only script plus installation instructions.

I'll output final answer accordingly.

I'll now produce final answer. We'll produce final answer accordingly in plain text with comments.</think>#!/usr/bin/env bash
#
# Bash completion for the command "ollama run <model>"
# This function dynamically lists available models by parsing the output of "ollama list".
# It filters completions based on the current word and handles errors silently.
#

_ollama_run() {
    # Get the current word being completed.
    local cur="${COMP_WORDS[COMP_CWORD]}"
    
    # Only complete if the user has typed "ollama run"
    if [[ ${#COMP_WORDS[@]} -ge 2 && "${COMP_WORDS[1]}" != "run" ]]; then
        return 0
    fi

    # Capture output from "ollama list", ignoring any errors.
    local out
    if ! out=$(command ollama list 2>/dev/null); then
        return 0
    fi

    # Parse each line (or whitespace separated token) into an array.
    local models=()
    while read -r model; do
        [ -z "$model" ] || models+=("$model")
    done <<< "$out"

    # Generate completion suggestions matching the current word prefix.
    COMPREPLY=( $(compgen -W "$(printf '%s ' "${models[@]}")" -- "$cur") )
}

complete -F _ollama_run ollama run

# Installation/Activation Instructions:
#
# 1. Save this script as "ollama-completion.bash".
# 2. Source it in your shell configuration file (e.g., ~/.bashrc or ~/.profile):
#
#      . /path/to/ollama-completion.bash
#
# 3. Reload your shell configuration (or restart your terminal) for the changes to take effect.
#    Alternatively, you can immediately source the script:
#
#      source /path/to/ollama-completion.bash

