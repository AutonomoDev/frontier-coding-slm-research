<think>We are asked:

The task: "Create a bash-completion function for the command `ollama run <model>` that dynamically lists available models by parsing the output of `ollama list` without using any external dependencies. Assume `ollama list` prints model names one per line (or separated by whitespace) when run with no formatting flags."

We need to create a bash-completion script function.

Let's check details:

We have command: "ollama run <model>".
So completions for the argument in position 2 (i.e., after `ollama run`). But note that we might also want completions for `ollama list`? But only need to do "ollama run <Tab>" or partial typed model name.

We are required: Use Bash completion conventions: populate COMPREPLY array, respect the current word prefix and check COMP_WORDS/COMP_CWORD.
So we have a function that is triggered if command equals "ollama" with subcommand "run", then parse available models from output of `ollama list`.
We are to do dynamic listing. Must handle failure gracefully.

Thus I need code: I'll write something like:

```
_ollama_run()
{
    local cur prev words cword
    _init_completion || return

    # if less than 2 arguments in command line, nothing
    if [ $COMP_CWORD -lt 3 ]; then
         return 0;
    fi

    # get model names from "ollama list" output.
    local models=()
    while IFS= read -r model; do
        # trim whitespace: using builtin parameter substitution perhaps?
        [[ "$model" =~ ^[[:space:]]*$ ]] && continue
        models+=("$model")
    done < <(ollama list 2>/dev/null)

    if [ ${#models[@]} -eq 0 ]; then
         COMPREPLY=()
         return
    fi

    local cur="${COMP_WORDS[COMP_CWORD]}"
    local suggestions=()
    for m in "${models[@]}"; do
        # matching prefix, ignoring case? Possibly yes. But requirement: "filtered by the current prefix"
        if [[ $m == $cur* ]]; then
            suggestions+=("$m")
        fi
    done

    COMPREPLY=( $(compgen -W "${suggestions[*]}" -- "$cur" ) )
}
```

I need to write code that is robust and minimal. But check: We need a function for completion of command "ollama run <model>".

We must use only built-in shell string manipulation, no jq or external dependencies.

The script should be a complete bash-completion file which will set up completions, e.g., `complete -F _ollama_run ollama` if needed? But careful: "ollama run" is two words. So the completion function must check that $COMP_WORDS array equals to [0]="ollama", [1]="run". Then argument model should be provided.

I need to handle: "ollama run <Tab>" and partial input model names, then suggestions from `ollama list`.

We have code:

```
_ollama_run() {
  local cur prev words cword
  _init_completion || return

  # If only "ollama run" typed:
  if [ $COMP_CWORD -lt 3 ]; then
      return 0;
  fi

  # Get available models from 'ollama list'
  local IFS=$'\n'
  local models=()
  while read -r model; do
    [[ "$model" =~ ^[[:space:]]*$ ]] && continue
    models+=("$model")
  done < <(ollama list 2>/dev/null)
  
  if [ ${#models[@]} -eq 0 ]; then
      COMPREPLY=()
      return 0
  fi

  # filter completions based on current prefix.
  local cur="${COMP_WORDS[COMP_CWORD]}"
  COMPREPLY=( $(compgen -W "${models[*]}" -- "$cur" ) )
}
```

I need to set the bash completion using "complete -F _ollama_run ollama run"? But usually we want completions for subcommands. Possibly one can do something like:

```
complete -F _ollama_run ollama
```

But then how does that work? The function is triggered by "ollama", and then if command is exactly "ollama run" it works, else nothing.

I can check $COMP_WORDS[1] equals "run"? So:
```
if [ "${COMP_WORDS[1]}" != "run" ]; then
    return 0;
fi
```

Yes, that's correct.

So code:

```
_ollama_run() {
   local cur prev words cword
   _init_completion || return

   if [ $COMP_CWORD -lt 3 ] || [ "${COMP_WORDS[1]}" != "run" ]; then
       return 0;
   fi

   ...
}
```

I need to check: The script must fail gracefully if `ollama list` fails. So I'll redirect errors with 2>/dev/null inside command substitution. But careful: Using <(ollama list 2>/dev/null) is available in ksh and bash? In Bash, process substitution works on Linux but might not be available in all POSIX shells but our requirement says only use built-ins. Actually process substitution is a shell feature, so it's fine.

I need to include instructions at end: Provide minimal but clear installation instruction: where to drop/source the script and how to activate it immediately. So I'll put instructions as comment at bottom: "Installation: Save this file in /etc/bash_completion.d/ollama.sh or similar and source ~/.bashrc"

We can add a block like:

