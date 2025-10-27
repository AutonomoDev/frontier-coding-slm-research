#! /usr/bin/env bash

# 定义完整的补全函数
function _ollama_completions {
    local cur prev words cword ollama_list

    # 获取当前命令和前一个命令
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    # 检查命令是否为 "ollama run"
    if [[ "${prev}" != "run" ]]; then
        return
    fi

    # 保存原始的 COMP_WORDBREAKS
    local original_comp_wordbreaks="$COMP_WORDBREAKS"

    # 临时移除冒号从 COMP_WORDBREAKS
    COMP_WORDBREAKS="${COMP_WORDBREAKS//:/}"

    # 重新解析命令行单词
    _get_comp_words_by_ref -n : cur prev

    # 恢复原始的 COMP_WORDBREAKS
    COMP_WORDBREAKS="$original_comp_wordbreaks"

    # 检查 ollama 命令是否可用
    if ! command -v ollama &>/dev/null; then
        return
    fi

    # 获取模型列表
    ollama_list=$(ollama list | awk 'NR>1 {print $1}')

    # 生成补全建议
    COMPREPLY=( $(compgen -W "$ollama_list" -- "$cur") )

    # 调用 __ltrim_colon_completions 确保显示正确
    __ltrim_colon_completions "$cur"
}

# 注册补全函数
complete -F _ollama_completions ollama

# [[HUMAN COMMENTED-OUT]]
# This Bash script provides a robust solution for handling the `ollama run` command's completion in a way that correctly manages the presence of colons and ensures that suggestions are displayed accurately. The script adheres to the outlined requirements, including immediate context checks, proper handling of COMP_WORDBREAKS, and careful management of completions after a colon is typed.