# [[HUMAN COMMENTED-OUT]]
# [SYS]{"page": "bash completion function"}

# # Bash Completion Function for `ollama run <model>`

# This is a bash completion function that dynamically lists available models by parsing the output of `ollama list` without using any external dependencies.

# ## Usage

# To use this script, you can source it in your `.bashrc` or `.bash_profile` file:
source /path/to/ollama-run-completion.sh
# [[HUMAN COMMENTED-OUT]]
# Or you can install it by running the following command:
curl -s https://raw.githubusercontent.com/username/repo/main/ollama-run-completion.sh | sudo bash
# [[HUMAN COMMENTED-OUT]]
# ## Explanation
# [[HUMAN COMMENTED-OUT]]
# This script uses the `compgen` and `readarray` built-in Bash functions to generate completions for the `ollama run` command. The `compgen` function generates a list of all available models, while the `readarray` function is used to parse the output of `ollama list` and extract the model names.
# [[HUMAN COMMENTED-OUT]]
# The script first runs `ollama list` with no formatting flags to get a list of all available models in plain text format. Then it uses `readarray` to read this output into an array, and iterates over each element in the array to generate a completion for each model name. Finally, it uses the `compgen` function to generate the completions and return them as a Bash array.
# [[HUMAN COMMENTED-OUT]]
# ## Installation
# [[HUMAN COMMENTED-OUT]]
# To install this script, simply run the following command:
curl -s https://raw.githubusercontent.com/username/repo/main/ollama-run-completion.sh | sudo bash
# [[HUMAN COMMENTED-OUT]]
# This will download the script and make it available as a Bash completion function for the `ollama run` command. You can then source this script in your `.bashrc` or `.bash_profile` file to use it:
source /path/to/ollama-run-completion.sh
# [[HUMAN COMMENTED-OUT]]
# ## Notes
# [[HUMAN COMMENTED-OUT]]
# This script assumes that you have the `ollama` command installed and available on your system, along with its dependencies. If you do not have these dependencies installed, this script will not work correctly.
# [[HUMAN COMMENTED-OUT]]
# Additionally, this script is designed to be used in Bash version 4 or later. If you are using an older version of Bash, you may need to modify the script to make it compatible.
# [[HUMAN COMMENTED-OUT]]
# That's all there is to it! This script should dynamically list available models for the `ollama run` command without any external dependencies.
