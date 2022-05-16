#!/bin/sh
#
# Description:
#   Setup the initial Android project.
#   You can setup ci and version setting.
#
# Usage:
#   0. move to the project dir
#   1. curl -s https://raw.githubusercontent.com/kokoichi206/utils/main/android/setup.sh -o setup.sh
#   2. bash setup.sh [OPTIONs]
#
set -eu

# ===== Customize settings =====
NEED_CI=true
# Versioning example
#   versionCode: 10103
#   versionName: 1.1.3
NEED_SEMANTIC_VERSIONING=true
# pull request template
NEED_PR_TEMPLATE=true
# ===== Customize settings =====

# ===== URL =====
## github-actions
MAIN_CI_URL="https://raw.githubusercontent.com/kokoichi206/utils/main/android/ci.yml"
SCHEDULE_CI_URL="https://raw.githubusercontent.com/kokoichi206/utils/main/android/schedule.yml"
## pull request
PR_TEMPLATE_URL="https://raw.githubusercontent.com/kokoichi206/utils/main/.github/pull_request_template.md"
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
    echo "  -s, --semantic-versioning"
    echo "      skip version management"
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
    -s | --semantic-versioning)
        NEED_SEMANTIC_VERSIONING=false
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

# temporary folder
TARGET_FILE="app/build.gradle"
if [ ! -e "${TARGET_FILE}" ]; then
    print_error "You are in the wrong dir."
    echo "Please check your current dir."
    echo ""
    exit 1
fi

# ===== need this setting to preserve TAB =====
# save the field separator and restore this setting when exit.
old_IFS=$IFS
# new field separator, the end of line
IFS="$'\n'"

# ===== BEGIN: github actions =====
if "${NEED_CI}"; then
    mkdir -p ./.github/workflows
    curl -s "${MAIN_CI_URL}" -o ./.github/workflows/ci.yml
    curl -s "${SCHEDULE_CI_URL}" -o ./.github/workflows/schedule.yml
fi
# ===== END: github actions =====

# ===== BEGIN: trap EXIT =====
function tear_down() {
    # restore default field separator
    IFS=$old_IFS
}
# ERR is special feature to bash
trap tear_down EXIT
# ===== END: trap EXIT =====

# ===== BEGIN: semantic versioning =====
if "${NEED_SEMANTIC_VERSIONING}"; then
    tmp=".tmp"
    while read -r line
    do
        if [[ "${line}" == "android {" ]]; then
            echo "def versionMajor = 0" >> "${tmp}"
            echo "def versionMinor = 0" >> "${tmp}"
            echo "def versionPatch = 0" >> "${tmp}"
            echo "" >> "${tmp}"
        fi
        echo "${line}" >> "${tmp}"
    done < "${TARGET_FILE}"
    mv "${tmp}" "${TARGET_FILE}"
    sed -i -e \
        "s@versionName .*@versionName 0.0.0@g" \
        "${TARGET_FILE}"
    sed -i -e \
        "s@versionCode .*@versionCode versionMajor * 10000 + versionMinor * 100 + versionPatch@g" \
        "${TARGET_FILE}"
    if [ -e "${TARGET_FILE}-e" ]; then
        # remove backup file if exists
        rm "${TARGET_FILE}-e"
    fi
fi
# ===== END: semantic versioning =====

# ===== BEGIN: pull request template =====
if "${NEED_PR_TEMPLATE}"; then
    mkdir -p ./.github
    curl -s "${PR_TEMPLATE_URL}" -o ./.github/pull_request_template.md
fi
# ===== END: pull request template =====
