<think>We are Phi and need to produce a robust Bash completion script for the command "ollama run". The instructions: "Include only the complete bash script", "include clear comments explaining each section" (each comment begins with "#"). Also, script is complete. We must follow guidelines:
- Handling colon in model names by saving COMP_WORDBREAKS and restoring them.
- Must find position of "run" in COMP_WORDS array
- Only trigger completion when COMP_CWORD equals run_index+1 (i.e. the argument after 'run')
- Use robust data parsing using awk for unique lines from ollama list command.
- Helper fallback: use _get_comp_words_by_ref if available, or manually set cur and prev.

Plan:
Define function `_ollama_run_completion` (or similar name) that will complete models. The function should check argument count etc. Must get the model completions only when run is at a particular position.

Algorithm:

1. Save original COMP_WORDBREAKS to old_wb variable.
2. Remove colon from COMP_WORDBREAKS: `COMP_WORDBREAKS=${COMP_WORDBREAKS//:}`.
3. Parse arguments in COMP_WORDS array to find index of "run". Must iterate through COMP_WORDS and detect which argument is exactly "run".
4. If found, then check if COMP_CWORD equals run_index + 1 i.e the next word after "run", otherwise return completion nothing (set COMPREPLY=()).
5. Use helper function _get_comp_words_by_ref to get current prefix if available, but fallback for manual extraction.
6. Get list of models from `ollama list` command output. The script is robust: 
   - It does: `models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | awk '!seen[$0]++')`
7. Use safe prefix matching:
   COMPREPLY=($(compgen -W "$models" -- "$cur"))
8. If no completions, then clear output.
9. Restore COMP_WORDBREAKS before exit.

Corner: The code must be robust with saving COMP_WORDS from _get_comp_words_by_ref if possible. Use helper fallback if not available.

Edge cases: If not matching completion conditions (if we are not at correct argument index), then do COMPREPLY=().

Edge: Must use "complete -F _ollama_run_completion ollama" to register completion for command "ollama". But instructions says "No filename fallback", so do not pass '-o default' option.
Thus, the script should be ready to source immediately (so just define function and then complete registration maybe at end).

I'll produce a robust Bash completion code that follows these steps.

Plan code:

```
#!/usr/bin/env bash
# This is bash completion for ollama run command

_ollama_run_completion() {
    # Save current COMP_WORDBREAKS to restore later
    local old_wb="$COMP_WORDBREAKS"
    # Remove colon from COMP_WORDBREAKS so that model names with colons are handled correctly.
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}

    # Determine index of "run" in the command arguments (COMP_WORDS)
    local run_index=-1
    local i
    for ((i=0; i<${#COMP_WORDS[@]}; i++)); do
        if [ "${COMP_WORDS[i]}" = "run" ]; then
            run_index=$i
            break
        fi
    done

    # Only trigger completion when the current word is after "run"
    if [ "$run_index" -ge 0 ] && [ "$COMP_CWORD" -eq $((run_index + 1)) ]; then
         # Try using _get_comp_words_by_ref for better compatibility if available.
         if type _get_comp_words_by_ref &>/dev/null; then
             _get_comp_words_by_ref -n : cur prev words cword
         else
             # Manual fallback: extract current word and previous word from COMP_WORDS array.
             local temp_cur="${COMP_WORDS[COMP_CWORD]}"
             local temp_prev="${COMP_WORDS[COMP_CWORD-1]}"
             cur="$temp_cur"
             prev="$temp_prev"
         fi

         # Build the list of models by parsing output of `ollama list`
         local models
         models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | awk '!seen[$0]++')

         # Generate completion matches using compgen for safe prefix matching.
         COMPREPLY=( $(compgen -W "$models" -- "$cur") )
    else
         # Not at the correct position: clear completions.
         COMPREPLY=()
    fi

    # Restore COMP_WORDBREAKS before returning.
    COMP_WORDBREAKS="$old_wb"
}
# Register bash completion for ollama command using our function, do not use -o default
complete -F _ollama_run_completion ollama
```

We need to add comments for each step.

I'll produce script text that includes all instructions in comment lines with # as required. The code must be ready to source immediately and only one file is provided.

Edge: I must consider using `#!/usr/bin/env bash` at top maybe, but since it's sourced, might not need shebang line. But if the script is intended for sourcing, we may omit shebang or include a comment that this script should be sourced.

I'll produce code with explanation comments in each step (starting with #). I must ensure every non-code line starts with "#", so I'll put all explanatory lines as "#".

Also note: For COMP_WORDS array iteration: In bash arrays, the syntax for iterating is either `for word in "${COMP_WORDS[@]}"; do ...` but if we want index then use a separate loop. But the instructions say "Find the exact position of 'run'". Possibly better to do for loop with index:

