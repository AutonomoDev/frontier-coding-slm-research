# Thinking...
# Okay, so I'm trying to help improve this bash completion script for the 'ollama run' command. From what I understand, there's been some issues with handling model names that have colons in them, like 'codellama:13b'. The previous versions of the prompt had some problems, especially with how the completions are displayed after a colon.
# 
# Let me go through the analysis and strategy again to make sure I get this right. Version 9 handled the parsing part by modifying COMP_WORDBREAKS and using _get_comp_words_by_ref with -n :, which got the pass rate up. But it didn't handle how the suggestions are displayed, so the perfect results were zero because of that oversight.
# 
# Then in version 14, they added __ltrim_colon_completions to fix the display issue, which boosted the perfect completions. However, this version introduced more complexity and some bugs, leading to failures like no suggestions or completing with files instead of models. The critical bugs section might have confused the AI, causing it to overcorrect.
# 
# So for v17, the plan is to merge the strengths of both versions but simplify the structure. Instead of listing all the things to avoid, they want a clear, unified solution that addresses both parsing and display issues with colons. They also want a straightforward code skeleton so the AI doesn't get lost in complex logic.
# 
# Looking at the proposed v17 prompt, it seems well-structured. It starts by explaining the core challenge, then breaks down the mandatory two-part colon fix into clear steps. The implementation requirements are laid out logically, from script structure to output format, with a strict checklist for verification.
# 
# I think the key points here are emphasizing early exit to prevent interference with other commands and making sure both parts of the colon fix (parsing and display) are clearly integrated. By providing a code skeleton with comments, it should guide the AI better without overwhelming it with too many constraints.
# 
# I wonder if there's anything else that could be simplified or made clearer. Maybe adding more context about why each step is necessary would help, but since the prompt needs to be concise, perhaps the current level of detail is sufficient.
# 
# Overall, this approach should balance clarity and completeness, reducing the chances of errors while maintaining the essential functionality needed for proper bash completions with model names containing colons.
# ...done thinking.

# [[HUMAN COMMENTED-OUT]]
# To address the challenges in creating a robust Bash completion script for the `ollama run` command, especially handling model names with colons, we've developed an improved prompt (v17). This version synthesizes the strengths of previous iterations while simplifying the structure to enhance clarity and effectiveness.

# [[HUMAN COMMENTED-OUT]]
# ### Approach
# 1. **Core Challenge Identification**: Recognize that colons in model names disrupt parsing and display.
# 2. **Two-Part Colon Fix**:
#    - **Parsing**: Modify `COMP_WORDBREAKS` to handle colons correctly during input parsing.
#    - **Display**: Use `__ltrim_colon_completions` to ensure suggestions are displayed properly after a colon is typed.
# 3. **Script Structure**: Provide a clear, step-by-step code structure with inline comments for guidance.
# 4. **Early Exit Mechanism**: Ensure the script exits immediately if not handling the 'run' subcommand to prevent interference.
# 5. **Verification Checklist**: Include a strict checklist to ensure all critical steps are implemented correctly.

# [[HUMAN COMMENTED-OUT]]
# ### Solution Code

_ollama_completions() {
    # Check if the command is 'ollama run'; exit early if not
    local cur prev
    if [[ ${COMP_WORDS[1]} != "run" ]]; then
        return 0
    fi

    # Save original COMP_WORDBREAKS and remove colon from it
    local ORIGINAL_COMP_WORDBREAKS=$COMP_WORDBREAKS
    COMP_WORDBREAKS=${COMP_WORDBREAKS/":"/}
    
    # Get the current word (cur) and previous word (prev), treating colon as part of the word
    _get_comp_words_by_ref -n : cur prev
    
    # Restore original COMP_WORDBREAKS immediately after use
    COMP_WORDBREAKS=$ORIGINAL_COMP_WORDBREAKS

    # Check if 'ollama' command exists
    if ! command -v ollama &>/dev/null; then
        COMPREPLY=()
        return 0
    fi

    # Fetch and parse the list of models, extracting only the first column (model names)
    local models=$(ollama list | awk 'NR>1 {print $1}')

    # Generate completion suggestions for the current word
    COMPREPLY=($(compgen -W "$models" -- "$cur"))

    # Ensure completions are displayed correctly after a colon
    __ltrim_colon_completions "$cur"
}

# Register the completion function for 'ollama' command
complete -F _ollama_completions ollama

# [[HUMAN COMMENTED-OUT]]
# ### Explanation
# - **Early Exit**: The script immediately exits if it's not handling the 'run' subcommand, preventing interference with other commands.
# - **Colon Handling**: Modifies `COMP_WORDBREAKS` to include colons, ensuring proper parsing of model names. After processing, it restores the original settings to avoid side effects.
# - **Model List Fetching**: Uses `ollama list` and `awk` to extract model names, ensuring only relevant data is processed.
# - **Completion Generation**: Uses `compgen` with the fetched models to generate suggestions for the current word (`$cur`).
# - **Display Fix**: Calls `__ltrim_colon_completions` to ensure suggestions are displayed correctly after a colon.
# 
# This approach ensures that the Bash completion script handles model names with colons effectively, providing accurate and user-friendly completions.
