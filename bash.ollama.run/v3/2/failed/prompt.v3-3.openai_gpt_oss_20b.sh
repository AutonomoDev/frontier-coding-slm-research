#Thinking...
#We need to produce a bash-completion script.
#
#We must produce a function for "ollama run <model>" that completes after "run".
#
#Requirements:
#
#- Activation only when previous word is 'run' and command is 'ollama'.
#- It should work even if more words exist (i.e., we check if prev=run). Use COMP_WORDS[COMP_CWORD-1] etc.
#- Should run 'ollama list' once and capture into variable. Use variable assignment. Not pipe into while.
#- Then filter: use [[ $model == "$cur"* ]].
#- Sorting alphabetically.
#- Build COMPREPLY either manually or via compgen -W.
#- Graceful failure: if ollama list fails or empty -> return with no completions.
#- No external dependencies except built-ins and coreutils.
#- If _get_comp_words_by_ref not available, fallback manually.
#- Attach to ollama.
#- Provide installation instructions.
#
#Let's design the script.
#
#First, we need to source bash_completion library if available. But we can't rely on it. Provide fallback.
#
#But we can still use _get_comp_words_by_ref. If available, we can use. If not, we set cur and prev manually.
#
#The function can be defined as _ollama_run.
#
#The logic:
#
#```
#_ollama_run()
#{
#    local cur prev words cword
#    # use bash_completion if available
#    if declare -f _get_comp_words_by_ref >/dev/null; then
#        _get_comp_words_by_ref -n = -i cur prev words cword
#    else
#        cur="${COMP_WORDS[COMP_CWORD]}"
#        prev="${COMP_WORDS[COMP_CWORD-1]}"
#        words=("${COMP_WORDS[@]}")
#        cword=$COMP_CWORD
#    fi
#
#    # Activate only when command is ollama and previous word is run
#    if [[ ${words[0]} != ollama ]] || [[ $prev != run ]]; then
#        return
#    fi
#
#    # Run ollama list once
#    local list_output
#    if ! list_output=$(ollama list 2>/dev/null); then
#        return
#    fi
#
#    # If list_output is empty
#    if [[ -z $list_output ]]; then
#        return
#    fi
#
#    # Parse list_output into array of model names
#    local models
#    IFS=$'\n' read -rd '' -a models <<<"$list_output"
#
#    # Filter by prefix
#    local filtered
#    filtered=()
#    local model
#    for model in "${models[@]}"; do
#        # Some lines may have extra spaces or format: "model 1" etc. We assume model names are first field
#        # So we extract first word
#        local name="${model%%[[:space:]]*}"
#        if [[ $name == "$cur"* ]]; then
#            filtered+=("$name")
#        fi
#    done
#
#    # If no matches, return
#    if (( ${#filtered[@]} == 0 )); then
#        return
#    fi
#
#    # Sort
#    IFS=$'\n' sorted=$(printf '%s\n' "${filtered[@]}" | sort)
#    # Now build COMPREPLY
#    COMPREPLY=()
#    while IFS= read -r suggestion; do
#        COMPREPLY+=("$suggestion")
#    done <<<"$sorted"
#}
#```
#
#But we need to ensure no subshell. For reading list_output into array, we use read -rd ''.
#
#But we can just use IFS=$'\n' read -rd '' -a models <<<"$list_output". That will create array models.
#
#But we need to handle if list_output includes lines like "modelname   1.0" etc. We'll parse first token. The assumption: each line starts with model name, rest of line is size, etc. We'll just use first word.
#
#Now we need to handle prefix filter using $cur. $cur could be empty; we still need to list all models. Our logic above will include all if $cur=="" because [[ $name == ""* ]] will match all.
#
#Now we need to ensure we don't use extra subshell for building COMPREPLY. We used while read to read sorted. That uses a subshell? The while loop inside process substitution is a subshell. But we can avoid using a subshell by using array indexing:
#
#```
#COMPREPLY=($(printf '%q\n' "${filtered[@]}" | sort))
#```
#
#But we can't use external sort? We can use sort builtin? Wait sort is coreutils. We can use sort.
#
#But we need to preserve spaces in model names; we might need quoting. But model names are likely simple. We can just use:
#
#```
#COMPREPLY=($(printf '%s\n' "${filtered[@]}" | sort))
#```
#
#But that splits on whitespace; if names contain spaces, that's problematic. But probably not.
#
#Alternatively we can fill COMPREPLY by iterating over sorted variable:
#
#```
#COMPREPLY=()
#while IFS= read -r suggestion; do
#    COMPREPLY+=("$suggestion")
#done <<<"$sorted"
#```
#
#But the while read loop uses a subshell? The while read inside a process substitution is a subshell. But we can avoid that by not using process substitution: just use for suggestion in $(printf "%s\n" "$sorted"); do COMPREPLY+=("$suggestion"); done. But that again splits on spaces.
#
#Alternatively, we can set COMPREPLY from array directly:
#
#```
#COMPREPLY=("${sorted_array[@]}")
#```
#
#But sorted array is not available. We could sort the array directly in bash without using sort? We could use array sort function? Not built-in. So we use sort.
#
#We could store sorted into an array via readarray -t sorted_array <<<"$sorted". That uses a subshell? readarray reads from a file descriptor? But still fine. The while read approach is okay but uses a subshell only if used in a pipeline. But we used a here-string "<<<". That is not a pipeline. In Bash, while read <<<"$sorted" does not spawn subshell. Good.
#
#So it's fine.
#
#Also need to attach to ollama command.
#
#We can use:
#
#```
#complete -F _ollama_run ollama
#```
#
#This attaches to the command. But will also run for other subcommands. But we only check previous word being run, so fine.
#
#We must also provide fallback for _get_comp_words_by_ref. Already done.
#
#Let's craft final script.
#
#Add comments.
#
#Also include installation instructions.
#
#Check for potential errors:
#
#- We used words[0] but words is array of COMP_WORDS. But we didn't set words. In fallback we set words=("${COMP_WORDS[@]}"). In the _get_comp_words_by_ref case, we passed -i cur prev words cword. That sets cur, prev, words, cword accordingly. So words is defined.
#
#- We used list_output=$(ollama list 2>/dev/null). We need to check if command exists. But okay.
#
#- If list_output empty or not, we return.
#
#- For parsing, we used IFS=$'\n' read -rd '' -a models <<<"$list_output". That's okay.
#
#- We extracted name="${model%%[[:space:]]*}". Works.
#
#- We check [[ $name == "$cur"* ]]. Good.
#
#- We accumulate filtered.
#
#- Then if none, return.
#
#- Sort: sorted=$(printf '%s\n' "${filtered[@]}" | sort). Good.
#
#- Build COMPREPLY by reading each line: while IFS= read -r suggestion; do COMPREPLY+=("$suggestion"); done <<<"$sorted". Good.
#
#- Finally, function ends.
#
#We might also want to use 'local' for all variables.
#
#Ok.
#
#Now the script.
#
#We need to provide installation instructions: e.g., save to ~/.bash_completion_ollama or source in .bashrc.
#
#We'll produce:
#
#```
## Place in ~/.bash_completion_ollama
## Then source it from .bashrc:
##   source ~/.bash_completion_ollama
## or if you have /etc/bash_completion.d, copy it there.
#```
#
#Now produce final answer.
#...done thinking.