```
# Installation:
# 1. Save this script to /etc/bash_completion.d/ollama.sh (or another directory recognized by your completion loader).
# 2. Make the file executable: chmod +x /etc/bash_completion.d/ollama.sh
# 3. Restart your terminal session or source ~/.bashrc to activate completions.
```

We need only a working script.

I must check correctness. I'll write function _ollama_run. It will use _init_completion, which is provided by bash-completion package? In most installations, yes, so it's fine.

But if _init_completion isn't available then we can simply do:

```
if [[ ${COMP_WORDS[0]} != "ollama" ]]; then return; fi
```

But instructions say use Bash completion conventions. So using _init_completion is common idiom.

I need to be careful with variable scoping: In bash, variables declared local within functions are local. I'll check my code:

```
_ollama_run() {
    # initialize variables
    local cur prev words cword
    _init_completion || return

    if [ $COMP_CWORD -lt 3 ] || [ "${COMP_WORDS[1]}" != "run" ]; then
         return 0;
    fi

    # Get available models from ollama list output.
    local IFS=$'\n'
    local models=()
    while read -r model; do
        [[ "$model" =~ ^[[:space:]]*$ ]] && continue
        models+=("$model")
    done < <(ollama list 2>/dev/null)

    if [ ${#models[@]} -eq 0 ]; then
         COMPREPLY=()
         return 0
    fi

    local cur="${COMP_WORDS[COMP_CWORD]}"
    # use compgen for suggestions matching prefix.
    COMPREPLY=( $(compgen -W "${models[*]}" -- "$cur") )
}
```

That is the function. Then I need to attach completions:
```
complete -F _ollama_run ollama
```
But careful: This attaches for both "ollama" command and its subcommands? Yes, because _init_completion will check if COMP_WORDS[0]="ollama".

I must note that compgen uses words list separated by space. It's safe.

Also note that the function does not handle partial completions for "ollama list", only for "ollama run". So it's fine.

I'll include instructions at the end as comment. I need to put them in a block comment at bottom of file, and instructions are minimal but clear installation instructions: Save script in /etc/bash_completion.d/ollama.sh or in ~/.bashrc if your system doesn't use that directory, then "source" it.

I'll check possible pitfalls: Using process substitution. It's standard in bash on Linux, so it's fine.

The script is self-contained and minimal. I must not add extra explanation text outside the script code? The question says: "Output: Only the shell script (with comments) plus the installation instructions." So we output a single file with the function and installation instructions as comment. Also note that the system instruction: "Assume ollama list prints model names one per line, or separated by whitespace."

I must mention that if there is whitespace separation then reading line-by-line still works because process substitution splits lines? Actually it's going to read entire output as separate lines.

Maybe also check that if `ollama list` doesn't produce any output then completions are empty.

I can also add a check: "if [ $COMP_CWORD -lt 2 ]; then return" But required is command "ollama run <Tab>" so we need at least two words. So I'll check COMP_WORDS[1]. Yes, done.

I must check that the function gracefully handles errors from ollama list by redirecting stderr to /dev/null in process substitution: That's correct.

I also need to mention that this is a robust and minimal solution.

I can produce final answer as code block with text. But instructions say "by default do not add markdown formatting", so I should just output plain text script? Actually instructions say: "Output: Only the shell script (with comments) plus installation instructions." So I'll output the entire file code.

I'll now produce final answer in a code snippet that includes function and then complete command, and then commented installation instructions.

I'll use minimal error handling. Also note: Use _init_completion to get current word prefix etc.

