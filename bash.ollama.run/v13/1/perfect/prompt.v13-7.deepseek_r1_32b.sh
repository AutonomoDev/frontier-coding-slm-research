#Thinking...
#Okay, I need to figure out how to correct the Bash shell completion script for the `ollama` command, specifically for the `ollama run <model>` part. The user has given some critical requirements and common pitfalls to avoid, so I should go through each of them step by step.
#
#First, the main issue is that the script only activates when the command is `ollama run`. So, in the COMP_WORDS array, the first element (index 0) should be "ollama" and the second element (index 1) should be "run". The original condition was checking if either of these wasn't correct. But wait, looking at the user's fix, they mentioned that the root cause is incorrect array indexing. So I think the previous script might have been incorrectly referencing the wrong indices.
#
#The critical requirement says to check if `[0]` is "ollama" AND `[1]` is "run". So in the completion function, the condition should be `[[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]`. That makes sense because it ensures both conditions are met before proceeding.
#
#Next, handling colons in model names. The script needs to use `_get_comp_words_by_ref -n :` so that the colon isn't treated as a separator. Also, `__ltrim_colon_completions "$cur"` should be called at the end to handle cases where the current word starts with a colon.
#
#Processing the output of `ollama list` is another important part. The script should skip the header line "NAME ID SIZE MODIFIED" and any empty lines. Then, it should extract the model names from the first column. So, when parsing each line from `ollama list`, we split by whitespace and take the first field.
#
#Common pitfalls to avoid include not referencing `COMP_WORDS[1]` as the command name because that's actually the second word. Also, assuming `COMP_WORDS[2]` is "run" could be incorrect since it might be the model being completed. Forgetting `__ltrim_colon_completions` would cause issues after a colon, but the main fix here is about the condition check.
#
#Putting it all together, I need to write the completion script where only the condition line is changed to use `[0]` and `[1]` correctly. The rest of the logic remains as per the original Gemma 27b script structure.
#
#So, in the corrected script, the function starts with checking if `COMP_WORDS[0]` is "ollama" and `COMP_WORDS[1]` is "run`. If not, return early. Then, it proceeds to get model names by running `ollama list`, skipping headers and empty lines, extracting the first column. It handles colons properly and trims them as needed.
#
#I should make sure that the script doesn't have any other changes except for the condition check line. All other parts like colon handling, parsing models from `ollama list` output, etc., remain unchanged.
#...done thinking.

_ollama() {
    local cur prev words cword

    if [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]; then
        return 0
    fi

    _get_comp_words_by_ref -n : cur prev words cword

    local models
    models=$(ollama list 2>/dev/null | sed '1d;/^$/d' | awk '{print $1}')

    COMPREPLY=($(compgen -W "$models" -- "$cur"))
    __ltrim_colon_completions "$cur"
}
complete -F _ollama ollama
