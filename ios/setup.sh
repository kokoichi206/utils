#!/bin/sh
#
# Description:
#   Setup the initial iOS project.
#   You can setup swiftlint, ci, version manager and gitignore.
#
# Usage:
#   0. move to the project dir
#   1. curl -s https://raw.githubusercontent.com/kokoichi206/utils/main/ios/setup.sh -o setup.sh && bash setup.sh
#
set -eu

# ===== Customize settings =====
# swiftlint when build
NEED_LINT=true
# lint, build and test (at present)
NEED_CI=true
# Versioning example
#   MARKETING_VERSION: 1.1.3
#   CURRENT_PROJECT_VERSION: 10103
NEED_SEMANTIC_VERSIONING=true
# gitignore created by gitignore.io
NEED_GITIGNORE=true
# pull request template
NEED_PR_TEMPLATE=true
# whether remove tmp directory when finished
REMOVE_TMP_DIR=true
# ===== Customize settings =====

# ===== URL =====
## swiftlint
# custom setting
LINT_URL="https://raw.githubusercontent.com/kokoichi206/utils/main/ios/.swiftlint.yml"
# script to setup swiftlint in project.pbxproj, from row 3
SCRIPT_BUILD_PHASE_SECTION_URL="https://raw.githubusercontent.com/kokoichi206/utils/main/ios/script_build_phase_section.txt"
## github-actions
MAIN_CI_URL="https://raw.githubusercontent.com/kokoichi206/utils/main/ios/ci.yml"
## version manager
VERSION_UPDATE_URL="https://raw.githubusercontent.com/kokoichi206/utils/main/ios/version_update.sh"
## gitignore
GITIGNORE_URL="https://raw.githubusercontent.com/kokoichi206/utils/main/ios/.gitignore"
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
    echo "  -l, --lint"
    echo "      skip lint"
    echo "  -c, --ci"
    echo "      skip ci (github actions)"
    echo "  -s, --semantic-versioning"
    echo "      skip semantic-versioning management"
    echo "  -g, --gitignore"
    echo "      skip gitignore"
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
    -l | --lint)
        NEED_LINT=false
        shift 1
        ;;
    -c | --ci)
        NEED_CI=false
        shift 1
        ;;
    -s | --semantic-versioning)
        NEED_SEMANTIC_VERSIONING=false
        shift 1
        ;;
    -g | --gitignore)
        NEED_GITIGNORE=false
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
TMP_DIR="./tmp"
LINT_SETTING="${TMP_DIR}/script_build_phase_section.txt"

TARGET_FILE="$(find . -name project.pbxproj)"

# ===== need this setting to preserve TAB =====
# save the field separator and restore this setting when exit.
old_IFS=$IFS
# new field separator, the end of line
IFS="$'\n'"

# ===== BEGIN: github actions =====
if "${NEED_CI}"; then
    mkdir -p ./.github/workflows
    curl -s "${MAIN_CI_URL}" -o ./.github/workflows/ci.yml
fi
# ===== END: github actions =====

# ===== BEGIN: make temporary directory =====
if [ -e "${TMP_DIR}" ]; then
    echo "${TMP_DIR} already exists."
    echo "Please delete it and run again"
fi
# 0. make tmp directory
mkdir "${TMP_DIR}"
# ===== END: make temporary directory =====

# ===== BEGIN: trap EXIT =====
function recover_from_backup() {
    EXIT_CODE="$?"
    # status code grater than 0 means error
    if [[ "$EXIT_CODE" -gt 0 ]]; then
        # 1. recover project.pbxproj
        mv "${TMP_DIR}/project.pbxproj.bak" "${TARGET_FILE}"

        echo "recovered from backup"
    else
        echo "Exit correctly"
    fi
    # restore default field separator
    IFS=$old_IFS
    # 0. remove tmp directory
    if "${REMOVE_TMP_DIR}"; then
        rm -rf "${TMP_DIR}"
    fi
}
# ERR is special feature to bash
trap recover_from_backup EXIT
# ===== END: trap EXIT =====

# ===== BEGIN: swiftlint in project.pbxproj =====
if "${NEED_LINT}"; then
    # download the necessary files
    curl -s "$LINT_URL" -o .swiftlint.ym
    curl -s "${SCRIPT_BUILD_PHASE_SECTION_URL}" -o "${LINT_SETTING}"

    tmp="${TMP_DIR}/tmp.txt"

    REGISTER_SHELL_AREA_KEY="/* Begin PBXNativeTarget section */"
    SCRIPT_START_KEY="/* End PBXResourcesBuildPhase section */"

    # 1. copy project.pbxproj
    cp "${TARGET_FILE}" "${TMP_DIR}/project.pbxproj.bak"

    is_in_section=false
    while read -r line
    do
        echo "${line}" >> "${tmp}"

        if [[ "${line}" == "${REGISTER_SHELL_AREA_KEY}" ]]; then
            is_in_section=true
        fi
        if "${is_in_section}"; then
            if [[ "$line" =~ ([ ]*)([0-9A-F]{11})[0-9A-F]{5}([0-9A-F]{8})" /* Resources */," ]]; then
                is_in_section=false

                SCRIPT_TAG_NUMBER="${BASH_REMATCH[1]}${BASH_REMATCH[2]}96EA8${BASH_REMATCH[3]}"
                echo "				${SCRIPT_TAG_NUMBER} /* ShellScript */," >> "${tmp}"
            fi
        fi

        if [[ "${line}" == "${SCRIPT_START_KEY}" ]]; then
            if [ -z "${SCRIPT_TAG_NUMBER}" ]; then
                exit 1
            fi
            echo "/* Begin PBXShellScriptBuildPhase section */" >> "${tmp}"
            echo "		${SCRIPT_TAG_NUMBER} /* ShellScript */ = {" >> "${tmp}"
            cat "${LINT_SETTING}" >> "${tmp}"
        fi
    done < "${TARGET_FILE}"
    # CAUTION: override the 'project.pbxproj' file
    mv "${tmp}" "${TARGET_FILE}"
fi
# ===== END: swiftlint in project.pbxproj =====

# ===== BEGIN: semantic versioning =====
if "${NEED_SEMANTIC_VERSIONING}"; then
    mkdir -p ./scripts
    curl -s "${VERSION_UPDATE_URL}" -o ./scripts/version_update.sh
    # set MARKETING_VERSION from 1.0 to 0.0.0
    sed -i -e \
        "s@MARKETING_VERSION = .*;@MARKETING_VERSION = 0.0.0;@g" \
        "${TARGET_FILE}"

    # set CURRENT_PROJECT_VERSION from 1 to 0
    sed -i -e \
        "s@CURRENT_PROJECT_VERSION = .*;@CURRENT_PROJECT_VERSION = 0;@g" \
        "${TARGET_FILE}"
fi
# ===== END: semantic versioning =====

# ===== BEGIN: gitignore =====
if "${NEED_GITIGNORE}"; then
    curl -s "${GITIGNORE_URL}" -o ./.gitignore
fi
# ===== END: gitignore =====

# ===== BEGIN: pull request template =====
if "${NEED_PR_TEMPLATE}"; then
    mkdir -p ./.github
    curl -s "${PR_TEMPLATE_URL}" -o ./.github/pull_request_template.md
fi
# ===== END: pull request template =====
