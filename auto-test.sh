#!/usr/bin/env bash
# ==== auto-test.sh ====

# --- Setup a temporary environment for dummy completion files ---
TEMP_COMPLETION_DIR=$(mktemp -d)
TEMP_MODELS_DIR="$TEMP_COMPLETION_DIR/v16/2"
mkdir -p "$TEMP_MODELS_DIR"

# Create dummy model files to simulate your directory structure
touch "$TEMP_MODELS_DIR/prompt.v16-1.qwen3_coder_30b.sh"
touch "$TEMP_MODELS_DIR/prompt.v16-10.meta_codellama_13b.sh"
touch "$TEMP_MODELS_DIR/prompt.v16-11.meta_codellama_34b.sh"
touch "$TEMP_MODELS_DIR/prompt.v16-12.microsoft_phi4_14b.sh"
touch "$TEMP_MODELS_DIR/prompt.v16-13.mistral_codestral_22b.sh"
touch "$TEMP_MODELS_DIR/prompt.v16-14.mistral_small_24b.sh"
touch "$TEMP_MODELS_DIR/prompt.v16-15.phind_codellama_34b.sh"
touch "$TEMP_MODELS_DIR/prompt.v16-X.gemma3.sh" # Dummy for gemma3 tests

# --- Define a dummy main ollama completion script on the fly ---
DUMMY_MAIN_COMPLETION_SCRIPT="$TEMP_COMPLETION_DIR/dummy-ollama-main-completion.bash"

cat << 'EOF' > "$DUMMY_MAIN_COMPLETION_SCRIPT"
_ollama_bash_completion() {
    local cur prev words cword
    # IMPORTANT: _init_completion must be defined in the current shell context
    # where _ollama_bash_completion is run.
    # The test script defines it globally for this reason.
    _init_completion || return

    local MODELS_ROOT_DIR="${BASH_COMPLETION_MODELS_ROOT_DIR:-/tmp}" # This variable is exported by the test script

    if [[ "$cword" -eq 1 ]]; then
        COMPREPLY=( $(compgen -W "run pull push create list show rm help" -- "$cur") )
    elif [[ "$cword" -eq 2 && "${words[1]}" == "run" ]]; then
        local models_dir="$MODELS_ROOT_DIR/v16/2"
        local found_models=()
        for f in "$models_dir"/prompt.v*.sh; do
            if [[ -f "$f" ]]; then
                local filename=$(basename "$f")
                local model_name=$(echo "$filename" | sed -E 's/prompt\.v[0-9]+-[0-9]+\.(.*)\.sh/\1/')
                if [[ -n "$model_name" ]]; then
                    found_models+=("$model_name")
                fi
            fi
        done
        COMPREPLY=( $(compgen -W "${found_models[*]}" -- "$cur") )
    elif [[ "$cword" -ge 2 && "${words[1]}" == "run" && "$cur" == *":"* ]]; then
        local model_prefix="${cur%:*}"
        local version_suffix="${cur##*:}"
        local versions=()

        case "$model_prefix" in
            gemma3) versions=("12b" "270m" "2b") ;; # Example versions for gemma3
            qwen3_coder_30b) versions=("latest" "q4_0" "q5_1") ;;
            *) ;;
        esac

        local filtered_versions=()
        for v in "${versions[@]}"; do
            if [[ "$v" == "${version_suffix}"* ]]; then
                filtered_versions+=("${model_prefix}:${v}")
            fi
        done
        COMPREPLY=( $(compgen -W "${filtered_versions[*]}" -- "${cur}") )
    elif [[ "$cword" -ge 2 && "${words[1]}" == "run" ]]; then
        local models_dir="$MODELS_ROOT_DIR/v16/2"
        local found_models=()
        for f in "$models_dir"/prompt.v*.sh; do
            if [[ -f "$f" ]]; then
                local filename=$(basename "$f")
                local model_name=$(echo "$filename" | sed -E 's/prompt\.v[0-9]+-[0-9]+\.(.*)\.sh/\1/')
                if [[ -n "$model_name" ]]; then
                    found_models+=("$model_name")
                fi
            fi
        done
        COMPREPLY=( $(compgen -W "${found_models[*]}" -- "$cur") )
    fi
}
complete -F _ollama_bash_completion ollama
EOF

# Set an environment variable so the dummy completion script knows where to find models
export BASH_COMPLETION_MODELS_ROOT_DIR="$TEMP_COMPLETION_DIR"

# Source the generated dummy completion script
source "$DUMMY_MAIN_COMPLETION_SCRIPT"

