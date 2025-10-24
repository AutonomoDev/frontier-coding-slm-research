#Thinking...
#We need to output a bash-completion script with inline comments. Requirements:
#
#- Only when completing after `ollama run`. Use COMP_WORDS and COMP_CWORD; we can check prev word: COMP_WORDS[COMP_CWORD-1] == "run" and COMP_WORDS[0]=="ollama". That triggers.
#- Retrieve `ollama list` once into a variable. Not pipe to while read. Instead: local list_output; list_output=$(ollama list 2>/dev/null). That will capture entire output. If fails or empty, return.
#- The output lines presumably contain model names maybe like "model1   description"? Actually, "ollama list" prints lines with model names maybe plus other columns. Need to extract model names. But requirement: "capture its full output into a variable". But then we need to filter by prefix on model names. We need to parse each line to get the first column? Usually "ollama list" output: maybe "stable-diffusion 1.2" but uncertain. But we can assume each line starts with model name, maybe followed by space. For simplicity, we can split on newline and extract first word.
#- Use [[ $model == "$cur"* ]] to filter.
#- Sort alphabetically before populating COMPREPLY. We can collect into an array matches, sort, then set COMPREPLY via compgen -W.
#- For graceful failure: if command fails or list_output empty, just return.
#- No external dependencies beyond Bash built-ins and sort.
#- Use fallback for _get_comp_words_by_ref: If function not defined, we compute cur and prev manually.
#- Attach to ollama: complete -F _ollama_run_ollama_completion ollama
#
#We also need to ensure that if more words present after run, we still only complete the first argument after run? The requirement: "only care that what’s being completed follows run." So if they type "ollama run <model> someotherarg", we still complete the model. We should check the next word index: the word currently being completed (cur) is COMP_WORDS[COMP_CWORD]. If prev is "run" we trigger. But there might be words after run already typed: e.g., "ollama run model1 -something" - but the user is completing at model1 maybe? Actually, typical scenario: after run, user might type model. But if they type additional args, we only want to complete the model before any other args. We could restrict to when prev is "run" and not when prev is some flag? But requirement: "when completing the model argument after typing ollama run" and "the simplest reliable check is that the previous word is run and the command is ollama. Do not fail if there are more than two words in COMP_WORDS—only care that what’s being completed follows run." So if there are more words, but prev is run, we still complete. But if prev is a flag (like -h) after run? That would be prev not run, so no completion. That matches.
#
#Thus we check prev == "run" and COMP_WORDS[0]=="ollama".
#
#Also we may consider that user might type "ollama   run   " with multiple spaces; but COMP_WORDS splits on spaces ignoring multiple whitespace. So prev will be "run".
#
#Implementation:
#
#_ollama_run_completion() {
#  local cur prev
#  # Try to use bash completion helper
#  if declare -f _get_comp_words_by_ref >/dev/null 2>&1; then
#    _get_comp_words_by_ref -n : cur prev
#  else
#    cur="${COMP_WORDS[COMP_CWORD]}"
#    prev="${COMP_WORDS[COMP_CWORD-1]}"
#  fi
#
#  # Trigger only if command is ollama and previous word is run
#  if [[ ${COMP_WORDS[0]} != ollama || ${prev} != run ]]; then
#    return
#  fi
#
#  # Get model list once
#  local list_output
#  if ! list_output=$(ollama list 2>/dev/null); then
#    return
#  fi
#
#  # If empty
#  [[ -z $list_output ]] && return
#
#  # Build array of model names
#  local -a models
#  while IFS= read -r line; do
#    # Get first word
#    local model
#    model=${line%%[[:space:]]*}
#    [[ -n $model ]] && models+=("$model")
#  done <<< "$list_output"
#
#  # Filter by prefix
#  local -a matches
#  for m in "${models[@]}"; do
#    if [[ $m == $cur* ]]; then
#      matches+=("$m")
#    fi
#  done
#
#  # If no matches, nothing
#  [[ ${#matches[@]} -eq 0 ]] && return
#
#  # Sort
#  IFS=$'\n' sorted=($(sort <<<"${matches[*]}"))
#  unset IFS
#
#  # Set COMPREPLY
#  COMPREPLY=($(compgen -W "${sorted[*]}" -- "$cur"))
#}
#complete -F _ollama_run_completion ollama
#```
#
#But we used while read loop with <<< "$list_output" which creates a subshell? Actually, while read in a pipeline is a subshell; but we are not using a pipeline, we use a here-string with <<< which does not spawn a subshell? In Bash, a while loop with a here-string still runs in the current shell. So that should be okay.
#
#We also used sort with <<< which is okay.
#
#Now installation instructions: e.g.,
#
#```
## Save to ~/.bash_completion.d/ollama-completion.sh
## Or source in ~/.bashrc
## Then reload: source ~/.bashrc
#```
#
#But requirement: Provide minimal example where to save or source, and how to activate. Provide something like:
#
#```
## ~/.bash_completion.d/ollama-completion.sh
## Then in ~/.bashrc add:
## source ~/.bash_completion.d/ollama-completion.sh
## reload with: . ~/.bashrc
#```
#
#We also might need to ensure that file is sourced after bash completion is loaded. But fine.
#
#Let's produce script with concise inline comments.
#
#Also mention that script requires Bash. Should we set shopt -s compat31? Not necessary.
#
#Let's write.
#
#...done thinking.
#
#```bash
## ~/.bash_completion.d/ollama-completion.sh
## Bash completion for `ollama run <model>`
# --------------------------------------------------------------

_ollama_run_completion() {
    local cur prev

    # 1. Get the word being completed and the previous word.
    if declare -f _get_comp_words_by_ref >/dev/null 2>&1; then
        _get_comp_words_by_ref -n : cur prev
    else
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
    fi

    # 2. Trigger only for `ollama run <...>`
    [[ "${COMP_WORDS[0]}" != ollama || "$prev" != run ]] && return

    # 3. Retrieve the model list once
    local list_output
    if ! list_output=$(ollama list 2>/dev/null); then
        return          # graceful failure if command fails
    fi
    [[ -z $list_output ]] && return  # no output → no completions

    # 4. Build an array of model names (first word of each line)
    local -a models
    while IFS= read -r line; do
        local model
        model=${line%%[[:space:]]*}
        [[ -n $model ]] && models+=("$model")
    done <<< "$list_output"

    # 5. Filter by the current prefix
    local -a matches
    for m in "${models[@]}"; do
        [[ $m == $cur* ]] && matches+=("$m")
    done
    [[ ${#matches[@]} -eq 0 ]] && return

    # 6. Sort alphabetically
    IFS=$'\n' sorted=($(sort <<<"${matches[*]}"))
    unset IFS

    # 7. Populate COMPREPLY
    COMPREPLY=($(compgen -W "${sorted[*]}" -- "$cur"))
}

# Wire the function to the `ollama` command
complete -F _ollama_run_completion ollama

# [[HUMAN COMMENTED-OUT]]
### Installation
#
#1. Save the script, e.g. to `~/.bash_completion.d/ollama-completion.sh`.
#2. In your `~/.bashrc` (or `~/.bash_profile`) add:
#
## Load bash completions
#[[ -f /usr/share/bash-completion/bash_completion ]] && . /usr/share/bash-completion/bash_completion
#
## Source our ollama completion
#source ~/.bash_completion.d/ollama-completion.sh
#```
#
#3. Reload the shell or source the file:
#
#```bash
#source ~/.bashrc
#```
#
#Now `ollama run <Tab>` will suggest model names.

