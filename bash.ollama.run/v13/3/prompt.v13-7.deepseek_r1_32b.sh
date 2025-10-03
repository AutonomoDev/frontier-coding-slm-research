# Thinking...
# Alright, I need to help fix a Bash shell completion script for the `ollama` command. The user provided specific requirements and identified that the issue lies in incorrect array indexing within the condition check. Let me break down how I would approach this.
#
# First, I'll review the problem statement carefully. The goal is to make sure the completion script only activates when the command is `ollama run`. This means checking if the first word is "ollama" and the second word is "run". 
#
# In Bash completions, `COMP_WORDS` is an array where each element corresponds to a part of the command line. So, for the command `ollama run <TAB>`, `COMP_WORDS[0]` should be "ollama", and `COMP_WORDS[1]` should be "run". The current script might have a condition that incorrectly checks these indices, leading to the completion not activating when it should.
#
# The user mentioned that the root cause is incorrect array indexing. So I need to ensure that in the condition, we're checking `[0]` for "ollama" and `[1]` for "run". The original script might have had a different check, perhaps looking at `[1]` as the command name or something else.
#
# Looking at the provided corrected script, the condition is:
# [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]
#
# This makes sense because we want to only proceed with completion if both conditions are met. If either is not true, we return without completing. So this condition correctly ensures that we're in the context of `ollama run`.
#
# I also need to ensure that other parts of the script remain unchanged. The handling of colons in model names and processing `ollama list` output should stay as they are, since those parts were working correctly except for the activation condition.
#
# So, in summary, the key step is modifying the condition to check the correct indices in `COMP_WORDS`. This ensures that the completion only triggers when the command is `ollama run`, preventing it from activating incorrectly and ensuring proper model name suggestions.
# ...done thinking.

# bash_completion: ollama completion script

_ollama()
{
    local cur prev words cword
    _get_comp_words_by_ref -n : cur prev words cword

    if [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]; then
        return 0
    fi

    local models=$(ollama list --json | jq -r '."models"[] | .name' | grep -v "^$")
    COMPREPLY=($(compgen -W "$models" -- "$cur"))
    __ltrim_colon_completions "$cur"
}

complete -F _ollama ollama
