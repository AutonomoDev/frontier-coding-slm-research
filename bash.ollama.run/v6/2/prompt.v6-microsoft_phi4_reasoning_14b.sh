<think>We are asked to produce a robust and correct Bash completion script for "ollama run" command, meeting many specific constraints and instructions. It must use bash-completion v2 framework with proper variables: COMP_WORDS, etc.

Let's re-read the instructions carefully:

User states:
"You're Phi, a language model developed by Microsoft... We need to create robust and correct Bash completion script for `ollama run` command."

"Your solution must be a self-contained Bash script that can be sourced (e.g., source my_script.sh) to enable the functionality." So code must be in one file.

Core Requirement:
- Provide autocompletion suggestions for model names when user types `ollama run ` and hits <TAB>.

"How to Get Data: The list of available local models is obtained by running command "ollama list". Must parse output, which is typical like:

```
NAME                            ID              SIZE    MODIFIED
llama3:latest                   a7320c749969    4.7 GB  3 weeks ago
codellama:17b                   2b9b6e83e370    4.7 GB  2 months ago
codellama:32b                   278b4081325b    9.3 GB  2 weeks ago
```

So we must use "ollama list", then parse the output, extracting first column entries. But skip header line that starts with NAME. Use standard and reliable tool like cut for this parsing.

We must check that only suggestions provided are filtered based on current typed word: if user types part of a model name starting with partial string, then list models matching.

No fallback to file names: if no match exists, do not suggest any completions. Also final suggestion list should not have duplicates.

Script must use standard bash syntax and variables COMP_WORDS, etc.
We may use _get_comp_words_by_ref, but include fallback that manually sets cur and prev from COMP_WORDS/CWORD if missing or fails.

"Targeted Triggering: Completion logic MUST only activate for the word immediately following the run subcommand. It should not complete "ollama", nor any other subcommand."

Check first word is "ollama" and previous word (prev) exactly "run".

Contextual filtering must be applied.
We use standard bash completion v2 framework.

No external dependencies besides coreutils.

Also, script line non-code lines must start with "#". Therefore every comment line begins with '#' per instructions.

So we'll produce a script that meets these requirements. We can do something like:
- Check if function _ollama_run_completion exists; if so, source it.

I can define a bash completion function for "ollama run", maybe with function _ollama_run_completion, then register using complete -F _ollama_run_completion ollama-run command but careful not to conflict.

Maybe we can use the function name that is used as completion script, e.g. _ollama_run. But instructions say "ollama run" so the completions for "ollama run".

Let's plan:

We want autocompletion suggestions only when:
- There are at least two words in COMP_WORDS: the first word must be "ollama".
- The second word (index 2, because array indexing is 1-based?) Actually, let's see how it works: COMP_WORDS[0] = ollama, COMP_WORDS[1] = run. But our instructions require that previous word equals "run". So if $COMP_CWORD > 1 then we check that $COMP_WORDS[$(($COMP_CWORD - 2))] equals "run"? Wait careful: In bash completion, the word being completed is the one at index (COMP_CWORD-1). The previous word is at index COMP_CWORD-2. But instructions say: "the first word is `ollama` and the previous word (`prev`) is exactly `run`." So check if COMP_WORDS[0]="ollama" and COMP_WORDS[1] equals "run"? Wait, instructions says "Check that the first word is ollama and the previous word (prev) is exactly run". So that means: The subcommand following "ollama" is "run", so if we are completing the argument after "run", then current argument index is 2 or more? Let's think: If user types: "ollama run ..." then:
- COMP_WORDS[0] = ollama
- COMP_WORDS[1] = run
- The word being completed is the third one, so it is COMP_WORDS[2].
So in bash completion, the current argument index (COMP_CWORD - 1) equals 2. So we require: COMP_WORDS[0]="ollama" and COMP_WORDS[1]=="run"? But instructions say "previous word" equals run, but what if user types only one word? Actually, if no subcommand is typed or if there's a different command then skip.

