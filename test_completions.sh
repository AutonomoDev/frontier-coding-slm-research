#!/bin/bash

# Ensure a path argument is provided
if [ -z "$1" ]; then
    echo "Error: No path provided." >&2
    exit 1
fi

# Attempt to cd into it, or exit on failure
cd "$1" || { echo "Error: Cannot change directory to '$1'." >&2; exit 1; }

# Get scripts sorted by the numeric part after vXX-
sorted_scripts=$(find . -maxdepth 1 -name 'prompt.*.sh' -printf '%f\n' |
          sed 's/prompt\.v\([0-9]*\)-\([0-9]*\)\..*/\1 \2 &/' |
          sort -k1,1n -k2,2n |
          cut -d' ' -f3-)
for script in $sorted_scripts; do
    clear

    echo "==== Testing $script ===="

    # Create a temporary rc file to load the completion in the subshell
    temp_rc=$(mktemp /tmp/test_completion.XXXXXX)
    echo "source '$(pwd)/$script'" > "$temp_rc"

    echo
    echo "Dropping into subshell with completion loaded."
    echo "Try: ollama [TAB][TAB]"
    echo "Exit the subshell (with 'exit' or Ctrl-D) when done testing."

    bash --rcfile "$temp_rc" -i

    rm "$temp_rc"

    # Ask for grade and comments
    echo
    echo "Grade the test (pass/fail): "
    read grade
    echo "Comments: "
    read -r comments

    if [[ "$grade" = "pass" ]] || [[ "$grade" = "p" ]]; then
        mkdir -p "passed"
        echo "$script PASSED: $comments" >> test.log
        mv -v "$script" "passed/$script"
    else
        mkdir -p "failed"
        echo "$script FAILED: $comments" >> test.log
        mv -v "$script" "failed/$script"
    fi
#done < <(find . -maxdepth 1 -name 'prompt.*.sh' -printf '%f\n' | sort -t- -k1.8,1.9n -k2n)
done

echo "✔️ All done!"
# It can't progress if two or more models have the same initial characters.
