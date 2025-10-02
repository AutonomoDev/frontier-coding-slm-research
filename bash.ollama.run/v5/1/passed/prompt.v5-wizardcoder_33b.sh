# [[HUMAN COMMENTED-OUT]]
#Sure, here's a bash completion script that satisfies all your requirements:
#!/bin/bash
_ollama()
{
    local cur prev words cword split
    _get_comp_words_by_ref -n :=: cur prev words cword

    case $prev in
        run)
            # Get a list of model names from the first column of 'ollama list' output.
            local models=$(ollama list | awk 'NR>1 {print $1}')

            # Remove duplicates by piping to sort -u and then using mapfile to read into an array
            local -a model_array="($(echo "$models" | sort -u))"

            # Use compgen for filename matching
            COMPREPLY=( $(compgen -W '${model_array[*]}' -- "$cur") )
        ;;
    esac
}

complete -F _ollama ollama

# [[HUMAN COMMENTED-OUT]]
#This script creates a completion function `_ollama` that's triggered when the previous word is "run". It gets the list of models by parsing the output of 'ollama list'. The list is then cleaned up to remove duplicates, and compgen provides filename matching for model names based on what the user has typed so far. If a model name doesn't match what the user has typed, it won't be suggested, fulfilling your requirement to not suggest filenames from the current directory.

