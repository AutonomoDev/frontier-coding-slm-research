# Thinking...
# We need to output a bash-completion script for ollama run <model>. Use COMPREPLY array. We need to parse ollama list output. We need to ensure robust and graceful error handling. Use built-in arrays. Should filter by prefix. The script may use declare -a models.
# 
# We can use COMPREPLY=() and then if [[ $cur == -* ]]; etc.
# 
# We need to provide installation instructions.
# 
# We need to ensure it works with bash completion system: we need to register completion function with complete -F function_name.
# 
# We might create a function _ollama_run_completion. It will check COMP_WORDS[COMP_CWORD] to get current word.
# 
# Also we need to ensure we only provide completions for second word after "ollama run". So the function should handle that. Also if user typed "ollama" and maybe partial run etc. But simplest: if the previous word is "run" or if the command is "ollama" and current word index is 2 (after "run").
# 
# Better: For general, we can simply provide completions if the first word is "ollama" and second is "run" and we're at word index 2 or greater? Actually we want to complete the model name at word index 2 (0-indexed?). COMP_WORDS array: COMP_WORDS[0] = command ("ollama"), COMP_WORDS[1] = "run". COMP_WORDS[2] = the model being typed. So we need to supply completions for COMP_WORDS[2].
# 
# But if the user hasn't typed "run" yet, we may not want to do completions. So we only fill if COMP_WORDS[1] == "run". And we also might want to check if current word index is 2.
# 
# Ok.
# 
# Now for parsing ollama list. The output could be model names separated by whitespace. We'll call `ollama list` and read lines into array. Use mapfile -t models < <(ollama list 2>/dev/null) ; but mapfile may not be POSIX but it's bash built-in. It's fine. But we need to silence errors. So `models=($(ollama list 2>/dev/null))` might also split on IFS. That would handle whitespace separated names. But names could contain spaces? Possibly not; likely model names don't contain spaces. So okay.
# 
# Better to use readarray or mapfile. Use readarray -t models < <(ollama list 2>/dev/null). This sets models array to lines.
# 
# Now filter: Use `COMPREPLY=( $(compgen -W "${models[*]}" -- "$cur") )` is simpler. But compgen uses the array of words. That uses shell expansion. Might be okay. But we might want to use pure filtering ourselves. But using compgen is fine. It's built-in to bash.
# 
# But the requirement says only built-in shell string manipulation and arrays. compgen is built-in. So we can use it.
# 
# However, we need to be careful with quoting to avoid word splitting incorrectly. Use `COMPREPLY=( $(compgen -W "${models[*]}" -- "$cur") )`. But this will run compgen and produce words.
# 
# But we need to ensure `models` array is set before that. So after readarray.
# 
# Now for errors: if ollama list fails, readarray will produce empty array, or if command not found, it will produce error. We redirect error to /dev/null, so no error. But we also need to catch if command fails: maybe the command exists but fails with non-zero exit code; but readarray will still read output? If fails, still reading. But we can ignore. If command not found, readarray will produce error; but we suppressed error? The error message would still be printed? We used 2>/dev/null. That should suppress. But readarray will still produce exit status. We can ignore exit status. So no completions.
# 
# Thus the function:
# 
## _ollama_run_completion() {
#     local cur prev words cword
#     _get_comp_words_by_ref -n : cur prev words cword
# 
#     # Only provide completion after 'run'
#     if [[ ${words[1]} != "run" ]]; then
#         return
#     fi
# 
#     # Get models
#     local -a models
#     if ! readarray -t models < <(ollama list 2>/dev/null); then
#         return
#     fi
# 
#     COMPREPLY=( $(compgen -W "${models[*]}" -- "$cur") )
# }
## 
# But _get_comp_words_by_ref is part of bash completion library. But we don't want to rely on that? Usually we can just use COMP_WORDS and COMP_CWORD. So:
# 
# ```
# local cur=${COMP_WORDS[COMP_CWORD]}
# local prev=${COMP_WORDS[COMP_CWORD-1]}
# ```
# 
# But we need to be careful for CWORD=0.
# 
# So:
# 
## local cur=${COMP_WORDS[COMP_CWORD]}
# local prev=${COMP_WORDS[COMP_CWORD-1]}
# ```
# 
# We also want to check if COMP_WORDS[1] == "run" to limit.
# 
# So:
# 
## if [[ ${COMP_WORDS[1]} != "run" ]]; then
#     return
# fi
# ```
# 
# Now we can parse.
# 
# Also handle prefix: compgen handles prefix automatically.
# 
# Edge: The user typed "ollama run" and no model typed yet; cur will be empty; compgen will list all models. That works.
# 
# Now we register:
# 
# ```
# complete -F _ollama_run_completion ollama
# ```
# 
# But that would also provide completions for all subcommands? But we want only for run. However we can restrict by using -F _ollama_run_completion -X '!run' ??? We could use -F and then inside function check. So fine.
# 
# Now installation instructions: "Save the script to a file like /etc/bash_completion.d/ollama_run_completion.sh or ~/.local/share/bash-completion/completions/ollama" and then source it or reload. Usually you can run `source /path/to/script` or `complete -F`.
# 
# Let's produce final script.
# 
# But we need to mention "shell script" comment. Provide minimal but clear installation instructions.
# 
# Ok.
# 
# Let's produce final answer.
# ...done thinking.

# ──────────────────────────────────────────────────────────────────────
# Bash completion for `ollama run <model>`
# 
# This file defines a completion function that fetches the list of
# available Ollama models (via `ollama list`) and offers them as
# completions for the `run` subcommand.
# ──────────────────────────────────────────────────────────────────────

# Completion function
_ollama_run_completion() {
    local cur prev
    # Current word being completed
    cur="${COMP_WORDS[COMP_CWORD]}"

    # Only act when the command is "ollama" and the first argument is "run"
    if [[ ${COMP_WORDS[1]} != "run" ]]; then
        return
    fi

    # Fetch the list of models.  Silence errors; if the command fails,
    # we simply return with no completions.
    local -a models
    if ! readarray -t models < <(ollama list 2>/dev/null); then
        return
    fi

    # Use compgen to apply the prefix filter and populate COMPREPLY
    COMPREPLY=( $(compgen -W "${models[*]}" -- "$cur") )
}

# Register the function with the shell completion system
complete -F _ollama_run_completion ollama

# [[HUMAN COMMENTED-OUT]]
# ### Installation
# 
# 1. **Save the script**  
#    Place the above code in a file, e.g. `~/.bash_completion_ollama_run.sh`.
# 
# 2. **Activate it**  
#    ```bash
#    # Either source the file manually
#    source ~/.bash_completion_ollama_run.sh
# 
#    # Or add it to your ~/.bashrc / ~/.bash_profile:
#    #   if [ -f ~/.bash_completion_ollama_run.sh ]; then
#    #       source ~/.bash_completion_ollama_run.sh
#    #   fi
# 
# 
# 3. **Reload your shell** (or start a new terminal) to use the completion immediately.
