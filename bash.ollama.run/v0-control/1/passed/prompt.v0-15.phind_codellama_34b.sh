# [[HUMAN COMMENTED-OUT]]
# Here's a Bash completion script for the command `ollama run <model>`:

# Check if the current word is `run` and if so, provide available model names as completions
_ollama() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    # For `run` command, suggest model names retrieved from `ollama list` output
    if [ "$prev" == "run" ]; then
        opts=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}') # ignore header line and print only the first column (model name)
        COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
    fi

    return 0
}
complete -F _ollama ollama

# [[HUMAN COMMENTED-OUT]]
# To install this completion script, you can add it to your `.bashrc` or `.bash_profile`:

# [[HUMAN COMMENTED-OUT]]
# Add this line to the end of your .bashrc or .bash_profile
source /path/to/your/_ollama.sh

# [[HUMAN COMMENTED-OUT]]
# Remember to replace `/path/to/your/_ollama.sh` with the actual path where you save the completion script. After sourcing the file, restart your terminal or run `source ~/.bashrc` (or `source ~/.bash_profile`) for the changes to take effect.
# 
# This solution assumes that `ollama` is a command available in your current environment. It also assumes you're using Bash as your shell environment. If not, consider adapting this completion script according to your shell and `ollama` setup.