We want to trigger completions only if the last complete word was "run". So condition: if [[ ${COMP_WORDS[0]} != ollama || ${COMP_WORDS[1]} != run ]] then return. But careful: Check COMP_CWORD, but we can do check anyway.

I will define a function _ollama_run_completion that does following:
- It first calls _get_comp_words_by_ref to get cur and prev. And if that fails, fallback: set cur = ${COMP_WORDS[COMP_CWORD - 1]} and prev = ${COMP_WORDS[COMP_CWORD - 2]}. But note instructions say "if _get_comp_words_by_ref is missing or fails", then do manual assignment.

- Then check if COMP_WORDS length <3 then return. Because we need at least two words, but since we want to complete the argument after run, that's third word. So maybe I'll check: if [ ${#COMP_WORDS[@]} -lt 2 ]; then return; fi.
But careful: We must not auto-complete when user types "ollama", so require: COMP_WORDS[0]="ollama" and COMP_WORDS[1]=="run". But what about arguments of run? Actually, instructions say the completion suggestions for the model name are provided after "run". So if the second word equals "run", then we want to autocomplete on third argument. So check that.

- Then get output of `ollama list`, parse with cut command. We need to skip header line. But careful: How to skip header? The first non-header is maybe not always first record because there might be a leading blank line sometimes? But assume header is present and we can remove it by using sed or grep pattern that doesn't match "NAME". Use something like:
   models=$(ollama list | sed '1d' | cut -f1) 
But careful: The output includes header as first row starting with "NAME", so use sed '1d'.

- Then filter for lines matching current word prefix (the user typed partial model name). We'll do that by filtering the output with grep. But careful, not to provide suggestions if none match.

- But then we also need to remove duplicates. Possibly sort unique with sort -u.
We can generate completions list as array of model names.

I must be careful: The instructions say "Use only Bash built-ins and GNU coreutils (sort, cut etc)". So it's allowed.

But the output is multiline text from `ollama list | sed '1d'` so I might store that in a variable and then use grep to filter for lines beginning with the prefix. But note: The user may have typed partial string, but what if there are spaces? But no need because model names don't contain whitespace. But they can contain colons. So we use grep ^$cur maybe.

Plan code:
```
# _ollama_run_completion function
_ollama_run_completion() {
    # Use _get_comp_words_by_ref with fallback.
    if declare -F _get_comp_words_by_ref > /dev/null 2>&1; then
       _get_comp_words_by_ref cur prev || { cur="${COMP_WORDS[COMP_CWORD-1]}"; prev="${COMP_WORDS[COMP_CWORD-2]}"; }
    else
       cur="${COMP_WORDS[COMP_CWORD-1]}"
       prev="${COMP_WORDS[COMP_CWORD-2]}"
    fi

    # Check if we're completing after 'run'
    if [ "${COMP_WORDS[0]}" != "ollama" ] || [ "${COMP_WORDS[1]}" != "run" ]; then
        return 0
    fi
    
    # Get list of models from ollama list, skipping header.
    local model_list
    model_list=$(ollama list | sed '1d' | cut -f1)
    
    # Filter model names that start with the current word fragment.
    COMPREPLY=( $(compgen -W "$model_list" -- $cur) )
}
```
But wait, instructions say: "The suggestions provided MUST be filtered based on the word the user is currently typing." This means if no match then nothing.

- Also must not use fallback to files. So that's fine.

We also need to ensure unique suggestions. Using compgen -W "$model_list" might produce duplicates? But normally, if there are duplicate lines in model_list, we want them removed? We can do: sort -u "$model_list". But the instructions require "The final list of completion suggestions MUST NOT contain duplicate entries."

We can generate it as:
```
local models
models=$(ollama list | sed '1d' | cut -f1 | grep "^${cur}" | sort -u)
COMPREPLY=( $(compgen -W "$models" -- $cur) )
```
But careful: if no model matches, then COMPREPLY becomes empty.
Better use:
```
local models
models=$(ollama list | sed '1d' | cut -f1 | grep "^${cur}" | sort -u)
COMPREPLY=( $(compgen -W "$models" -- $cur) )
```

- But wait, we want to complete only if the user is typing a model name. So check condition: if not then return.

- Also "Ensure that script works with bash-completion v2."

We must register completions for "ollama run". Typically, in bash completion scripts one uses:
```
complete -F _ollama_run_completion ollama
```
But careful: We want to only complete the third argument? But instructions say "only complete for the word immediately following the `run` subcommand", so we want to check that previous is run. So if user types "ollama run" then no completions because it's the second argument? Wait, read instructions: "The completion logic must only activate for the word immediately following the `run` subcommand." That means when user types "ollama run ", the third word is completed. So our function _ollama_run_completion should be triggered when a command line is "ollama run <something>".
But in completions, if we register "complete -F _ollama_run_completion ollama", then it might get triggered for all subcommands of "ollama"?
We want to restrict it so that only if the second word is exactly "run" then do completion. But our function check already does that.

But sometimes bash-completion registers a separate function for completions on commands with multiple arguments. Possibly we can use "complete -F _ollama_run_completion ollama-run", but I'm not sure.

We want to complete only after the "run" subcommand, so maybe we do:
```
case "${COMP_WORDS[0]}" in
    ollama)
         case "${COMP_WORDS[1]:-}" in
             run)  _ollama_run_completion ;;
             *) return;;
         esac
         ;;
    *)
        return
esac
```
But note, if the function is attached to "ollama", then it should be triggered only when subcommand equals run. So maybe we can do:

complete -F _ollama_run_completion ollama

Then in function, check that COMP_WORDS[1]=="run". But careful: sometimes if user types just "ollama" then there's no second word, so our check would fail.

I think best approach is to register completion for the command "ollama run" specifically. But I'm not sure how to do that with bash-completion v2. Possibly use "complete -F _ollama_run_completion ollama-run"? But "ollama run" as one argument? Alternatively, we can simply do complete -F _ollama_run_completion ollama and then check in the function for second word equals "run". That might be acceptable.

Maybe it's safer to define a wrapper function that checks if second word is run. E.g.,

_ollama_completion() {
    local cur prev
    # get comp words by ref or fallback.
    ... 
    if [ "${COMP_WORDS[0]}" != "ollama" ]; then return; fi
    
    case "${COMP_WORDS[1]:-}" in
        run) _ollama_run_completion ;;
         *) return ;;
    esac
}

