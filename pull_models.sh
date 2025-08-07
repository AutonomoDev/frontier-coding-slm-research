#!/bin/sh

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <MODELS LIST>"
    exit 1
fi

DIRECTORY="$1"
                                                                                                                                                                                                                                                        #!/bin/sh
for MODEL in $(cat "$1" | awk '{print $1}'); do
    echo $MODEL;
    time ollama pull $MODEL;
done

