# [[HUMAN COMMENTED-OUT]]
# Thinking...
# Alright, I need to fix the condition check in the Bash completion script for the `ollama run` command. Let me think through this step by step.
#
# First, understanding the problem: The current script's condition is incorrect, causing it to activate when it shouldn't. The requirement is that the script should only activate when the command is exactly `ollama run`. 
#
# Looking at the structure of `COMP_WORDS`, I remember that indexes start at 0. So for `ollama run`, `COMP_WORDS[0]` is "ollama" and `COMP_WORDS[1]` is "run". The current condition might be checking the wrong indices, leading to activation in incorrect scenarios.
#
# The user mentioned a common pitfall where people reference `COMP_WORDS[1]` as the command name, which it's not—it's actually the first argument. So I need to ensure that we're correctly checking the command name and the first argument.
#
# The root cause is the array indexing. The original condition might have been using `[2]` instead of `[1]`. To fix this, the condition should check if either `COMP_WORDS[0]` isn't "ollama" or `COMP_WORDS[1]` isn't "run". That way, the script only activates when both are correct.
#
# So, I'll modify the condition to:
# `[[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]`
#
# This ensures that the script doesn't activate unless the command is exactly `ollama run`. The rest of the script remains unchanged because it's handling colons and model extraction correctly.
#
# I also need to ensure that I don't alter any other parts of the script, like how models are parsed or how colons are handled. Only the condition line should be changed.
#
# Let me double-check: When the user types `ollama run <TAB>`, `COMP_WORDS` will have `[0]` as "ollama" and `[1]` as "run". The new condition correctly activates the completion here. For other commands like `ollama somethingelse`, the condition won't be met, so the script doesn't run.
#
# I think that's it. This should fix the activation issue without affecting other functionalities.
# ...done thinking.

_ollama_run() {
    local cur prev command
    COMPREPLY=
    _get_comp_words_by_ref -n : cur prev
    if [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]; then
        return
    fi

    local models=(
        $(ollama list | sed '1d' | grep -v '^$' | cut -d "$FS" -f 1)
    )

    compset -P 'llama:' && compadd -a models
}

complete -F _ollama_run ollama
