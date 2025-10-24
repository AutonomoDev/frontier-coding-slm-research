#Thinking...
#We need to write a bash completion script for `ollama run <model>`.
#
#We must meet all requirements.
#
#We need to write a script that can be sourced to provide completion for `ollama`.
#
#We need a function that checks if command is "ollama" and previous word is "run". So something like:
#
#```
#_ollama_run()
#{
#    local cur prev words cword
#    # try to use _get_comp_words_by_ref if available
#    if declare -f _get_comp_words_by_ref >/dev/null; then
#        _get_comp_words_by_ref -n : cur prev words cword
#    else
#        cur="${COMP_WORDS[COMP_CWORD]}"
#        prev="${COMP_WORDS[COMP_CWORD-1]}"
#        words=("${COMP_WORDS[@]}")
#        cword=$COMP_CWORD
#    fi
#
#    if [[ ${words[0]} != "ollama" || ${prev} != "run" ]]; then
#        return 0
#    fi
#
#    local output
#    if ! output=$(ollama list 2>/dev/null); then
#        return 0
#    fi
#
#    # if output empty
#    [[ -z $output ]] && return 0
#
#    local -a models
#    # read lines into array
#    while IFS= read -r line; do
#        # Each line from ollama list? Suppose output lines like "model_name <some other fields>"
#        # We need just model name. Typically first word.
#        # We'll use cut -d ' ' -f1
#        models+=("${line%% *}")
#    done <<< "$output"
#
#    # Filter by prefix
#    local -a matches
#    for m in "${models[@]}"; do
#        [[ $m == "$cur"* ]] && matches+=("$m")
#    done
#
#    # sort
#    IFS=$'\n' sorted=($(sort <<<"${matches[*]}"))
#    unset IFS
#
#    COMPREPLY=($(printf "%q\n" "${sorted[@]}"))
#
#    return 0
#}
#complete -F _ollama_run ollama
#```
#
#Need to be careful to avoid quoting issues.
#
#Better to build COMPREPLY by compgen -W.
#
#So:
#
#```
#local list
#list=$(ollama list 2>/dev/null)
#[[ -z $list ]] && return
#local -a models=()
#while IFS= read -r line; do
#    models+=("${line%% *}")
#done <<< "$list"
#local -a filtered=()
#for m in "${models[@]}"; do
#    [[ $m == "$cur"* ]] && filtered+=("$m")
#done
#IFS=$'\n' sorted=($(sort <<<"${filtered[*]}"))
#unset IFS
#COMPREPLY=($(printf '%q\n' "${sorted[@]}"))
#```
#
#But the requirement says we can use compgen -W with sorted list.
#
#Simpler: join sorted list into string and call compgen -W.
#
#```
#local wordlist
#wordlist=$(printf '%s\n' "${sorted[@]}" | tr '\n' ' ')
#COMPREPLY=( $(compgen -W "$wordlist" -- "$cur") )
#```
#
#But careful with spaces.
#
#Alternative: use compgen -W "${sorted[*]}"? But that will use spaces as separators, but sorted may contain spaces inside model names? Unlikely. But safe to join with space.
#
#But the easiest: we can just use COMPREPLY=( $(compgen -W "${sorted[*]}" -- "$cur") ). Because compgen splits on spaces.
#
#But we need to preserve proper quoting? Since models likely have no spaces.
#
#Ok.
#
#Need to handle fallback if _get_comp_words_by_ref missing: manual extraction.
#
#Also requirement: Do not fail if more than two words; we just check prev word is "run". But what if user typed "ollama run foo bar" then prev word would be "bar" and we might not trigger. That's fine; completion only after run, but after other words we don't want to trigger. The requirement: "trigger only when completing the model argument after typing ollama run" So if the user typed "ollama run" and then tab, or "ollama run foo" and tab, the completion for foo is model argument. But if they type "ollama run foo bar" and tab, we don't want to trigger. So we check that prev word is "run" OR maybe we want to trigger when prev word is "run" AND COMP_CWORD is 2 or 3? Actually we need to trigger when the current word being completed is the first argument after run. So if prev word is "run" then it should trigger. So if user typed "ollama run foo bar", when at "bar", prev word would be "foo" not "run", so we should not trigger. So the check is fine.
#
#Need to make sure we get cur from COMP_WORDS[COMP_CWORD].
#
#Also the function should be defined in script.
#
#Add installation snippet at end.
#
#Also comment to include fallback.
#
#Be careful: when _get_comp_words_by_ref fails, we still need to set cur and prev properly.
#
#Also we should consider that COMP_WORDS might contain an empty string for trailing tab. But typical.
#
#Ok.
#
#Edge: The output of `ollama list` may have more columns; we need only model names.
#
#Better to use cut -d' ' -f1.
#
#But we should parse lines: Each line may start with "model_name <space> other details". So the first word is the model name. We can extract first word via `${line%% *}`.
#
#We need to store output in variable, then read into array. We'll do:
#
#```
#local list_output
#if ! list_output=$(ollama list 2>/dev/null); then
#    return
#fi
#[[ -z $list_output ]] && return
#
#local -a model_names=()
#while IFS= read -r line; do
#    model_names+=("${line%% *}")
#done <<< "$list_output"
#```
#
#Ok.
#
#Now filtering and sorting:
#
#```
#local -a matches=()
#for m in "${model_names[@]}"; do
#    [[ $m == "$cur"* ]] && matches+=("$m")
#done
#
#if (( ${#matches[@]} == 0 )); then
#    COMPREPLY=()
#    return
#fi
#
#IFS=$'\n' sorted=($(sort <<< "${matches[*]}"))
#unset IFS
#COMPREPLY=( $(compgen -W "${sorted[*]}" -- "$cur") )
#```
#
#But compgen may not need sorted; we already sorted. But we can just set COMPREPLY=("${sorted[@]}")? But we need to match prefix. But we already filtered. So we can set COMPREPLY=("${sorted[@]}") directly. But we must ensure that we don't need to use compgen because compgen will further filter? Actually we want to present only the filtered and sorted models. So we can just assign them to COMPREPLY. But requirement says either build COMPREPLY manually or use compgen. We can just do COMPREPLY=("${sorted[@]}") and return. That is fine.
#
#But we need to quote properly. So:
#
#```
#COMPREPLY=("${sorted[@]}")
#```
#
#Ok.
#
#Also ensure that we return 0.
#
#Ok.
#
#Let's write the script.
#
#Add comments.
#
#Add installation snippet: "Save this file to ~/.bash_completion/ollama" and source it, or source it in .bashrc.
#
#Ok.
#
#Edge: Ensure we use local variables.
#
#Need to guard against _get_comp_words_by_ref not available. Provide fallback.
#
#Check: _get_comp_words_by_ref is part of bash completion library; might not be loaded. We can test:
#
#```
#if type _get_comp_words_by_ref > /dev/null 2>&1; then
#    _get_comp_words_by_ref -n : cur prev words cword
#else
#    ...
#fi
#```
#
#But we need to use declare -f _get_comp_words_by_ref, but easier: if type -p _get_comp_words_by_ref > /dev/null.
#
#Ok.
#
#Now script:
#
#```
## Bash completion for ollama run <model>
#_ollama_run()
#{
#    local cur prev words cword
#    # Try to use bash-completion helper if available
#    if type _get_comp_words_by_ref > /dev/null 2>&1; then
#        _get_comp_words_by_ref -n : cur prev words cword
#    else
#        cur="${COMP_WORDS[COMP_CWORD]}"
#        prev="${COMP_WORDS[COMP_CWORD-1]}"
#        words=("${COMP_WORDS[@]}")
#        cword=$COMP_CWORD
#    fi
#
#    # Trigger only when command is ollama and previous word is run
#    if [[ ${words[0]} != "ollama" || ${prev} != "run" ]]; then
#        return 0
#    fi
#
#    # Retrieve model list once
#    local list_output
#    if ! list_output=$(ollama list 2>/dev/null); then
#        return 0
#    fi
#    [[ -z $list_output ]] && return 0
#
#    # Extract model names
#    local -a model_names=()
#    while IFS= read -r line; do
#        # Get first word (model name)
#        model_names+=("${line%% *}")
#    done <<< "$list_output"
#
#    # Filter by prefix
#    local -a matches=()
#    for m in "${model_names[@]}"; do
#        [[ $m == "$cur"* ]] && matches+=("$m")
#    done
#
#    # No matches, nothing to offer
#    (( ${#matches[@]} == 0 )) && return 0
#
#    # Sort alphabetically
#    IFS=$'\n' sorted=($(sort <<< "${matches[*]}"))
#    unset IFS
#
#    # Populate COMPREPLY
#    COMPREPLY=("${sorted[@]}")
#
#    return 0
#}
#
#complete -F _ollama_run ollama
#```
#
#Now installation instructions.
#
#Add comment: "Save to ~/.bash_completion/ollama-completion.sh" or ".bash/completion/..." Then source.
#
#Let's write:
#
#```
## Installation:
## 1. Save this file to ~/.bash_completion/ollama
## 2. Source it in your shell:   source ~/.bash_completion/ollama
## 3. For automatic loading, add the source line to your ~/.bashrc or ~/.bash_profile
#```
#
#But we also need to ensure .bash_completion directory exists. But we can mention.
#
#Ok.
#
#Wrap all in script.
#
#Let's produce final answer.
#...done thinking.