I should check that "if [ $COMP_CWORD -lt 3 ]" is correct; because if user types "ollama run", then COMP_WORDS array: index 0: ollama, index1: run, and index2 might be empty. So we need at least 3 words for completion. But the instructions say: "ollama run <Tab>" so maybe only two words? Actually when the user typed "ollama run" with Tab, then COMP_WORDS array has length 2. But since there's no partial model argument yet? But then completions should be triggered on first parameter of second word if we already have two words? The script: If [ $COMP_CWORD -lt 3 ] returns true. But wait check: "ollama run" with Tab means COMP_WORDS length is 2, and COMP_CWORD=1 maybe or 0-based indexing? Let's recall: In bash completion, COMP_WORDS[0] equals the first word of the command (i.e., command name) while COMP_WORDS[1] equals second argument etc. And COMP_CWORD gives zero-indexed index of current word being completed, so if you have "ollama run" typed then COMP_WORDS length is 2 and COMP_CWORD=1? Actually check: For example, if user types "ollama run", COMP_WORDS= [ 'ollama', 'run' ] and COMP_CWORD=1 because the currently active word is "run". But we need to trigger our function only if subcommand is run. So if COMP_CWORD==1 (which means second argument) then we want suggestions? Because "run" is fixed by user? Actually, check: When you type "ollama run" and press Tab, the completions should provide model names for argument 2. But in that scenario, COMP_WORDS would be: index0 = ollama, index1 = run, but then current word index is COMP_CWORD= ? Let's see, if user typed only "ollama run" (no space after run), then the active word might be "run". But wait, we want to complete models when you type "ollama run <Tab>" maybe after a space. So what is the behavior? When you press Tab, if no partial argument for model exists, then completions are triggered on the next word. Possibly COMP_WORDS length = 2 and COMP_CWORD=1 means currently editing second argument ("run"). But we want to show suggestions only when there is at least one extra argument (like "ollama run" with a space after run)? Let's simulate: Suppose you type "ollama run " then press Tab, what are values? Then the command line becomes "ollama run <Tab>", so COMP_WORDS might be [ 'ollama', 'run', '' ]. And COMP_CWORD=2. So we need to check if $COMP_WORDS[1] equals run AND $COMP_CWORD is at least 3 because then third word exists. But what if user types just "ollama run" with no trailing space, then completions might be triggered on the second argument "run"? And that's not our target? We want to complete only models after "ollama run". So we need to check: If [ "$COMP_WORDS[1]" != "run" ] then return. But what if COMP_WORDS is length 2 and COMP_WORDS[1] equals "run", but COMPREPLY might be triggered for second word completion? Wait, no.

I want completions for the argument that follows "ollama run". So I need to check: If COMP_CWORD < 3 then we don't have a model argument. But what if user types "ollama run" and hits tab, then the current word is "run", but that's not our target? Usually bash completions for subcommands are only triggered after they've been typed fully. In fact, often you do complete -W "list run" ollama, so that when user types "ollama r", it suggests "ollama run". But here we want to complete model name argument if the command is "ollama run".

So in _ollama_run function, I check: if [ $COMP_CWORD -lt 3 ]; then return; fi. That means that if there's no third word (i.e., model argument), then do nothing. So if user types just "ollama run", with no space after run, then COMP_WORDS length is 2 and COMP_CWORD=1? Actually check: If you type "ollama run" and hit Tab, the current cursor position might be at the end of "run". In that case, COMP_WORDS is ["ollama", "run"] and COMP_CWORD=1. But our condition [ $COMP_CWORD -lt 3 ] will be true because 1 < 3, so then we return. So no completions are offered for "run" itself. But if the user types "ollama run " (with a space), then COMP_WORDS becomes ["ollama", "run", ""] and COMP_CWORD=2, which is >= 3? Actually wait, check: For three-word command, indices are 0,1,2, so COMP_CWORD might be 2. But our condition "if [ $COMP_CWORD -lt 3 ]" becomes if 2 < 3 then true? So that returns nothing. So it seems we want to require at least 3 words? Let's double-check: If user types "ollama run", the current word is the second argument which is "run". But we want completions only for model names after "run". So our function should be triggered when COMP_WORDS[1] equals run and there is a third word present. That means that when the user has typed "ollama run" with a space, then COMP_WORDS becomes: ["ollama", "run", ""] and COMP_CWORD=2 (the active argument index 2). But then condition $COMP_CWORD -lt 3? Actually, if COMP_CWORD is 2, then $COMP_CWORD < 3 means 2<3 is true, so we would return. But wait, that's not correct: We want to trigger when there is a third word argument. So check: If the command line is "ollama run" with a space after run (i.e., COMP_WORDS[2] is empty) then COMP_CWORD will be 2, but the length of COMP_WORDS array is 3? Wait, I need to recall how bash completion works: When you press tab and there is no partial word for third argument, then COMP_WORDS has an element "run" at index1 and then an empty string (or maybe a space?) at index2. The current word index would be 2 because that's the one being completed. So I want to trigger completions only if the subcommand is run and there are at least two arguments? But careful: We want to complete model names, which should start at argument 3 (index 2) if you count from 0. Let's simulate: Suppose user types "ollama run". At this point, the command line might be "ollama run" with cursor at end of second word, but if you press tab, then maybe it triggers completion for that word? But in our case we want to complete only after a space is inserted after "run"? I think the typical pattern is: complete -W "list run" ollama. That means completions for first argument are offered. Then, completions for the model names should be done by a separate function triggered when the command is "ollama run". So then my condition in _ollama_run should be something like: if [ "$COMP_WORDS[1]" != "run" ] then return; else proceed with completions. But also we want to have at least one argument after run, i.e., COMP_CWORD should be 2 or more? Let's check: If user types "ollama run", the active word is "run"? Actually let me recall how bash completions are triggered: For each function, when a tab is pressed, the function is called with the current command line words in COMP_WORDS. The number of words equals COMP_CWORD+1 usually. So if the user typed "ollama run" (with no space after run), then COMP_WORDS[0]="ollama", COMP_WORDS[1]="run". Then COMP_CWORD = 1? Because indexing starts at 0 for the current word being completed, so if there is only one argument after command name, then COMP_CWORD=1. But in that scenario, the active argument is "run", which is not a model, it's actually already complete: It might be suggested from -W "list run" ollama if you want completions for subcommands. So maybe we want to trigger our function only when the second argument has been fully typed as "run". But our function _ollama_run should be called by complete command for "ollama run", so it's normally triggered after the user types "ollama run" and then a space, meaning that the active word is model name. So in that case, COMP_WORDS might be: ["ollama", "run", ""] with COMP_CWORD=2 (because index 0: ollama, index1: run, index2: empty). Then our condition should check if $COMP_WORDS[1] equals "run". And then also we want to complete the third argument. So the condition would be if [ "$COMP_WORDS[1]" != "run" ] then return. And maybe no need for checking COMP_CWORD because it will always be 2 in that case? But what if user types something like "ollama run foo", with partial input on model name, then COMP_WORDS has length=4 and COMP_CWORD=3 (index0: ollama, index1: run, index2: foo, current word being completed is the third argument). In both cases, $COMP_WORDS[1] should be "run". So our condition should simply be if [ "$COMP_WORDS[1]" != "run" ]; then return. That would cover all scenarios.

