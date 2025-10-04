#!/usr/bin/env bash
set -euo pipefail

# Enhanced test script for OpenRouter streaming with custom system prompt support
# Usage: ./openrouter-test.sh [prompt] [model] [system_prompt]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FETCH_SCRIPT="${SCRIPT_DIR}/openrouter-fetch.sh"
PARSE_SCRIPT="${SCRIPT_DIR}/openrouter-parse.sh"

MODEL="${OPENROUTER_MODEL:-${2:-deepseek/deepseek-r1}}"
PROMPT="${1:-"Explain how you would sort a list, then give a concise summary."}"
SYSTEM_PROMPT="${3:-"Respond in plain text."}"

# --- Prerequisite Checks ---

if [[ -z "${OPENROUTER_API_KEY:-}" ]]; then
    echo "Error: OPENROUTER_API_KEY is not set." >&2
    exit 1
fi

if ! command -v jq >/dev/null; then
    echo "Error: This script requires jq." >&2
    exit 1
fi

if [[ ! -x "$FETCH_SCRIPT" ]]; then
    echo "Error: Fetch script not found or not executable: $FETCH_SCRIPT" >&2
    exit 1
fi

if [[ ! -x "$PARSE_SCRIPT" ]]; then
    echo "Error: Parse script not found or not executable: $PARSE_SCRIPT" >&2
    exit 1
fi

# --- Display Info ---

echo "Model: $MODEL"
echo "Prompt: $PROMPT"
echo
echo "(Streaming… reasoning if available, then final)"
echo

# --- Execute ---

"$FETCH_SCRIPT" "$MODEL" "$SYSTEM_PROMPT" "$PROMPT" "true" | "$PARSE_SCRIPT"