```
local i=0
for arg in "${COMP_WORDS[@]}"; do
    if [ "$arg" = "run" ]; then
         run_index=$i; break
    fi
    i=$((i+1))
done
```

This is safer. I'll use that style.

I must check if COMP_CWORD equals (run_index + 1). But note: if run_index is -1, then we are not in the right position.

I can also get current word as:
- If _get_comp_words_by_ref exists, call it.
- Else fallback using array indices.
But careful with fallback. The instructions mention manual fallback code example that uses "cur" and "prev". But they suggest "cur = COMP_WORDS[COMP_CWORD]" but also need to check if not running.

I'll produce safe fallback: if _get_comp_words_by_ref is available, use it; else, set cur=${COMP_WORDS[COMP_CWORD]}. Also get prev if needed maybe. But the instructions mention only using cur. So I will do this:
```
if type _get_comp_words_by_ref &>/dev/null; then
    _get_comp_words_by_ref -n : cur prev words cword
else
    local temp_cur="${COMP_WORDS[COMP_CWORD]}"
    cur="$temp_cur"
fi
```
Also, maybe we want to use 'prev' variable if needed but not required by our completion.

Then get list of models: `models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | awk '!seen[$0]++')`

I must check the output of ollama list. The first line may contain headers, so we use NR>1.
I'll mention in comment that it removes duplicates.

Then do:
```
COMPREPLY=( $(compgen -W "$models" -- "$cur") )
```
Yes.

Finally, restore COMP_WORDBREAKS.

That's basically the code.

Corner: Must include comments on each section. So I'll produce a script with many comment lines.
I'll produce code that includes function definition `_ollama_run_completion`, and then calls "complete -F _ollama_run_completion ollama" at end to register completions. The instructions say "No filename fallback", so do not use -o default.

I'll produce code text that is complete with comments.

I'll produce answer in final message with no markdown formatting? But instructions say: "Provide ONLY the complete bash script". So I'll produce exactly one file's content as a plain text code block. The instructions says "Ensure every non-code line starts with '#'." So each comment must start with "#".

I'll produce code that is a single file, maybe named something like ollama_run_completion.bash.

I'll produce the final answer in plain text script. I'll check if all requirements are satisfied:
- Save and restore COMP_WORDBREAKS: Yes.
- Position detection: find index of "run", then only trigger completion when COMP_CWORD equals run_index+1.
- Robust data parsing using awk to get unique models from ollama list output. 
- Helper function fallback: use _get_comp_words_by_ref if available, else manual fallback.
- Safe filtering: Use compgen with -W and prefix matching.
- No filename fallback: complete registration doesn't include -o default.

Yes.

I'll produce final answer accordingly in a code block (text) without markdown formatting.</think>#!/usr/bin/env bash
# This script provides robust Bash completion for the "ollama run" command,
# handling model names that contain colons and ensuring proper COMP_WORDBREAKS management.
#
# To use, simply source this file.

_ollama_run_completion() {
    # Save current COMP_WORDBREAKS to restore it later
    local old_wb="$COMP_WORDBREAKS"
    
    # Remove colon from COMP_WORDBREAKS so that model names with colons are handled correctly.
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}
    
    # Find the index of "run" in COMP_WORDS by iterating over each argument
    local run_index=-1
    local i=0
    for arg in "${COMP_WORDS[@]}"; do
        if [ "$arg" = "run" ]; then
            run_index=$i
            break
        fi
        i=$((i + 1))
    done

    # Only provide completion when the current word is immediately after "run"
    if [ "$run_index" -ge 0 ] && [ "$COMP_CWORD" -eq $((run_index + 1)) ]; then
        
        # Attempt to use _get_comp_words_by_ref for accurate parsing if available
        if type _get_comp_words_by_ref &>/dev/null; then
            _get_comp_words_by_ref -n : cur prev words cword
        else
            # Fallback: manually extract the current word from COMP_WORDS array.
            local temp_cur="${COMP_WORDS[COMP_CWORD]}"
            cur="$temp_cur"
        fi

        # Retrieve and parse the list of models from "ollama list" output
        # This uses awk to skip the header (NR>1) and remove duplicate model names.
        local models
        models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}' | awk '!seen[$0]++')

        # Generate completion matches using compgen for safe prefix matching.
        COMPREPLY=( $(compgen -W "$models" -- "$cur") )
    else
        # Not in the correct position for model name completion; clear completions.
        COMPREPLY=()
    fi

    # Restore COMP_WORDBREAKS before returning from the function.
    COMP_WORDBREAKS="$old_wb"
}

# Register the completion function with Bash-completion framework (v2)
# Note: Do not use "-o default" to avoid filename fallbacks.
complete -F _ollama_run_completion ollama

# End of script.

