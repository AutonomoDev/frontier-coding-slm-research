##Thinking...
##The user wants code blocks only, no commentary outside. They require a series of bash code snippets progressively demonstrating concepts. They want code that could be saved directly to .sh file. Should include comments inside the code.
##
##We need to produce a single contiguous block of code. It includes:
##
##1. Simple Static Completion: one-line complete command for example_cmd.
##
##2. Dynamic Completion with a function: _example_cmd_completions.
##
##3. Context-Aware Completion: _app_completions.
##
##4. Advanced Completion for Non-Standard Word Breaks: _ollama_completions.
##
##5. Installation instructions as code comments: commented block showing how to source completion files from ~/.bash_completion.d within ~/.bashrc.
##
##We need to embed comments within code for each section. We must not add commentary outside the code. Also the advanced section must include code snippet that explains solution. They also provide some commented code at end of prompt that should be included as part of solution? They inserted a sample block. We need to integrate that into our code.
##
##We need to ensure we follow bash-completion v2: use _get_comp_words_by_ref.
##
##Thus produce:
##
### 1. Simple Static Completion
##complete -W "option1 option2 option3" example_cmd
##
### 2. Dynamic Completion with a Function
##_example_cmd_completions() {
##    local cur
##    cur="${COMP_WORDS[COMP_CWORD]}"
##    COMPREPLY=( $(compgen -W "option1 option2 option3" -- "$cur") )
##}
##complete -F _example_cmd_completions example_cmd
##
### 3. Context-Aware Completion
##_app_completions() {
##    local cur prev
##    cur="${COMP_WORDS[COMP_CWORD]}"
##    prev="${COMP_WORDS[COMP_CWORD-1]}"
##    if [[ "$prev" == "app" ]]; then
##        COMPREPLY=( $(compgen -W "run list pull" -- "$cur") )
##    elif [[ "$prev" == "run" ]]; then
##        COMPREPLY=( $(compgen -W "model:small model:large" -- "$cur") )
##    fi
##}
##complete -F _app_completions app
##
### 4. Advanced Completion for Non-Standard Word Breaks
##_ollama_completions() {
##    local cur prev
##    # The CORE PROBLEM...
##    local _old_wb=${COMP_WORDBREAKS}
##    COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}
##    _get_comp_words_by_ref -n : cur prev
##    COMP_WORDBREAKS=${_old_wb}
##    # If the subcommand is run, complete models
##    if [[ "${COMP_WORDS[1]}" == "run" ]]; then
##        local models
##        models=$(ollama list | awk 'NR>1 {print $1}')
##        COMPREPLY=( $(compgen -W "$models" -- "$cur") )
##    fi
##}
##complete -F _ollama_completions ollama
##
### 5. Installation instructions as code comments
### To automatically source completion files from ~/.bash_completion.d in ~/.bashrc:
###   # Load bash-completion if available
###   if [ -f /usr/share/bash-completion/bash_completion ]; then
###     . /usr/share/bash-completion/bash_completion
###   fi
###   # Source all *.sh files in ~/.bash_completion.d
###   if [ -d ~/.bash_completion.d ]; then
###     for f in ~/.bash_completion.d/*.sh; do
###       [ -r "$f" ] && . "$f"
###     done
###   fi
##
##We also need to include the commented code snippet from the prompt maybe inside _ollama_completions comments. They provide block starting with "# THE CORE PROBLEM". We can include that as comments inside _ollama_completions. The earlier comment lines we already included.
##
##Let's assemble final code accordingly. Ensure only code. Let's produce.
##...done thinking.
#
#```bash
## 1. Simple Static Completion
## The simplest form of completion using the -W flag.
#complete -W "option1 option2 option3" example_cmd
#
## 2. Dynamic Completion with a Function
## _example_cmd_completions uses COMP_WORDS and COMP_CWORD to find the current word (cur),
## compgen -W to filter the static list, and assigns the results to COMPREPLY.
#_example_cmd_completions() {
#    local cur
#    cur="${COMP_WORDS[COMP_CWORD]}"
#    COMPREPLY=( $(compgen -W "option1 option2 option3" -- "$cur") )
#}
#complete -F _example_cmd_completions example_cmd
#
## 3. Context-Aware Completion
## _app_completions provides subcommand completion for 'app' and model name completion
## when the subcommand is 'run'.
#_app_completions() {
#    local cur prev
#    cur="${COMP_WORDS[COMP_CWORD]}"
#    prev="${COMP_WORDS[COMP_CWORD-1]}"
#    if [[ "$prev" == "app" ]]; then
#        COMPREPLY=( $(compgen -W "run list pull" -- "$cur") )
#    elif [[ "$prev" == "run" ]]; then
#        COMPREPLY=( $(compgen -W "model:small model:large" -- "$cur") )
#    fi
#}
#complete -F _app_completions app

# 4. Advanced Completion for Non-Standard Word Breaks
# This function handles the 'ollama' command, specifically the 'run' subcommand,
# and correctly completes model names that contain colons.
_ollama_completions() {
    local cur prev
    # THE CORE PROBLEM: By default, Bash splits words on ':', so typing "codellama:"
    # makes the previous word "codellama" and the current word an empty string.
    # This breaks our context logic for completing model names.
    #
    # THE SOLUTION: We temporarily remove ':' from the word-breaking characters
    # and use a helper function to re-parse the command line with our new rule.
    #
    # 1. Save the original word break characters.
    local _old_wb=${COMP_WORDBREAKS}
    # 2. Modify COMP_WORDBREAKS to remove the colon.
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}
    # 3. Use the helper to re-parse and correctly set `cur` and `prev`.
    #    The `-n :` option tells it to NOT use the colon as a separator.
    _get_comp_words_by_ref -n : cur prev
    # 4. Restore the original word breaks immediately to avoid side-effects.
    COMP_WORDBREAKS=${_old_wb}

    # Now, `cur` and `prev` are correct even when a colon is typed.
    # e.g., for `ollama run codellama:`, `prev` will be "run", not "codellama".
    if [[ "${COMP_WORDS[1]}" == "run" ]]; then
        local models
        models=$(ollama list | awk 'NR>1 {print $1}')
        COMPREPLY=( $(compgen -W "$models" -- "$cur") )
    fi
}
complete -F _ollama_completions ollama

# 5. Installation Instructions as Code Comments
# To automatically source completion files from ~/.bash_completion.d in ~/.bashrc:
#   # Load bash-completion if available
#   if [ -f /usr/share/bash-completion/bash_completion ]; then
#     . /usr/share/bash-completion/bash_completion
#   fi
#   # Source all *.sh files in ~/.bash_completion.d
#   if [ -d ~/.bash_completion.d ]; then
#     for f in ~/.bash_completion.d/*.sh; do
#       [ -r "$f" ] && . "$f"
#     done
#   fi
```

