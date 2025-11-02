<think>We are asked: "You are a concise shell scripting assistant. Your job is to output a working bash-completion script for a given command. Focus on correctness and portability." We need to produce a script with the following requirements.

The task: "Create a bash-completion function for the command `ollama run <model>` that dynamically lists available models by parsing the output of `ollama list` without using any external dependencies. Assume `ollama list` prints model names one per line (or separated by whitespace) when run with no formatting flags."

Requirements:
1. When the user types "ollama run <Tab>" or partially types a model name, the completion should suggest matching model names filtered by the current prefix.
2. Do not rely on jq or any third-party tool; use only built-in shell string manipulation and arrays.
3. Handle the case where `ollama list` fails (e.g., command not found or error) by silently returning no completions.
4. Provide a minimal but clear installation instruction: where to drop/source the script and how to activate it immediately.

The output must be only the shell script plus installation instructions, with comments, and not add unrelated explanation.

We need to produce a bash-completion function that does something like: It should check if the current word is being completed (i.e., COMP_WORDS[COMP_CWORD] is "run", "model" or maybe partial model name). But note we are asked for completion of `ollama run <model>` so after command and "run" we need to complete a model name. So our bash completion function should be activated when the command name equals "ollama". And if second argument is "run", then third argument (index 2) is the model name if provided, so we need to check that.

So typical pattern for bash completion script: define _ollama_run() and then use compopt -o nospace, etc. Alternatively, define _ollama function that checks COMP_WORDS. But the question says "bash-completion function for the command ollama run <model>" That means we need to detect when the first argument is "ollama" and second argument is "run". And then use completion suggestions for model name.

The completions code should follow these steps:

- We check if COMP_WORDS[1] equals "ollama", and COMP_WORDS[2] equals "run".
- If yes, then we set the current prefix to be the third word (if present) otherwise empty.
- Then we run `ollama list` command. But we need to capture its output. The instruction says: Assume ollama list prints model names one per line or separated by whitespace when no formatting flags are used.

So, we'll get models from "ollama list" and then filter matching lines that start with the prefix (which is stored in COMP_POINT? Actually, the current word is in COMP_WORDS[COMP_CWORD]. But note: If a user uses tab completion on argument 3, then COMP_POINT might be set to beginning of model name. However, by default, we need to use "COMPREPLY" array and maybe set COMPREPLY with matching completions.

Typically, bash completion function does something like:

