#!/bin/bash
set -e

while [[ "$#" -gt 0 ]]; do
    case $1 in
    -c | --config)
        CONFIG_FILE="$2"
        shift
        ;;

    *)
        echo "Unknown parameter passed: $1"
        exit 1
        ;;
    esac

    shift
done

if [[ -z "${CONFIG_FILE}" ]]; then
    echo "Missing command parameter (-c | --config) and value for deployment toml file"
    exit 1
fi

if [[ ! -e "${CONFIG_FILE}" ]]; then
    echo "Deployment toml file ${CONFIG_FILE} not found"
    exit 1
fi

mise install

poetry install
poetry export --without-hashes >src/requirements.txt

sam build --config-file "${CONFIG_FILE}"
sam deploy --resolve-s3 --config-file "${CONFIG_FILE}"
