#!/bin/bash

# _ollama_completions() implements completion for the ollama command. It is
# invoked whenever the user hits the Tab key after typing part of a valid
# invocation. The function relies on Bash's programmable completion
# facilities, as provided by the bash-completion package.

# NOTE: This script assumes that bash-completion version 2 or later is
# installed and configured correctly.
_ollama_completions() {
    # COMP_WORDS is an array of words in the current command line.
    # COMP_CWORD is the index of the current word (the one the user is
    # trying to complete). So COMP_WORDS[COMP_CWORD] is the current word.
    local cur prev words cword
    _get_comp_words_by_ref -n =: cur prev words cword

    # Do not try to complete the command name, i.e., the first word in the
    # command line; this would be a waste of time since we are only defining
    # completion for one specific command (ollama). The user could already
    # have typed "ollama" on their own if they wanted that.
    if [[ "$prev" = ollama ]]; then
        # If the previous word is "ollama", it means the current word is a
        # subcommand or option of the command, so we need to complete them.
        COMPREPLY=($(compgen -W "run" -- "$cur"))
    else
        # Otherwise, we are completing model names for the ollama run
        # subcommand. To correctly parse model names with colons, we need to
        # temporarily remove ':' from COMP_WORDBREAKS and re-parse the
        # command line using _get_comp_words_by_ref with -n : to handle
        # colons properly.
        local comp_wordbreaks=$COMP_WORDBREAKS
        COMP_WORDBREAKS=${COMP_WORDBREAKS//:}
        local prev cur words cword
        _get_comp_words_by_ref -n : cur prev words cword

        # Generate completions based on the output of ollama list. We use
        # awk to extract only the first column starting from the second line,
        # which gives us the model names.
        COMPREPLY=($(compgen -W "$(ollama list | awk 'NR>1 {print $1}')" -- "$cur"))
        COMP_WORDBREAKS=$comp_wordbreaks
    fi
}

# Register the completion function with the bash-completion framework. This
# is done by creating a file named _ollama in one of the directories specified
# by the $fpath variable, which is an array of directories that Bash will
# search for completion functions whenever a command name matches the
# pattern /_*/. The contents of this file will be sourced as a Bash script,
# so we must ensure that it does not produce any syntax errors.
#
# Note that the function _ollama_completions is defined above and sourced
# before this registration code runs. Therefore, there should be no errors in
# sourcing this file.
complete -F _ollama_completions ollama
