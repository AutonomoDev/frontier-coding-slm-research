# Thinking...
# Okay, I need to generate a Bash completion script for the `ollama` command. Let me break down what's required.
# 
# First, the script must be a single function called `_ollama_completions`. It should handle different commands with various completion behaviors.
# 
# The commands are grouped into three categories:
# 
# 1. Commands that require model name completions: show, run, stop, push, cp, rm.
# 2. The `create` command which has specific flags to complete: --file, -f, --quantize, -q.
# 3. Commands with no argument completion: serve, pull, signin, signout, list, ps, help.
# 
# The main structure should use a case statement based on the subcommand. If the previous word is `ollama`, it should list all possible subcommands as completions.
# 
# For model name completion, there's a specific process:
# 
# - Extract current and previous words using `_get_comp_words_by_ref`.
# - Check if `ollama` command exists; if not, return empty.
# - Fetch models by running `ollama list`, extract the first column starting from line 2.
# - If no models are found, return empty.
# - Generate completions with `compgen` and sort them before trimming.
# 
# I need to ensure that the model names are handled as a string, not an array. Also, avoid sorting before `compgen`.
# 
# For the `create` command, complete specific flags if it's the current word or the previous word is `create`. The flags are `--file`, `-f`, `--quantize`, `-q`.
# 
# I should structure the function with a case statement for each subcommand. Each case will handle the appropriate completion logic.
# 
# Finally, register the completion function with `complete -F _ollama_completions ollama` at the end.
# 
# Putting it all together, I'll write the function step by step, making sure each part adheres to the constraints and requirements.
# ...done thinking.

_ollama_completions() {
    local cur prev words cword
    _get_comp_words_by_ref -n : words cword cur prev

    # Handle top-level command completion
    if [[ $prev == ollama ]]; then
        COMPREPLY=($(compgen -W "show run stop push cp rm create serve pull signin signout list ps help" -- "$cur"))
        return 0
    fi

    case "$prev" in
        show|run|stop|push|cp|rm)
            # Step A: Extract word info
            local cur prev
            _get_comp_words_by_ref -n : cur prev
            
            # Step B: Fetch models
            if ! command -v ollama &>/dev/null; then COMPREPLY=(); return; fi
            local models
            models=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
            [[ -z "$models" ]] && { COMPREPLY=(); return; }
            
            # Step C: Generate completions
            COMPREPLY=($(compgen -W "$models" -- "$cur"))
            
            # Step D: Sort and trim
            COMPREPLY=($(printf "%s\n" "${COMPREPLY[@]}" | sort))
            __ltrim_colon_completions "$cur"
            ;;
        create)
            if [[ "$cur" == -* ]]; then
                COMPREPLY=($(compgen -W "--file -f --quantize -q" -- "$cur"))
            else
                # No completions for other arguments of create
                return 1
            fi
            ;;
    esac
}

complete -F _ollama_completions ollama
