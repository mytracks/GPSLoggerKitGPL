#!/bin/zsh
# Publishes a version of this Swift package: checks, tests, Git tag and GitHub release
# (spec release-publishing in mytracks/gpsloader, "GitHub-Release der Pakete").
#
# Usage:
#   Scripts/release.sh <version> [--dry-run]
#
#   <version>   semantic version without prefix, e.g. 0.1.0; release notes in docs/releases/<version>.md
#   --dry-run   run all checks and tests, then print the tag and release commands instead of running them
#
# Versions below 1.0.0 are published as pre-releases. A published tag is never moved.
# iOS tests run when Package.swift declares iOS; the simulator is IOS_DESTINATION
# (default: platform=iOS Simulator,OS=27.1,name=iPhone Duo).
set -euo pipefail

VERSION="${1:-}"
DRY_RUN=0
[[ "${2:-}" == "--dry-run" ]] && DRY_RUN=1
[[ "${VERSION}" =~ '^[0-9]+\.[0-9]+\.[0-9]+$' ]] || { echo "usage: Scripts/release.sh <version> [--dry-run]" >&2; exit 2; }

ROOT="${0:A:h:h}"
cd "${ROOT}"
PACKAGE=$(sed -n 's/^ *name: "\([^"]*\)",.*/\1/p' Package.swift | head -1)
NOTES="docs/releases/${VERSION}.md"
IOS_DESTINATION="${IOS_DESTINATION:-platform=iOS Simulator,OS=27.1,name=iPhone Duo}"

step() { print -P "%F{cyan}==> $1%f"; }
fail() { print -P "%F{red}release: $1%f" >&2; exit 1; }
run() {
    if (( DRY_RUN )); then print -r -- "would run: ${(q)@}"; else "$@"; fi
}

# --- Checks before the tests -------------------------------------------------------------------------------

step "Checking ${PACKAGE} ${VERSION}"
[[ -f "${NOTES}" ]] || fail "missing release notes ${NOTES}"
[[ -z "$(git status --porcelain)" ]] || fail "uncommitted changes; commit and push first"
git rev-parse -q --verify "refs/tags/${VERSION}" >/dev/null && fail "tag ${VERSION} exists already"

if git remote get-url origin >/dev/null 2>&1; then
    git fetch --quiet origin
    branch=$(git rev-parse --abbrev-ref HEAD)
    git merge-base --is-ancestor HEAD "origin/${branch}" 2>/dev/null \
        || fail "HEAD $(git rev-parse --short HEAD) is not pushed to origin/${branch}"
    [[ -z "$(git ls-remote --tags origin "refs/tags/${VERSION}")" ]] || fail "tag ${VERSION} exists on origin"
    gh auth status >/dev/null 2>&1 || fail "gh is not signed in"
    gh release view "${VERSION}" >/dev/null 2>&1 && fail "a GitHub release ${VERSION} exists already"
    echo "ok: $(git rev-parse --short HEAD) is on origin, no tag or release ${VERSION} yet"
elif (( DRY_RUN )); then
    echo "note: no remote 'origin' yet; remote checks skipped in the dry run"
else
    fail "no remote 'origin'"
fi

# --- Tests ------------------------------------------------------------------------------------------------

step "Running tests (macOS)"
swift test

if grep -q '\.iOS(' Package.swift; then
    step "Running tests (${IOS_DESTINATION})"
    # Serial: under parallel load the simulator misses the one-second limit of the cancellation tests.
    xcodebuild test -scheme "${PACKAGE}" -destination "${IOS_DESTINATION}" -parallel-testing-enabled NO -quiet
fi

# --- Tag and release --------------------------------------------------------------------------------------

PRERELEASE=()
[[ "${VERSION}" == 0.* ]] && PRERELEASE=(--prerelease)

step "Tagging and publishing ${VERSION}"
run git tag -a "${VERSION}" -m "${PACKAGE} ${VERSION}"
run git push origin "${VERSION}"
run gh release create "${VERSION}" --verify-tag --title "${PACKAGE} ${VERSION}" --notes-file "${NOTES}" "${PRERELEASE[@]}"

echo
if (( DRY_RUN )); then echo "Dry run: nothing was tagged or published."; else echo "Published ${PACKAGE} ${VERSION}."; fi
