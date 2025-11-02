Here is a bash-completion script for `ollama run <model>` that satisfies all requirements:

```bash
# Bash completion function
_ollama() 
{
    local cur prev words cword split
    _init_completion -s || return
    
    # This function is only invoked when the command is 'ollama run' and 
    # user is completing after 'run'.
    [[ ${words[1]} != "run" ]] && return

    # Get all available models by calling 'ollama list' once and storing the output.
    local models=$(ollama list 2>/dev/null) || return
    
    # Prefix filtering: Use current word to filter model names so only those matching 
    # the prefix are suggested. Populate COMPREPLY using 'compgen' with '-W'.
    COMPREPLY=( $( compgen -W "$models" -- $cur ) )
    
    # Graceful failure: If ollama list fails, no completions will be offered 
    # without breaking the shell.
} && complete -F _ollama ollama

# Installation instructions
echo "To activate this bash completion script immediately, add the following line to your .bashrc:"
echo "source /path/to/your_script"
```
Save this script somewhere (e.g., `~/.ollama-completion.sh`), then source it in `.bashrc`: 

```bash
echo 'source ~/.ollama-completion.sh' >> ~/.bashrc
```
Remember to replace `/path/to/your_script` with the actual path where you saved this script. Finally, start a new shell session or source your `.bashrc` file: 

```bash
source ~/.bashrc
```
This should make bash auto-completion for `ollama run <model>` behave as described above. 

