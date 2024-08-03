#!/bin/bash
set -e

# check cloudformation template
poetry run cfn-lint template.yaml

# linter checks
poetry run ruff format .
poetry run ruff check .
