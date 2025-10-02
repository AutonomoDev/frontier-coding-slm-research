# This is a Bash completion script for the `ollama run` command, which provides autocompletion suggestions for model names when the user presses `<TAB>`. The script must handle model names containing colons and provide unique suggestions.
# To activate this completion, source this script in your current shell: `source ./ollama_run_completion.sh`

_ollama_run_completion() {
    # Get the index of the 'run' subcommand
    local run_index=$(compgen -c "ollama" | awk '/run/ {print NR-1}')

    # Check if the current word is immediately after 'run'
    [[ $COMP_CWORD != "$run_index" ]] && return

    # Get the available local models from `ollama list` output
    local wordlist=$(ollama list | awk 'NR>1 {print $1}' | awk '!seen[$0]++')

    # Temporarily remove colon from COMP_WORDBREAKS to handle colons in model names
    local old_wb=$COMP_WORDBREAKS
    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}

    # Use compgen to filter matches based on the current word being typed
    local cur="${COMP_WORDS[$COMP_CWORD]}"
    COMPREPLY=( $(compgen -W "$wordlist" -- "$cur") )

    # Restore colon from COMP_WORDBREAKS and exit
    COMP_WORDBREAKS=$old_wb
    return 0
}
complete -F _ollama_run_completion ollama
# This script provides autocompletion suggestions for model names when the user presses `<TAB>` after typing `ollama run`. The script handles model names containing colons and provides unique suggestions. To activate this completion, source this script in your current shell: `source ./ollama_run_completion.sh`