Then complete with: complete -F _ollama_completion ollama

But instructions mention "the previous word (`prev`) is exactly run." So that means the argument before the current is run. So if user types "ollama run", then COMP_WORDS[2] is the model name and COMP_WORDS[1] equals run, so our check works.

Alternatively, we can simply do: complete -F _ollama_run_completion ollama-run. But I'm not sure if that's valid.

I think a safe approach:
```
_ollama_run_completion() {
   # get cur and prev.
   ...
   if [ "${COMP_WORDS[0]}" != "ollama" ] || [ "${COMP_WORDS[1]}" != "run" ]; then
       return 0;
   fi

   local models
   models=$(ollama list | sed '1d' | cut -f1 | grep "^${cur}" | sort -u)
   COMPREPLY=( $(compgen -W "$models" -- $cur) )
}
complete -F _ollama_run_completion ollama
```
But then what about completions for "ollama"? It might match if user types only "ollama", but we check in the function that COMP_WORDS[1] equals run, so it won't complete. But is that acceptable? Yes.

I worry: If user types "ollama run" and then press TAB before typing any model name, then COMP_CWORD will be 2, not 3. In that case, our check in the function might not trigger because we want to complete only if current argument index >= 3.
So maybe we need to check that number of arguments is at least 3, i.e., ${#COMP_WORDS[@]} -lt 3 then return 0. But instructions say "the completion suggestions for the model name" so it's only relevant if there's a third word.

We can do:
```
if [ ${#COMP_WORDS[@]} -lt 2 ]; then
   return 0;
fi

if [ "${COMP_WORDS[1]}" != "run" ]; then
    return 0;
fi
```
But wait, what if user types "ollama run" and then hits TAB for the argument after run? Then COMP_WORDS will be two words ("ollama", "run"). But then current argument is empty string. So maybe we want to also trigger completions when no third word exists (i.e., just after run)? The instructions say: "the completion logic must only activate for the word immediately following the `run` subcommand." That means if user types "ollama run", the next argument is incomplete and should be completed. So in that case, COMP_WORDS will have 2 words ("ollama", "run"). But then current argument index (COMP_CWORD) equals 2. And our check: COMP_WORDS[0]="ollama" and COMP_WORDS[1]=="run". So then it's correct to start completing the third word, even though currently there is no third word. But compgen will generate completions for an empty prefix? Actually, if cur is empty string (""), then compgen -W "$models" -- "" returns all words that match, which might be acceptable.

I worry about our fallback assignment: We use _get_comp_words_by_ref to get current and previous words. But when COMP_CWORD equals 2, the third word doesn't exist yet, so cur becomes empty string. And previous word becomes "run". That is correct.

So condition:
if [ "${COMP_WORDS[0]}" != "ollama" ]; then return 0; fi
if [ "${COMP_WORDS[1]:-}" != "run" ]; then return 0; fi

That should be enough.

I need to check that the script uses proper quotes and escapes. Possibly use local variable for models. Also, I'll ensure uniqueness by piping through sort -u. But what if grep doesn't match anything? Then compgen will yield empty array, which is fine.

Potential pitfall: If `ollama list` returns something like:
NAME
model1
model2
Then sed '1d' removes the first line and cut -f1 gives "model1" on next line. So that's good.

I want to do:
```
local models
models=$(ollama list | sed '1d' | cut -f1 | grep "^${cur}" | sort -u)
COMPREPLY=( $(compgen -W "$models" -- $cur) )
```
That is acceptable. But then, what if user typed something that doesn't match any model? Then COMPREPLY becomes empty.

I want to note: "The final list of completion suggestions MUST NOT contain duplicate entries." The sort -u ensures uniqueness.
Also, "the suggestions provided must be filtered based on the word the user is currently typing", which is done by grep "^${cur}".

One more detail: In some shells, compgen might require a space after the option. But that's fine.

Maybe I'll also include a comment at top of file.

I should output full script in plain text with no markdown formatting. I'll now produce final answer with code snippet and explanation.

I'll now produce final answer as required.</think>#!/bin/bash
# This completion function provides model name completions for the “ollama run” subcommand.
#
# It will only trigger when the command line looks like:
#   ollama run <model-name>
#
# If the second word is not "run" (or if fewer than two words have been typed)
# then no completions are offered.
#
# The list of available models is obtained by running “ollama list”, skipping
# the header line, and filtering unique entries that begin with the current
# word fragment.

_ollama_run_completion() {
    # Try to get "cur" (the word being completed) and "prev" (its previous word)
    if declare -F _get_comp_words_by_ref > /dev/null 2>&1; then
        _get_comp_words_by_ref cur prev || {
            cur="${COMP_WORDS[COMP_CWORD-1]}"
            prev="${COMP_WORDS[COMP_CWORD-2]}"
        }
    else
        cur="${COMP_WORDS[COMP_CWORD-1]}"
        prev="${COMP_WORDS[COMP_CWORD-2]}"
    fi

    # Only complete if the command is "ollama" and the second word equals "run".
    if [ "${COMP_WORDS[0]}" != "ollama" ]; then
        return 0
    fi
    if [ -z "${COMP_WORDS[1]:-}" ] || [ "${COMP_WORDS[1]}" != "run" ]; then
        return 0
    fi

    # Retrieve the list of models from "ollama list", skip the header, and extract the first field.
    local model_list
    model_list=$(ollama list | sed '1d' | cut -f1)

    # Filter out only those model names starting with the current fragment,
    # sort them uniquely, then generate completions.
    local models
    models=$(echo "$model_list" | grep "^${cur}" | sort -u)
    COMPREPLY=( $(compgen -W "$models" -- $cur) )
}

# Register the completion function for the "ollama" command.
complete -F _ollama_run_completion ollama

# End of file.

