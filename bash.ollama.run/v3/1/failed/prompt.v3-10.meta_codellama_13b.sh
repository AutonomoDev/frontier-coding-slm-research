_ollama_run() {
    # 1. Triggering: activate only when completing `run <model>` after typing `ollama`
    [[ ${COMP_WORDS[0]} = ollama ]] || return
    [[ ${COMP_WORDS[1]} = run ]] || return

    # 2. Model list retrieval: capture output of `ollama list` into a variable
    local models=($(ollama list))

    # 3. Prefix filtering: use current word as prefix and include only model names that start with it
    for model in "${models[@]}"; do
        if [[ $model == "$COMP_WORDS[2]"* ]]; then
            COMPREPLY+=($model)
        fi
    done

    # 4. Sorting: sort filtered models alphabetically before assigning to `COMPREPLY`
    IFS=$'\n' COMPREPLY=($(sort <<<"${COMPREPLY[*]}"))

    # 5. Populate COMPREPLY correctly: either build `COMPREPLY` manually from filtered & sorted results or use `compgen -W ... -- "$cur"` on a prepared, alphabetically sorted list
    local models_sorted=$(printf '%s\n' "${models[@]}" | sort)
    if [[ $? -eq 0 ]]; then
        COMPREPLY=($(compgen -W "${models_sorted[*]}" -- "$cur"))
    fi
}

# Wiring: attach the function to `ollama` so that typing `ollama run <Tab>` triggers it
complete -F _ollama_run ollama