function _ollama_run() {
   # Check if command is "ollama run"
   local cur prev words cword
   read -a words < /dev/stdin  # but wait, we use COMP_WORDS?
   Actually, in bash completion functions we can use: local cur="${COMP_WORDS[COMP_CWORD]}" then prefix variable.

   But I must check if the first argument is "ollama" and second is "run", else do nothing.

   So:
   if [[ ${#COMP_WORDS[@]} -lt 3 ]]; then return; fi
   if [[ "${COMP_WORDS[1]}" != "ollama" ]] || [[ "${COMP_WORDS[2]}" != "run" ]]; then return; fi

   local models; maybe get the output from `ollama list 2>/dev/null` (we need to silence errors).
   Then if models variable empty, return.

   But careful: The command "ollama list" might have failure output. We want to fail gracefully by returning no completions, so we check if $? !=0 then return.

   Alternatively, we can do something like:
   local list=$(command ollama list 2>/dev/null) 
   If [ -z "$list" ]; then
         return
   fi

   Then we need to parse the output lines. But careful: The output might be a single line with whitespace separated models or multiple lines.

   We want robust completion so that each token in the "ollama list" is used as candidate.
   So, we can do something like:
   
   local IFS=$'\n'
   declare -a model_list
   for word in $list; do
     # if the output is whitespace separated words, then each word might be on same line? But we want to support both.
     # Alternatively, maybe we do: read array using mapfile or something.

   Actually, because bash arrays need to be built by reading lines. But note that "ollama list" may return text with multiple spaces. We can use "readarray" to read all lines into an array if available in bash (it is available since bash 4). But we are required for portability: Should check if we're using /dev/stdin? Actually, Bash-completion scripts usually use built-in completion functions and might rely on command substitution.

   But since the instructions said "without any external dependencies", so it's allowed to use "readarray" because that's a built-in command in bash. But maybe not on all systems (older ones)? The script may be minimal, but we are using Bash-specific features so assume it is bash.

   So:
   local models
   readarray -t models < <(ollama list 2>/dev/null)
   if [ ${#models[@]} -eq 0 ]; then
      return
   fi

   Then filter each model name that begins with the current prefix. The variable "cur" is used for completion (like the token currently being typed). But note: The token might include a trailing space? We can use case or grep.

   I'll do something like:
   local cur=${COMP_WORDS[COMP_CWORD]}
   local suggestions=()
   for m in "${models[@]}"; do
       if [[ "$m" == $cur* ]]; then
           suggestions+=("$m")
       fi
   done

   Then fill COMPREPLY with the suggestions.

   But we also need to be careful: if cur is empty, then all completions are valid. But that's fine.

   Also, note: Use compopt -o default maybe? But instructions said "Include brief installation/activation instructions at the end."

   After the function definition, we do:
   complete -F _ollama_run ollama

   But wait, our command is "ollama run <model>" not just "ollama". So should we define a completion function for command ollama but check that second argument equals "run"? Yes.

   But if the user types "ollama", then it might complete with subcommands? Possibly. We could also have completions for subcommand run, or do nothing else.

   Also note: There's a possible alternative: Instead of using readarray, we can use built-in arrays and command substitution.

   Perhaps something like:
       local models
       maps=()
       while IFS= read -r line; do
         # If the output is multiple tokens on one line (or single token per line) then add each non-empty token.
         for word in $line; do
            [ "$word" ] && suggestions+=("$word")
         done
       done < <(ollama list 2>/dev/null)
   But that might be overcomplicating things.

   I'll use readarray -t. That is standard in bash, but if not available then fallback to while read loop with command substitution.

   But instructions said "do not rely on external dependencies", so using readarray is fine because it's built-in in modern versions of Bash.
   
   Alternatively, for portability we might want to use "models=($(ollama list 2>/dev/null))". But if the output has spaces, then that won't separate correctly if there are multiple whitespace separated tokens. It might break if model names contain spaces. But instructions did not mention that possibility. They said assume one per line or separated by whitespace. So we need to support both.
   If they are on same line, splitting them with "readarray -t" would split based on newline characters. But if there is a single line with multiple models, then readarray will produce one element in the array.

   For example, if ollama list outputs:
   model1 model2 model3
   Then readarray -t will create an array with only "model1 model2 model3" as first element. And our for loop would then iterate once. But then our suggestion filtering condition would be: if [[ "$m" == $cur* ]]. But that would check whether the entire string starts with cur, but in this case it might not match because there's whitespace between them.

   So we need to account for that possibility by splitting each line into tokens using either word splitting. Perhaps we can do something like:
       local models
       readarray -t lines < <(ollama list 2>/dev/null)
       declare -a suggestions
       for line in "${lines[@]}"; do
         for m in $line; do # word-splitting will automatically split on whitespace.
            if [[ "$m" == $cur* ]]; then
                suggestions+=("$m")
            fi
         done
       done

   That would be more robust: each line is processed separately, and within each line, the words are extracted. But note that we want to avoid duplications? Possibly not necessary.

   So I'll do:
       local models=()
       readarray -t lines < <(ollama list 2>/dev/null)
       if [ ${#lines[@]} -eq 0 ]; then return; fi
       local cur=${COMP_WORDS[COMP_CWORD]}
       local suggestions=()
       for line in "${lines[@]}"; do
          for model in $line; do
              if [[ "$model" == $cur* ]]; then
                  suggestions+=("$model")
              fi
          done
       done

   Then assign COMPREPLY with ${suggestions[@]}. And then return.

   Also, I should set the local variable prefix to cur? But it's already being used.

   Also note: We need to add a compopt line to ensure that the completions are case insensitive maybe. It might be optional.

   So final script:

```
# bash-completion for ollama run <model>
_ollama_run() {
    # Check if we're completing "ollama run" subcommand
    if [[ ${COMP_CWORD} -lt 3 ]]; then
        return
    fi
    local prev_word="${COMP_WORDS[1]}"
    local cur_command="${COMP_WORDS[2]}"
    if [[ "$prev_word" != "ollama" || "$cur_command" != "run" ]]; then
        return
    fi

    # Get current word to complete from COMP_WORDS
    local cur=${COMP_WORDS[COMP_CWORD]}

    # Get available models by running ollama list, ignoring errors.
    local lines=()
    if ! readarray -t lines < <(ollama list 2>/dev/null); then
         return
    fi

    local suggestions=()
    for line in "${lines[@]}"; do
        # Split the line into words (in case models are space separated)
        for model in $line; do
            if [[ -n "$model" && "$model" == $cur* ]]; then
                suggestions+=("$model")
            fi
        done
    done

    COMPREPLY=( "${suggestions[@]}" )
}
complete -F _ollama_run ollama
```
   And then add installation instructions at the end of file as a comment:

```
# Installation:
# 1. Save this script to /etc/bash_completion.d/ollama-run.bash (or another directory in your PATH for bash completions).
# 2. Source it in your .bashrc or profile: source /etc/bash_completion.d/ollama-run.bash
# Alternatively, place the script in a file and source it directly.
```

But instructions said "Do not add unrelated explanation." But instructions also said to include minimal but clear installation instruction at end of the output.

We need to produce exactly the shell script with comments and instructions. We are to output only the shell script with comments plus installation instructions, no extraneous text.

I'll produce a final answer in plain text code block, but instructions says "by default, do not use markdown unless requested"? It said by default: "Output: Only the shell script (with comments) plus the installation instructions."

I need to output as plain text. I must produce an answer with a single code snippet containing the script and then include at the end installation instructions.

I'll produce:
```
# Bash completion for 'ollama run <model>'
_ollama_run() {
    # Ensure that we have at least three words: "ollama", "run", and model
    if [[ ${COMP_CWORD} -lt 3 ]]; then
        return
    fi

    # Check if the first two words are "ollama" and "run"
    if [[ "${COMP_WORDS[1]}" != "ollama" || "${COMP_WORDS[2]}" != "run" ]]; then
        return
    fi

    # Get current token to complete
    local cur="${COMP_WORDS[COMP_CWORD]}"

    # Capture the output of 'ollama list' ignoring errors; if command fails, no completions will be provided.
    local lines=()
    if ! readarray -t lines < <(ollama list 2>/dev/null); then
        return
    fi

    # Filter and prepare suggestions based on current prefix (cur)
    local suggestions=()
    for line in "${lines[@]}"; do
        # Split the line by whitespace into individual model names.
        for model in $line; do
            if [[ -n "$model" && "$model" == $cur* ]]; then
                suggestions+=("$model")
            fi
        done
    done

    COMPREPLY=( "${suggestions[@]}" )
}
complete -F _ollama_run ollama

# Installation Instructions:
# 1. Save this script to a file, for example: /etc/bash_completion.d/ollama-run.bash
# 2. Ensure the file is executable if required.
# 3. Source the completions in your shell configuration (e.g., add "source /etc/bash_completion.d/ollama-run.bash" to ~/.bashrc).
```

That should meet requirements.

I'll now produce final answer accordingly. We'll not include any additional explanation outside of comments.

I need to produce a code snippet that is correct and minimal as required.

Double-check:
- The function _ollama_run uses COMP_WORDS[COMP_CWORD] for current token, and checks if first two words are "ollama" and "run".
- It captures output of `ollama list` using readarray -t. If read fails then return.
- Then loops over each line, then word-splitting on the line, then check if model name starts with prefix.
- Then COMPREPLY is set to suggestions array.

- Also include compopt maybe? But instructions do not require that specifically. We could add "complete -F _ollama_run ollama" so it's complete.

- Also note: The script uses command substitution < <(ollama list 2>/dev/null) which is portable in modern Bash (it may fail on older versions of bash but we assume typical environment)

I need to ensure that if "ollama list" fails, then return no completions gracefully.

I also need to note "fail gracefully", so that means do not echo error messages. So doing 2>/dev/null is correct.

- Also check instructions: "Do NOT add any unrelated explanation." So our final answer should contain only the shell script and installation instructions as comments at end.
- Possibly also include a comment at top with "Bash completion for 'ollama run <model>'"

I'll produce final answer.</think>#!/bin/bash
# Bash completion for "ollama run <model>"
_ollama_run() {
    # Ensure that there are at least three words: "ollama", "run", and the model name.
    if [[ ${COMP_CWORD} -lt 3 ]]; then
        return
    fi

    # Check if we're completing the "ollama run" subcommand.
    if [[ "${COMP_WORDS[1]}" != "ollama" || "${COMP_WORDS[2]}" != "run" ]]; then
        return
    fi

    # Get the current token to complete.
    local cur="${COMP_WORDS[COMP_CWORD]}"

    # Capture the output of 'ollama list', ignoring errors. If the command fails, no completions are offered.
    local lines=()
    if ! readarray -t lines < <(ollama list 2>/dev/null); then
        return
    fi

    # Process each line; split by whitespace to support models output on one or multiple lines.
    local suggestions=()
    for line in "${lines[@]}"; do
        for model in $line; do
            if [[ -n "$model" && "$model" == $cur* ]]; then
                suggestions+=("$model")
            fi
        done
    done

    COMPREPLY=( "${suggestions[@]}" )
}
complete -F _ollama_run ollama

# Installation Instructions:
# 1. Save this script to a file (e.g., /etc/bash_completion.d/ollama-run.bash).
# 2. Ensure the file is executable if required.
# 3. Source the completions in your shell configuration (for example, add "source /etc/bash_completion.d/ollama-run.bash" to ~/.bashrc).

