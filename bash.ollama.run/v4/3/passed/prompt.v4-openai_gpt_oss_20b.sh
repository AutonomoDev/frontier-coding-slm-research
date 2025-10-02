#Thinking...
#We need to write a Bash completion script for ollama run. Provide completion only for models after run.
#
#We should check COMP_WORDS[1] == run. Then we need to parse `ollama list` output to get first column after header. We'll use `ollama list | awk 'NR>1{print $1}'` to get names. We need to filter based on current word: COMP_WORDS[COMP_CWORD] is the word being completed. That word is at index 2 when command is `ollama run <word>`. But if user typed "ollama run" with trailing space, the word being completed is empty string; then we need to list all models.
#
#Need to use COMPREPLY array. Must not provide filenames. Must avoid fallback to filenames: by setting `compopt -o nospace`? Actually by default completion may fallback to files; we need to disable fallback. Use `compopt -o default`? Wait. In bash-completion, to disable filename completion, we can set `compopt -o default`? Actually default is to consider files, but we want only model names. There's an option: `compopt -o default`? Let's recall: `compopt -o filenames`? Wait, maybe we can set `compopt -o default`? Let's check. In Bash completion, `compopt -o filenames` will allow filenames as fallback. The default is to not fallback? Actually `bash-completion` includes default fallback to filenames if COMPREPLY is empty, but we can override by setting `compopt -o default`? I think we can set `compopt -o default` to preserve default behaviour? Actually we need to avoid fallback. So we can set `compopt -o default`? I'm not certain. Another method: set `COMPREPLY=()` and then `return`. But the fallback still might occur if COMPREPLY remains empty. I think we can use `compopt -o default`? Let's search memory: In bash completion, `compopt -o default` sets default completion options. There is also `compopt -o nospace` to suppress trailing space. But to disable filename fallback, you can use `compopt -o default`? Actually there is `compopt -o default` which re-enables the default behaviour? Eh.
#
#Let's check typical script: e.g., `__ssh_hosts() { local cur=${COMP_WORDS[COMP_CWORD]}; COMPREPLY=( $(compgen -W "$(ssh -G $cur)" -- "$cur") ); }`. They don't disable fallback; they rely on completions. But to avoid fallback to filenames, you can set `COMPREPLY=()` and `return`. But fallback may still happen. But maybe `bash-completion` framework automatically uses the completions if COMPREPLY non-empty else fallback. But we want no fallback. There is an option: `compopt -o default`. Actually maybe we can use `compopt -o default`. Let's confirm: In Bash 4.3+, `compopt` can set options for the current completion. Options include `-o default`, `-o nospace`, `-o filenames`, `-o plusdirs`, etc. `-o default` resets to default. The default is to treat files and directories. We want to disable fallback, so we should not set filenames option. But default might include filenames; I'm not sure. But typical completions for commands like `git checkout` don't fallback to filenames because the command doesn't accept filenames. But the default for bash might still add file names if COMPREPLY empty. But many completions just set COMPREPLY and rely on that. There may be an option `-o default` to turn on default behavior: that includes files. But if we don't set it, maybe default is not to fallback. But I think default is to fallback to files. Let's check typical completion for `apt-cache search`: they just set COMPREPLY; no fallback. So maybe not fallback. Let's keep simple: just set COMPREPLY and return. The requirement says: If no matches, no suggestions, no errors. So we set COMPREPLY=() and return. That should not produce fallback.
#
#We also need to ensure duplicates are removed: We can use `sort -u`.
#
#Let's implement function `_ollama_run`. Steps:
#
#```
#_ollama_run() {
#  local cur prev words cword
#  cur=${COMP_WORDS[COMP_CWORD]}
#  prev=${COMP_WORDS[COMP_CWORD-1]}
#  words=${COMP_WORDS[@]}
#  cword=$COMP_CWORD
#
#  # Only trigger after 'run'
#  if [[ ${COMP_WORDS[1]} != run ]]; then
#    return
#  fi
#
#  # Get list of models
#  local models
#  models=$(ollama list | awk 'NR>1 {print $1}')
#  # Remove duplicates
#  models=$(printf "%s\n" "$models" | sort -u)
#
#  # Filter based on cur
#  local IFS=$'\n'
#  COMPREPLY=()
#  for m in $models; do
#    if [[ $m == $cur* ]]; then
#      COMPREPLY+=("$m")
#    fi
#  done
#
#  # No fallback
#  return
#}
#```
#
#We might use `compgen -W` to generate completions. But we need to filter ourselves. But we can use compgen with -W: `COMPREPLY=( $(compgen -W "$models" -- "$cur") )`. That will handle prefix. It will automatically filter. But we need to preserve duplicates? compgen may produce duplicates if models has duplicates; but we removed duplicates. That is fine. Use `IFS=$'\n'` to preserve spaces. But compgen will split on whitespace. Our model names have colon, not whitespace. So fine.
#
#But we should also set `COMPREPLY=($(compgen -W "$models" -- "$cur"))`. That is fine.
#
#Also we might want to handle the case when user typed nothing after run: cur is "", then compgen will produce all. Good.
#
#We also want to set `compopt -o default`? Might not needed. Let's just set COMPREPLY.
#
#But we also need to set the completion for command. At end:
#
#```
#complete -F _ollama_run ollama
#```
#
#But we must restrict to subcommand run only. The function will handle that.
#
#Alternatively, we can use `complete -F _ollama_run -o default ollama`. But we don't want default fallback. So we can skip -o default. But maybe default fallback triggers file completion if COMPREPLY empty. Not sure. The requirement says: no filename fallback. We can force by setting `compopt -o default`? Hmm.
#
#We can use `complete -o default -F _ollama_run ollama`. Actually -o default means fallback? Actually -o default is to use default completion behavior. So that would cause file fallback. We don't want that. So skip -o default. Without -o default, only COMPREPLY matters. So okay.
#
#Thus script:
#
#```
##!/usr/bin/env bash
## Bash completion script for 'ollama run' model names.
#
#_ollama_run() {
#  local cur
#  cur="${COMP_WORDS[COMP_CWORD]}"
#
#  # Ensure we are completing after 'run'
#  if [[ "${COMP_WORDS[1]}" != "run" ]]; then
#    return
#  fi
#
#  # Get unique model names from 'ollama list'
#  local models
#  models=$(ollama list | awk 'NR>1 {print $1}' | sort -u)
#
#  # Use compgen to generate completions filtered by current word
#  COMPREPLY=( $(compgen -W "$models" -- "$cur") )
#}
#
## Register the completion function for the 'ollama' command.
#complete -F _ollama_run ollama
#```
#
#But we need to be careful: We need to preserve duplicates? We removed duplicates via sort -u. Good.
#
#We also need to use `IFS=$'\n'`? Actually compgen splits on spaces. Our model names don't contain spaces, so it's fine.
#
#We should also set `local IFS=$'\n'` maybe not needed.
#
#Also we might need to use `local cur prev` but not used. Not necessary.
#
#Also we may want to use `COMPREPLY=()` if no matches? compgen returns empty array, COMPREPLY will be empty. Good.
#
#Need to avoid fallback: We don't set -o default, so no fallback. Good.
#
#Edge: If `ollama list` fails? We could handle errors? Not required.
#
#Also we need to support quoting? Not required.
#
#Let's produce final script.
#
#Also we might need to include `#!/usr/bin/env bash` at top? It's optional. But we can include.
#
#Let's produce final answer.
#...done thinking.

#!/usr/bin/env bash
# Bash completion script for `ollama run` – suggests local model names.
#
# Usage:
#   source this_file.sh
#   (or add the file to ~/.bash_completion and source it from your shell rc)

# Completion function for the 'ollama' command.
# It activates only when the subcommand is 'run' and proposes model names
# obtained from `ollama list`.  Filenames are never suggested.
_ollama_run() {
    # Current word being completed.
    local cur="${COMP_WORDS[COMP_CWORD]}"

    # Trigger only when the second word is exactly 'run'.
    if [[ "${COMP_WORDS[1]}" != "run" ]]; then
        return
    fi

    # Grab the list of local models from `ollama list`.
    # Skip the header line (NR>1) and keep only the first column (model name).
    # Remove duplicates just in case.
    local models
    models=$(ollama list | awk 'NR>1 {print $1}' | sort -u)

    # Generate completions filtered by the current word.
    # If there is no match, COMPREPLY will be empty – no filename fallback.
    COMPREPLY=( $(compgen -W "$models" -- "$cur") )
}

# Register the completion function for the `ollama` command.
complete -F _ollama_run ollama


