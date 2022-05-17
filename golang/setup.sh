#!/bin/sh
#
# Description:
#   Setup the initial Go project.
#   You can setup ci and version setting.
#
# Usage:
#   0. move to the project dir
#   1. curl -s https://raw.githubusercontent.com/kokoichi206/utils/main/golang/setup.sh -o setup.sh
#   2. bash setup.sh [OPTIONs]
#
set -eu

# ===== Customize settings =====
NEED_CI=true
# pull request template
NEED_PR_TEMPLATE=true
# editorconfig
NEED_EDITOR_CONFIG=true
# Makefile
NEED_MAKEFILE=true
# gitignore
NEED_GITIGNORE=true
# ===== Customize settings =====

# ===== URL =====
## github-actions
MAIN_CI_URL="https://raw.githubusercontent.com/kokoichi206/utils/main/golang/ci.yml"
## pull request
PR_TEMPLATE_URL="https://raw.githubusercontent.com/kokoichi206/utils/main/.github/pull_request_template.md"
## editorconfig
EDITOR_CONFIG_URL="https://raw.githubusercontent.com/kokoichi206/utils/main/golang/.editorconfig"
## Makefile
MAKEFILE_URL="https://raw.githubusercontent.com/kokoichi206/utils/main/golang/Makefile"
## Makefile
GITIGNORE_URL="https://raw.githubusercontent.com/kokoichi206/utils/main/golang/.gitignore"
# ===== URL =====

# ===== BEGIN: define print error, usage =====
PROGRAM=$(basename "$0")
function print_error() {
    ERROR='\033[1;31m'
    NORMAL='\033[0m'
    echo -e "${ERROR}ERROR${NORMAL}: $1"
}
function print_usage() {
    echo "Usage: bash ${PROGRAM} [OPTION]"
    echo "  -h, --help, -help"
    echo "      print manual"
    echo "  -c, --ci"
    echo "      skip ci (github actions)"
    echo "  -e, --editorconfig"
    echo "      skip editorconfig"
    echo "  -m, --makefile"
    echo "      skip Makefile"
}
usage_and_exit()
{
    print_usage
    exit "$1"
}
# ===== END: define print error, usage =====

# ===== BEGIN: parse arguments (options) =====
for i in "$@"; do
    case $i in
    -h | --help | -help)
        usage_and_exit 0
        ;;
    -c | --ci)
        NEED_CI=false
        shift 1
        ;;
    -e | --editorconfig)
        NEED_EDITOR_CONFIG=false
        shift 1
        ;;
    -m | --makefile)
        NEED_MAKEFILE=false
        shift 1
        ;;
    -*)
        echo ""
        print_error "Unknown option $1"
        echo ""
        usage_and_exit 1
        ;;
    esac
done
# ===== END: parse arguments (options) =====

# ===== BEGIN: github actions =====
if "${NEED_CI}"; then
    mkdir -p ./.github/workflows
    curl -s "${MAIN_CI_URL}" -o ./.github/workflows/ci.yml
fi
# ===== END: github actions =====

# ===== BEGIN: pull request template =====
if "${NEED_PR_TEMPLATE}"; then
    mkdir -p ./.github
    curl -s "${PR_TEMPLATE_URL}" -o ./.github/pull_request_template.md
fi
# ===== END: pull request templat =====

# ===== BEGIN: editorconfig =====
if "${NEED_EDITOR_CONFIG}"; then
    curl -s "${EDITOR_CONFIG_URL}" -o ./.editorconfig
fi
# ===== END: editorconfig =====

# ===== BEGIN: Makefile =====
if "${NEED_MAKEFILE}"; then
    curl -s "${MAKEFILE_URL}" -o ./Makefile
fi
# ===== END: Makefile =====

# ===== BEGIN: gitignore =====
if "${NEED_GITIGNORE}"; then
    curl -s "${GITIGNORE_URL}" -o ./.gitignore
fi
# ===== END: gitignore =====