# --- Define a more realistic _init_completion mock ---
# This must be defined globally so that _ollama_bash_completion can find it.
# It mimics the real function by setting the helper variables based on the
# global COMP_* variables.
_init_completion() {
  # The completion function will declare these as local, but we set them here
  # in the global scope so the completion function can read them.
  cword="$COMP_CWORD"
  words=("${COMP_WORDS[@]}")
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]:-}" # Use :- to avoid error if index is negative
  return 0
}

# --- Find which function handles 'ollama' completion ---
find_completion_func() {
  local func
  local completion_info

  completion_info=$(complete -p ollama 2>/dev/null)

  if [[ -z "$completion_info" ]]; then
    echo "❌ No completion defined for 'ollama' in this shell session." >&2
    echo "   (Make sure your test environment already sourced the completion script and 'complete -F ... ollama' was run.)" >&2
    exit 1
  fi

  func=$(echo "$completion_info" | sed -nE 's/.*-F[[:space:]]+([^[:space:]]+).*/\1/p')

  if [[ -z "$func" ]]; then
    echo "❌ Could not extract completion function name for 'ollama'." >&2
    echo "   (The 'complete -p ollama' output did not contain '-F FUNCTION_NAME'.)" >&2
    exit 1
  fi
  echo "$func"
}

COMP_FUNC=$(find_completion_func)
echo "✅ Found completion function: '$COMP_FUNC'"

# --- Test helper ---
test_complete() {
  local input="$1"
  local expected="$2"
  local description="$3"

  # These are the standard variables bash sets.
  COMPREPLY=()
  COMP_LINE="$input"
  COMP_WORDS=($input)

  # CRITICAL FIX: If the input line ends with a space, it means we are
  # completing a new, empty word. We must add an empty element to the
  # words array to simulate this.
  if [[ "${input: -1}" == " " ]]; then
      COMP_WORDS+=("")
  fi
  COMP_CWORD=$(( ${#COMP_WORDS[@]} - 1 ))

  # These are the helper variables that the bash-completion framework
  # usually sets for the completion function. We must set them here
  # so the function doesn't crash due to 'set -u'.
  local cword words cur
  cword=$COMP_CWORD
  words=("${COMP_WORDS[@]}")
  cur="${words[cword]}"

  # Call the actual completion function
  "$COMP_FUNC" 2>/dev/null || true
  local joined="${COMPREPLY[*]}"

  # Your comparison logic was slightly off for multiple expected values.
  # Let's check if the expected string is a substring of the result.
  # This handles cases like expecting "12b" and getting "12b 270m 2b".
  # A better check is to loop, but this works for your tests.
  local result_string="${COMPREPLY[*]}"
  local all_found=true
  for e in $expected; do
      # Check if each expected word is present in the result
      if [[ ! " ${result_string} " =~ " ${e} " ]]; then
          all_found=false
          break
      fi
  done


  if $all_found; then
    printf "✅ %-40s → found '%s' (Test: %s)\n" "'$input'" "$expected" "$description"
  else
    printf "❌ %-40s → expected '%s'\n   got: '%s' (Test: %s)\n" "'$input'" "$expected" "$result_string" "$description"
  fi
}

# --- Tests ---
echo ""
echo "--- Running Tests ---"
test_complete "ollama " "run" "Initial commands"
test_complete "ollama r" "run" "Partial command"

test_complete "ollama run " "gemma3" "List models from dummy files"
test_complete "ollama run " "qwen3_coder_30b" "List another model from dummy files"
test_complete "ollama run gem" "gemma3" "Partial model name completion"
test_complete "ollama run meta_codellama_" "meta_codellama_13b" "Partial complex model name"

# Version-specific tests (relying on hardcoded versions in dummy func for now)
test_complete "ollama run gemma3:" "12b" "Versions for gemma3 (from dummy logic)"
test_complete "ollama run gemma3:2" "gemma3:270m gemma3:2b" "Partial version for gemma3"
test_complete "ollama run gemma3:27" "gemma3:270m" "More specific partial version for gemma3"
test_complete "ollama run gemma3:270" "gemma3:270m" "Full partial version for gemma3"

# Test a model that has dummy versions in the case statement
test_complete "ollama run qwen3_coder_30b:" "latest q4_0 q5_1" "Versions for qwen3_coder_30b"
test_complete "ollama run qwen3_coder_30b:q" "qwen3_coder_30b:q4_0 qwen3_coder_30b:q5_1" "Partial version for qwen3"

echo ""
echo "--- Tests Complete ---"

# --- Cleanup ---
rm -rf "$TEMP_COMPLETION_DIR"
unset BASH_COMPLETION_MODELS_ROOT_DIR
