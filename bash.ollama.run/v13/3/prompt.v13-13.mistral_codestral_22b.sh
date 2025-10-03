_ollama_run() {
    local cur prev words cword split
    _init_completion || return

    if [[ "${COMP_WORDS[0]}" != "ollama" || "${COMP_WORDS[1]}" != "run" ]]; then
      return
    fi

    _get_comp_words_by_ref -n : cword split

    local models=()
    while IFS=' ' read -r name; do
      [[ $name == "#"* || -z "$name" ]] && continue
      models+=("$name")
    done < <(ollama list | sed 1d)

    __ltrim_colon_completions "$cur"
    COMPREPLY=( $(compgen -W "${models[*]}" -- "$cur") )
  }
  complete -F _ollama_run ollama
