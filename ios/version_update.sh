#!/bin/bash
#
# Description
#   Update CURRENT_PROJECT_VERSION if needed
#   Force to update versions of ALL packages (main, test, uitest)
#
# Versioning example
#   MARKETING_VERSION: 1.1.3
#   CURRENT_PROJECT_VERSION: 10103
#
# Usage:
#   0. update version of your 'main' project in xcode
#   1. bash scripts/version_update.sh
#
set -eu

# ==================== CONFIG ====================
FILE_NAME="SimpleToDo.xcodeproj/project.pbxproj"

# MAYBE: Get these values from arguments ?
# if you wanna update from 1.2.0 to 2.0.0, set to true
IS_MAJOR_UPDATE=false
# if you wanna update from 1.2.4 to 1.3.0, set to true
IS_MINOR_UPDATE=false
# ==================== ====== ====================

PROGRAM="$(basename "$0")"
NEW_VERSION=""

function print_error() {
    ERROR='\033[1;31m'
    NORMAL='\033[0m'
    echo -e "${ERROR}ERROR${NORMAL}: $1"    
}

# ===== print usage =====
function print_usage() {
    echo "Usage: $PROGRAM [OPTION]"
    echo "  -h, --help, -help"
    echo "      print manual"
    echo "  -v <new_version>, --version <new_version>"
    echo "      update with specific version"
}

function usage_and_exit() {
    print_usage
    exit "$1"
}

# ======================
# parse arguments (options)
# ======================
for i in "$@"; do
    case $i in
    -h | --help | -help)
        usage_and_exit 0
        ;;
    -v | --version)
        if [[ -z "$2" ]]; then
            print_error "option requires a new version for $1 option"
            echo ""
            usage_and_exit 1
        fi
        echo "$2"
        if [[ "$2" =~ ^([0-9]+\.[0-9]+\.[0-9]+)$ ]]; then
            NEW_VERSION="$2"
        else
            print_error "new version format should be \d\.\d\.\d for $1 option"
            echo ""
            usage_and_exit 1
        fi
        
        shift 2
        ;;
    -*)
        echo "Unknown option $1"
        usage_and_exit 1
        ;;
    esac
done

BACKUP_FILE_NAME="${FILE_NAME}.${PROGRAM}.backup"
# make a backup just in case
cp "${FILE_NAME}" "${BACKUP_FILE_NAME}"

function recover_from_backup() {
    EXIT_CODE="$?"
    if [[ "$EXIT_CODE" -gt 0 ]]; then
        echo "Something went wrong."
        rm "${FILE_NAME}"
        mv "${BACKUP_FILE_NAME}" "${FILE_NAME}"
        echo "recovered from backup"
    else
        rm "${BACKUP_FILE_NAME}"
    fi
    # sed in mac creates a default backup file??
    BACKUP_FILE_BY_MAC="${FILE_NAME}-e"
    if [[ -f "${BACKUP_FILE_BY_MAC}" ]]; then
        rm "${BACKUP_FILE_BY_MAC}"
    fi
}
# "trap recover_from_backup ERR" not working on my mac ??
# ERR is special feature to bash
trap recover_from_backup EXIT

# e.g) CURRENT_VERSION: 1.0.1
CURRENT_VERSION="$(cat "${FILE_NAME}" | grep MARKETING_VERSION | head -n1 | sed -E 's@.*= (.*);@\1@')"

if [[ "${IS_MAJOR_UPDATE}" == "true" ]]; then
    NEXT_VERSION="$(echo "${CURRENT_VERSION}" | awk -F'.' -v OFS='.' '{print ($1+1), 0, 0}' )"
elif [[ "${IS_MINOR_UPDATE}" == "true" ]]; then
    NEXT_VERSION="$(echo "${CURRENT_VERSION}" | awk -F'.' -v OFS='.' '{print $1, ($2+1), 0}' )"
else
    NEXT_VERSION="$(echo "${CURRENT_VERSION}" | awk -F'.' -v OFS='.' '{print $1, $2, ($3+1)}' )"
fi

if [ -z "${NEW_VERSION}" ]; then
    NEW_VERSION="${NEXT_VERSION}"
fi
echo "NEW version: $NEW_VERSION"

sed -i -e \
    "s@MARKETING_VERSION = .*;@MARKETING_VERSION = "${NEW_VERSION}";@g" \
    "${FILE_NAME}"

# e.g) CURRENT_PROJECT_VERSION: 10001 <- 1*10000 + 0*100 + 1
CURRENT_PROJECT_VERSION="$(echo "${NEW_VERSION}" | awk -F'.' '{print $1*10000 + $2*100 + $3}')"
sed -i -e \
    "s@CURRENT_PROJECT_VERSION = .*;@CURRENT_PROJECT_VERSION = "${CURRENT_PROJECT_VERSION}";@g" \
    "${FILE_NAME}"