Thus I'll modify function: Instead of "if [ $COMP_CWORD -lt 3 ]", I'll do:
if [ "${COMP_WORDS[1]}" != "run" ]; then
   return
fi

That is more straightforward.

Now let me produce final answer:

I'll include the following code:
-------------------------
#!/bin/bash
# ollama-run completion function for bash.
_ollama_run_completion() {
    # Only complete if second argument is 'run'
    if [ "${COMP_WORDS[1]}" != "run" ]; then
        return
    fi

    # Get current word being completed
    cur="${COMP_WORDS[COMP_CWORD]}"

    # Obtain models from ollama list output.
    local IFS=$'\n'
    local models=()
    while read -r model; do
        # Skip empty lines or spaces
        [[ "$model" =~ ^[[:space:]]*$ ]] && continue
        models+=("$model")
    done < <(ollama list 2>/dev/null)

    if [ ${#models[@]} -eq 0 ]; then
        COMPREPLY=()
        return
    fi

    # Generate completions using compgen.
    COMPREPLY=( $(compgen -W "${models[*]}" -- "$cur") )
}

complete -F _ollama_run_completion ollama
-------------------------

Then I'll add installation instructions as comment, e.g.:

# Installation Instructions:
# Save this file as /etc/bash_completion.d/ollama-completion.sh and restart your shell,
# or source it in your ~/.bashrc: 
#   source /path/to/this/script

I'll output code accordingly.

I'll now produce final answer with plain text script including comments.</think>#!/bin/bash
#
# ollama-run completion function for bash.
# This function completes model names only when the command is "ollama run".
#

_ollama_run_completion() {
    # Only complete if the second argument (subcommand) is exactly "run"
    if [ "${COMP_WORDS[1]}" != "run" ]; then
        return
    fi

    # Get the current word being completed.
    cur="${COMP_WORDS[COMP_CWORD]}"

    # Retrieve model names from the output of "ollama list".
    # We assume that ollama list prints one model per line (or separated by whitespace).
    local IFS=$'\n'
    local models=()
    while read -r model; do
        # Skip any blank lines.
        [[ "$model" =~ ^[[:space:]]*$ ]] && continue
        models+=("$model")
    done < <(ollama list 2>/dev/null)

    # If no models were found, do not offer completions.
    if [ ${#models[@]} -eq 0 ]; then
        COMPREPLY=()
        return
    fi

    # Use compgen to generate a list of possible completions matching the current word.
    COMPREPLY=( $(compgen -W "${models[*]}" -- "$cur") )
}

# Register _ollama_run_completion for the "ollama run" command.
complete -F _ollama_run_completion ollama

# INSTALLATION INSTRUCTIONS:
#
# 1. Save this script to a file (for example, ollama-completion.sh).
#
# 2. To have the completion function loaded automatically in bash,
#    place it into one of your bash_completion directories.
#
#    On many systems you can save it as:
#      /etc/bash_completion.d/ollama-completion.sh
#
#    Then restart your shell or source the file directly to test it:
#      source /etc/bash_completion.d/ollama-completion.sh
#
# 3. Alternatively, if your system does not use bash_completion,
#    add the following line to your ~/.bashrc:
#      source /path/to/ollama-completion.sh
#
# Now, when you type "ollama run" followed by a space and press Tab,
# the available model names will be suggested.

