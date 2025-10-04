#<think>
#We are Phi, need to produce a bash completion function for command "ollama run <model>" that dynamically lists available models by parsing output of `ollama list`. The sample input is given as sample output.
#
#Let's first think: We need a bash script that defines a bash-completion function. We'll create function _ollama_run. And then we need to register it with "complete -F _ollama_run ollama" or similar, but not exactly because command is "ollama run <model>" i.e. subcommand "run". But I think the bash completion should be for "ollama run", so if user types ollama run, then after that we want to parse output of `ollama list` and produce a list of models. We can do something like: function _ollama_run_completion() { local cur prev opts; COMPREPLY=(); cur="${COMP_WORDS[COMP_CWORD]}"; previous=${COMP_WORDS[COMP_CWORD-1]}; then maybe we want to list available model names using ollama list command.
#
#I need to output a self-contained script. It should include installation snippet at the end, that is, how to install it.
#
#We need to produce a self-contained bash script with comments and installation instructions.
#
#We are told: "Focus on correctness and portability."
#
#The task: Create a bash completion function for the command `ollama run <model>` that dynamically lists available models by parsing output of `ollama list` without external dependencies. Assume `ollama list` prints model names one per line (or separated by whitespace) when run with no formatting flags.
#
#Wait, sample output "ollama list" is as given in the question: It shows header lines "NAME ID SIZE MODIFIED", then three lines of models? Actually sample has 5 lines total. The first line includes column headers, but maybe we want to ignore header lines or not. But it says that when run with no formatting flags, ollama list prints model names one per line. That might mean that if we call "ollama list --format plain" then it's different? But anyway.#
#We assume the output is in a typical table format and we want to extract the first column (which is the NAME) from each line. So we can run command: ollama list 2>/dev/null | sed '1d' | awk '{print $1}' but that would require sed and awk, but they are standard utilities on POSIX systems. But the question says "without using any external dependencies" so is it allowed? They said no third-party dependencies like jq but can use awk and sed because those are usually available in typical bash environments.
##I need to note: "Do not include any external dependencies (no jq, no external binaries beyond what a typical POSIX/bash environment has)". Usually "sed", "awk", "grep" etc are considered standard. So it's fine.
#
#We must fail gracefully if underlying commands error. That means we want to capture errors from ollama list and then do nothing or output empty suggestion? It said: "Fail gracefully if underlying commands error (e.g., silence failures so the shell doesn’t break)". So in our function, we need to call "ollama list" and catch its failure and then exit gracefully. We can use something like:
#models=$(ollama list 2>/dev/null | sed '1d' | awk '{print $1}' ) maybe with an error check if [ $? -ne 0 ]? But maybe I'll capture errors in COMPREPLY, but better is to not let them cause completion to fail.
#
#We can do: local models=$(ollama list 2>/dev/null || true) then parse. But note that the "|| true" ensures command will succeed even if ollama fails.
#
#Wait, careful: The command "ollama list" might error out if the command doesn't exist. So we want to capture errors gracefully. We can do:
#models=$(ollama list 2>/dev/null | sed '1d' | awk '{print $1}') but then check if models is empty maybe? But that's fine.
##I need to consider: The completion function should only complete the model parameter for "ollama run", so it must be triggered when there are at least 2 arguments: e.g. "ollama run" and then a partial word. So we want:
#function _ollama_run() {
#  local cur prev opts
#  COMPREPLY=()
#  cur="${COMP_WORDS[COMP_CWORD]}"
#  # If there's exactly two words, it might be "ollama run", but if third argument provided, then that is the model name? Let's check: The command is "ollama run <model>". So the completion should be done on the <model> parameter. But our COMP_WORDS array: index 0: ollama, index 1: run, index 2: maybe a partial word for model. So if ${#COMP_WORDS[@]} -lt 3 then no completions.#  
#  # Alternatively we can check that the command is "ollama" and the second argument is "run", i.e. COMP_WORDS[1] equals "run". If not, just do nothing.
#
#  local cword=${COMP_CWORD}
#  if [[ ${#COMP_WORDS[@]} -lt 3 ]]; then
#      return
#  fi
#
#  # Check that first two arguments are correct.
#  if [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]; then
#    return
#  fi
#
#  # Now get models. Use command substitution and filter header line, maybe check if the output has a header line? But sample suggests that first line might be header.
#  local models
#  models=$(ollama list 2>/dev/null | { 
#          # The script: if first line is "NAME ID SIZE MODIFIED", then skip it. Use grep to filter out lines starting with NAME.
#          grep -v '^NAME ' || true;
#         } | awk '{print $1}')
#
#  COMPREPLY=( $(compgen -W "$models" -- "$cur") )#  return 0
#}
#
#But maybe simpler: I'll do a check: if [ ${#COMPREPLY[@]} -eq 0 ] then nothing.
#
#However, we must ensure that the function is self-contained. We need to add "complete -F _ollama_run ollama" at the end. But wait, note that command is "ollama run", so maybe we want to define completion for "ollama". But some people might prefer a separate completion for "run". Actually I should register the function with "complete -F _ollama_run ollama run" but typically, if a command is a subcommand of another command that has its own completions, sometimes you need to do something like:#complete -F _ollama_run ollama
#But then only complete for when second word is run. But in our function we check first two words are "ollama" and "run". So it's fine.#
#I can do: complete -F _ollama_run ollama
#
#We need to include a snippet for installation, maybe:
#
#Installation:
#- Save this file as /etc/bash_completion.d/ollama-completion.bash or in your home directory.
#- Then add the following line to your .bashrc if not already present: "source /path/to/ollama-completion.bash".
#
#I want to produce self-contained script with comments.
#
#I need to mention that it must be a self-contained bash script. Use only built-in commands.
#
#We can use "compgen" for generating completions.
##What is compgen? Yes, compgen is builtin command in bash for generating possible completions.
#
#I also want to note that I'm using sed and awk which are standard utilities available on a typical POSIX environment.
#
#Let's produce complete code:
#
#-----
##!/bin/bash
## ollama completion function
#
#_ollama_run() {
#    # This function provides tab-completion for the "ollama run <model>" command.
#    local cur prev opts
#    COMPREPLY=()
#    cur="${COMP_WORDS[COMP_CWORD]}"
#    
#    # Check if at least two arguments ("ollama" and "run") are provided.
#    if [[ ${#COMP_WORDS[@]} -lt 2 ]]; then
#        return
#    fi
#    
#    # Ensure we're completing the model argument for "ollama run"
#    if [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]; then
#        return
#    fi
#
#    # Retrieve available models by parsing the output of 'ollama list'#    local models
#    models=$(ollama list 2>/dev/null | sed '/^NAME /d' | awk '{print $1}')
#
#    # Generate completion suggestions using compgen.
#    COMPREPLY=( $(compgen -W "$models" -- "$cur") )
#}
#
## Register the completion function for the 'ollama' command.
#complete -F _ollama_run ollama
#
## Installation snippet:
## To enable this bash-completion, save this script to a file (e.g., /etc/bash_completion.d/ollama-completion.bash)
## and ensure it is sourced by your shell. For example, add the following line to your ~/.bashrc if not already present:
##
##   [ -r /etc/bash_completion ] && . /etc/bash_completion
## or source this file directly:
##   . /path/to/ollama-completion.bash
##
## This will activate bash completion for the 'ollama run <model>' command.
#-----
#
#That's it.
#
#I'll produce a complete self-contained script with comments and installation snippet. I need to output exactly that as the final answer, no markdown formatting by default? Actually instructions said: "Your solution must be a self-contained Bash script. Only the complete script with comments and the installation snippet." Do not include anything else. And by default we should produce plain text.
#
#I'll produce a script starting with #!/bin/bash then function _ollama_run() etc, register completion, include installation instructions as comments at bottom.
#
#I'll produce final answer in plain text.
#
#I'll now produce the final answer.
#</think>
#!/bin/bash
# This is a self-contained bash-completion script for the command "ollama run <model>".
# It dynamically lists available models by parsing the output of "ollama list".
#
# The script uses only built-in bash commands and standard utilities (sed, awk)
# which are assumed to be available in a typical POSIX/bash environment.
#
# To install this completion:
# 1. Save this script as /etc/bash_completion.d/ollama-completion.bash or another appropriate location.
# 2. Ensure that your shell sources the completions directory. For example, add
#      [ -r /etc/bash_completion ] && . /etc/bash_completion
#    to your ~/.bashrc if it isn't already present.
# 3. Reload your terminal or source the file directly:
#      . /path/to/ollama-completion.bash

_ollama_run() {
    # This function provides bash completion for "ollama run <model>".
    local cur prev opts
    COMPREPLY=()
    
    # Only provide completions if at least two arguments are present ("ollama" and "run").
    if [[ ${#COMP_WORDS[@]} -lt 2 ]]; then
        return
    fi
    
    # Ensure we're completing the model argument for "ollama run".
    if [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]; then
        return
    fi

    # Retrieve available models by running "ollama list" and parsing its output.
    # The script assumes that the first line (header) starts with "NAME ".
    local models
    models=$(ollama list 2>/dev/null | sed '/^NAME /d' | awk '{print $1}')

    # Generate completion suggestions using compgen.
    COMPREPLY=( $(compgen -W "$models" -- "${COMP_WORDS[COMP_CWORD]}") )
}

# Register the bash-completion function for the "ollama" command.
complete -F _ollama_run ollama

# Installation snippet:
# To enable this completion, save this script to a file (e.g., /etc/bash_completion.d/ollama-completion.bash)
# and ensure it is sourced by your shell. For example, add the following line to your ~/.bashrc if not already present:
#
#   [ -r /etc/bash_completion ] && . /etc/bash_completion
#
# Alternatively, source this file directly:
#   . /path/to/ollama-completion.bash
