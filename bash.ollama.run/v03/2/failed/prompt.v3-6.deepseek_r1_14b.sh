# Thinking...
# Alright, I need to create a bash completion function for the command `ollama run <model>`. The user has specified several requirements that must be met.
#
# First, the function should only activate when the user is completing the model argument after typing `ollama run`. So, I'll check if the previous word is `run` and the command is `ollama`.
#
# Next, I need to retrieve the list of models by running `ollama list` once. The output should be captured in a variable without using pipes directly because that creates subshells. Instead, I'll store the output in a variable and then process it.
#
# Then, I have to filter the model names based on the current word being completed. This means checking if each model name starts with the prefix provided by `COMP_CURRENT_WORD`.
#
# After filtering, the models should be sorted alphabetically. I'll use `sort` for this step to ensure they are in order.
#
# I need to build `COMPREPLY` correctly. Using `compgen -W` with a sorted list and including the current word will handle the suggestions properly.
#
# If `ollama list` fails or returns no models, the function should gracefully fail without providing any completions. I'll check for an empty model list and return if that's the case.
#
# The script shouldn't have any external dependencies, so I'll rely on Bash built-ins. If `_get_comp_words_by_ref` isn't available, I'll fallback to manually setting `cur` and `prev`.
#
# Finally, I need to wire this function to activate when typing `ollama run`. This involves defining the function and ensuring it's called at the right time.
#
# For installation, the user will save the script in a directory like `/etc/bash_completion.d/`, source it, and then reload their shell configuration.
# ...done thinking.

# Bash completion for ollama run <model>
ollama_run_completions() {
    # Get current word and previous word
    _get_comp_words_by_ref "$COMP_WORDS" cur prev || {
        cur=${COMP_WORDS[COMP_CWORD]}
        prev=${COMP_WORDS[COMP_CWORD-1]}
    }

    # Check if command is ollama and previous word is run
    if [[ "$prev" == "run" && "$COMP_WORDS[0]" == "ollama" ]]; then
        # Get list of models
        models=$(ollama list 2>/dev/null)
        if [ -z "$models" ]; then
            return
        fi
### 安装示例

# 将上述脚本保存为 `_ollama_run_completion`，然后将其放置在 `/etc/bash_completion.d/` 目录下（需要权限），或者将其添加到你的 `.bashrc` 文件中：

# ```bash
# # 如果 _ollama_run_completion 存在，则自动补全
# if [ -f /etc/bash_completion.d/_ollama_run_completion ]; then
#     source /etc/bash_completion.d/_ollama_run_completion
# elif [ -f ~/.bashrc ]; then
#     echo "source /path/to/_ollama_run_completion" >> ~/.bashrc
#     source ~/.bashrc
# fi
# ```

# 请将 `"/path/to/_ollama_run_completion"` 替换为脚本的实际路径。

        # Filter models starting with current word
        completions=$(echo "$models" | tr -s '\n' | grep "^$cur")

        # Sort completions alphabetically
        sorted_completions=$(echo "$completions" | sort)

        # Generate completion suggestions
        COMPREPLY=( $(compgen -W "$sorted_completions" -- "$cur") )
    fi
}

# Install: Save this file as /etc/bash_completion.d/ollama-run-completion or source it from .bashrc
# Then: ollama run <Tab> to see completions