#--------------------------------------------------------------------
# Bash completion for `ollama run <model>`
#--------------------------------------------------------------------
_ollama_run()
{
    local cur prev words cword

    # Try to use the helper from the bash-completion library if it exists
    if type _get_comp_words_by_ref > /dev/null 2>&1; then
        _get_comp_words_by_ref -n : cur prev words cword
    else
        # Manual extraction when helper is missing
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
        words=("${COMP_WORDS[@]}")
        cword=$COMP_CWORD
    fi

    # Trigger only when the command is `ollama` and the previous word is `run`
    [[ ${words[0]} != "ollama" || ${prev} != "run" ]] && return 0

    # Run `ollama list` once and capture its output
    local list_output
    if ! list_output=$(ollama list 2>/dev/null); then
        return 0
    fi
    [[ -z $list_output ]] && return 0

    # Extract model names (first word of each line)
    local -a model_names=()
    while IFS= read -r line; do
        model_names+=("${line%% *}")
    done <<< "$list_output"

    # Filter names that start with the current word being completed
    local -a matches=()
    for m in "${model_names[@]}"; do
        [[ $m == "$cur"* ]] && matches+=("$m")
    done
    (( ${#matches[@]} == 0 )) && return 0

    # Sort matches alphabetically
    IFS=$'\n' sorted=($(sort <<< "${matches[*]}"))
    unset IFS

    # Populate the completion reply array
    COMPREPLY=("${sorted[@]}")
    return 0
}

# Wire the function to the `ollama` command
complete -F _ollama_run ollama

# [[HUMAN COMMENTED-OUT]]
#---
#
#### Installation
#
#1. **Save the script** to a file, e.g. `~/.bash_completion/ollama`
#   (create the `~/.bash_completion` directory if it doesn’t exist).
#
#2. **Source it** in the current shell:
#   ```bash
#   source ~/.bash_completion/ollama
#   ```
#
#3. **Make it automatic** by adding the source line to your shell startup file:
#   ```bash
#   echo "source ~/.bash_completion/ollama" >> ~/.bashrc   # or ~/.bash_profile
#   ```
#
#Reload your shell or run `source ~/.bashrc` to activate the completion immediately.