# ──────────────────────────────────────────────────────────────────────────────
# Bash completion for `ollama run <model>`
# ──────────────────────────────────────────────────────────────────────────────
# Save this file (e.g. ~/.bash_completion_ollama) and source it from ~/.bashrc.
# ---------------------------------------------------------------------------

# Check if the built‑in helper is available and use it; otherwise fall back.
_ollama_run()
{
    local cur prev words cword
    # Prefer the Bash completion helper if it exists
    if declare -f _get_comp_words_by_ref >/dev/null; then
        _get_comp_words_by_ref -n = -i cur prev words cword
    else
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
        words=("${COMP_WORDS[@]}")
        cword=$COMP_CWORD
    fi

    # Activate only when the command is `ollama` and the previous word is `run`
    if [[ ${words[0]} != ollama ]] || [[ $prev != run ]]; then
        return
    fi

    # Run `ollama list` once, suppress errors
    local list_output
    if ! list_output=$(ollama list 2>/dev/null); then
        return
    fi

    # No output → no completions
    [[ -z $list_output ]] && return

    # Split output into an array (one model per line)
    local models
    IFS=$'\n' read -rd '' -a models <<<"$list_output"

    # Filter models that start with the current word
    local filtered=()
    local model name
    for model in "${models[@]}"; do
        # Extract the first word (the model name)
        name="${model%%[[:space:]]*}"
        [[ $name == "$cur"* ]] && filtered+=("$name")
    done

    # No matches → nothing to offer
    (( ${#filtered[@]} == 0 )) && return

    # Sort alphabetically
    local sorted
    sorted=$(printf '%s\n' "${filtered[@]}" | sort)

    # Populate the completion reply
    COMPREPLY=()
    while IFS= read -r suggestion; do
        COMPREPLY+=("$suggestion")
    done <<<"$sorted"
}

# Attach the completion function to the `ollama` command
complete -F _ollama_run ollama

#**Installation**
#
# 1. Save the script, e.g. ~/.bash_completion_ollama
# 2. Source it from your shell startup file:
#    echo "source ~/.bash_completion_ollama" >> ~/.bashrc
# 3. Reload the shell (or run `source ~/.bashrc`) to activate the completion.

