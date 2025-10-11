#!/usr/bin/env bash

# Thinking...
# We need to produce a bash-completion script for `ollama run <model>`. It should list available models by parsing output of `ollama list`. The script must be self-contained, with comments and installation snippet.
#
# We need to use Bash completion conventions. Usually completions are defined with `_ollama_run` function, etc. Use `complete -F _ollama_run ollama` or `complete -F _ollama_run ollama` only when command is `ollama`? Actually we want to provide completion for `ollama run <model>`. So the script should complete after "ollama run". We can set `complete -F _ollama_run ollama` and then check inside function whether first word after command is "run". Or we can use `complete -F _ollama_run ollama` and inside we filter.
#
# We must parse output of `ollama list` (no formatting flags). The sample output includes header line: "NAME ID SIZE MODIFIED" and then lines with model names. Model names contain colon. They may contain spaces? Probably not. But colon may appear. We just need to list model names: first column of each data line. Should ignore header.
#
# We should capture output of `ollama list` and process. Since it's one per line or separated by whitespace. But sample shows each line has one entry per row. We can read the output via `while read -r line; do ...` but we need to skip header. We can skip first line: use `tail -n +2`. Use command substitution to produce list.
#
# Implementation: function _ollama_run() {
#   local cur prev words
#   cur="${COMP_WORDS[COMP_CWORD]}"
#   prev="${COMP_WORDS[COMP_CWORD-1]}"
#   local i
#   if [[ ${prev} == "run" ]]; then
#     # get models
#     local models
#     models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}')
#     COMPREPLY=( $(compgen -W "${models}" -- "${cur}") )
#   fi
# }
#
# Edge: We must not error if ollama list fails; redirect to /dev/null.
#
# We need to be careful about word splitting and globbing. Use compgen -W.
#
# Make sure to escape properly.
#
# Add comment, installation snippet: source this file or add to /etc/bash_completion.d/ollama.
#
# Better: Provide full script: maybe start with shebang #!/usr/bin/env bash but not necessary for completion. But we can produce script that defines function and calls complete.
#
# Make script as .sh file.
#
# Also maybe support older bash: Use local variables, etc.
#
# Ok produce final script.
# ...done thinking.

# /etc/bash_completion.d/ollama   (or ~/.bash_completion.d/ollama)
# Bash completion for `ollama run <model>`
#
# It dynamically lists available Ollama models by parsing the output of
# `ollama list`.  The completion works only when the word before the cursor
# is "run".  Errors from `ollama list` are silenced so that the shell
# completion never aborts.

_ollama_run()
{
    local cur prev words

    # Current word being completed and previous word
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    # Provide completions only after "ollama run"
    if [[ "$prev" == "run" ]]; then
        # Grab the first column of every line after the header.
        # If `ollama list` fails, nothing will be completed.
        local models
        models=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}')

        # Generate the completion list
        COMPREPLY=( $(compgen -W "${models}" -- "$cur") )
    fi
}

# Attach the completion function to the `ollama` command.
complete -F _ollama_run ollama
