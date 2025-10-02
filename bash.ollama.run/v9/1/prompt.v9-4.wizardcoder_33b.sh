The following Bash script fulfills your requirements, with comments explaining each step.

```bash
#!/usr/bin/env bash
# This is the simplest form of completion. It matches on words in a static list.
complete -W "option1 option2 option3" example_cmd

# This function handles dynamic completions for `example_cmd`.
_example_cmd_completions() {
  # `cur`: The current word being typed.
  local cur
  # `COMP_WORDS` and `COMP_CWORD` are variables maintained by Bash completion framework to hold the command line arguments and the index of the cursor position (word currently being typed).
  _get_comp_words_by_ref -n : cur
  # `compgen` is a built-in utility in bash that generates possible completions given a partial word.
  COMPREPLY=( $( compgen -W "option1 option2 option3" -- "$cur") )
}

# Register the above function for 'example_cmd' command.
complete -F _example_cmd_completions example_cmd

# This function handles dynamic completions with context awareness for 'app' command.
_app_completions() {
  local cur prev subcommands models
  COMPREPLY=()
  # Retrieve the current and previous words using `get_comp_words_by_ref`.
  _get_comp_words_by_ref -n : cur prev
  
  subcommands="run list pull"
  # If we're typing a subcommand after 'app', offer the subcommands as options.
  if [[ "${#COMP_WORDS[@]}" == "2" ]]; then
    COMPREPLY=( $( compgen -W "$subcommands" -- "$cur") )
  fi
  
  # If we're typing after 'app run', suggest some models.
  if [[ "${#COMP_WORDS[@]}" == "3" && "$prev" == "run" ]]; then
    COMPREPLY=( $( compgen -W "model:small model:large" -- "$cur") )
  fi
}

complete -F _app_completions app

# This function handles advanced completion for 'ollama' command.
_ollama_completions() {
  local cur prev models
  # Save the original word break characters.
  local old_wb=${COMP_WORDBREAKS}
  # Modify COMP_WORDBREAKS to remove the colon.
  COMP_WORDBREAKS=${COMP_WORDBREAKS//:}
  # Use `_get_comp_words_by_ref` to correctly set `cur` and `prev`, with a colon as separator.
  _get_comp_words_by_ref -n : cur prev
  
  if [[ "${#COMP_WORDS[@]}" == "2" && "$prev" == "run" ]]; then
    # Fetch models dynamically by running `ollama list` command and extracting first column.
    local models=$(ollama list | awk 'NR>1 {print $1}')
    COMPREPLY=( $(compgen -W "$models" -- "$cur") )
  fi
  
  # Restore the original word breaks immediately to avoid side-effects.
  COMP_WORDBREAKS=${old_wb}
}

complete -F _ollama_completions ollama
```
To install these completion scripts, add this to your `~/.bashrc`:
```bash
if [ -d ~/.bash_completion.d ]; then
  for c in ~/.bash_completion.d/*; do
    . "$c"
  done
fi
```
Then reload your Bash shell to apply the changes:
```bash
source ~/.bashrc
```
In this script, you can add as many completion scripts as you like to `~/.bash_completion.d` and they will be automatically loaded when a new shell is opened. 

