# This is a comment. The following line is code:
_ollama_list() {
  COMPREPLY=($(ollama list 2>/dev/null | awk 'NR > 1 && $0 !~ /^[[:space:]]*$/ {print $1}' | sed 's/:.*//' | sed "s/'/\'\\\\'\'/g" | sed "s/^/'/" | sed "s/$/'/"))
}

# This is a comment. The following line is code:
_ollama() {
  local cur prev opts

  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"

  case "${prev}" in
    run)
      _ollama_list
      ;;
    *)
      COMPREPLY=()
      ;;
  esac

  # Filter out options that start with the same string as $cur, and append them to COMPREPLY.
  COMPREPLY=( $(compgen -W "${COMPREPLY[*]}" -- "$cur") )
}
complete -F _ollama ollama

# [[HUMAN COMMENTED-OUT]]
#Please make sure you source this script in your bash environment before testing the autocompletion. This can be done by sourcing the file like so: `source <path-to-the-script>`. Once that is done, try typing `ollama run ` and press `<TAB>` to see the magic happen.
#
#The `_ollama_list` function fetches the list of available models from the ollama command by filtering the output of `ollama list`, extracting the first column (model names) after skipping the header line, and removing parts that are not relevant (hashes, sizes, modification dates). The filtered names are then provided as completion suggestions.
#
#The `_ollama` function is a wrapper around this functionality. It's triggered only for the `ollama` command, specifically for the second word in a command line (`run` subcommand in our case).
#
#The `complete -F _ollama ollama` command registers the completion function `_ollama` with the bash shell for the `ollama` command.
#
#This script should be placed in your user's home directory and sourced from your .bashrc file to be loaded at each new shell session. You may also need to add a line to source your .bashrc file after placing this script there, like so: `source ~/.bashrc`.

