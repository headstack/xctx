#!/usr/bin/env bash
# Regenerates README.md.
#
# Output = a hand-authored header (title, badges, install, usage, versioning)
# wrapped around the package documentation that `goreadme` extracts straight
# from the Go source (doc comments, function signatures, the runnable
# Example* functions used as the "Usage" snippet).
#
# Every value below (module path, repo, license label, CI workflow file) is
# read from the repo itself - nothing here is hardcoded, so this keeps
# working unchanged if the module is renamed, moved, or re-licensed.
set -euo pipefail

# Runs against the current working directory's package (same convention as
# the plain `goreadme` call it replaces), but badges are repo-wide metadata,
# so those are looked up from the module root regardless of which package
# directory this script was invoked from.
MODULE_ROOT="$(dirname "$(go env GOMOD)")"

DOC_FILE="${DOC_FILE:-README.md}"
DOC_CMD="${DOC_CMD:-goreadme -types -constants -factories -functions -methods -variabless -credit=false}"

MODULE_PATH="$(go list -m)"
PKG_IMPORT_PATH="$(go list .)"
PKG_NAME="$(basename "$PKG_IMPORT_PATH")"

REPO=""
case "$MODULE_PATH" in
  github.com/*) REPO="${MODULE_PATH#github.com/}" ;;
esac

WORKFLOW_FILE=""
if [ -d "$MODULE_ROOT/.github/workflows" ]; then
  WORKFLOW_FILE="$(grep -lm1 -E '^name: *CI *$' "$MODULE_ROOT"/.github/workflows/*.yml "$MODULE_ROOT"/.github/workflows/*.yaml 2>/dev/null | head -n1 || true)"
  [ -n "$WORKFLOW_FILE" ] && WORKFLOW_FILE="$(basename "$WORKFLOW_FILE")"
fi

LICENSE_LABEL=""
if [ -f "$MODULE_ROOT/LICENSE" ]; then
  LICENSE_LABEL="$(head -n1 "$MODULE_ROOT/LICENSE" | sed -E 's/ License$//')"
fi

raw="$(mktemp)"
trap 'rm -f "$raw"' EXIT
$DOC_CMD > "$raw"

TITLE="$(head -n1 "$raw")"
DESCRIPTION="$(awk 'NR==1{next} /^## /{exit} {print}' "$raw" | awk '!started && /^[[:space:]]*$/{next} {started=1; print}')"
USAGE_BODY="$(awk '/^## Examples/{f=1; next} /^## /{f=0} f' "$raw")"
REST="$(awk '
  /^## /{started=1}
  started && /^## Examples/{skip=1; next}
  started && /^## /{skip=0}
  started && !skip
' "$raw")"

{
  echo "$TITLE"
  echo

  if [ -n "$REPO" ] && [ -n "$WORKFLOW_FILE" ]; then
    echo "[![CI](https://github.com/$REPO/actions/workflows/$WORKFLOW_FILE/badge.svg)](https://github.com/$REPO/actions/workflows/$WORKFLOW_FILE)"
  fi
  echo "[![Go Reference](https://pkg.go.dev/badge/$PKG_IMPORT_PATH.svg)](https://pkg.go.dev/$PKG_IMPORT_PATH)"
  if [ -n "$LICENSE_LABEL" ]; then
    badge_label="$(printf '%s' "$LICENSE_LABEL" | sed -E 's/[ -]/_/g')"
    echo "[![License: $LICENSE_LABEL](https://img.shields.io/badge/License-${badge_label}-blue.svg)](LICENSE)"
  fi
  echo

  if [ -n "$DESCRIPTION" ]; then
    echo "$DESCRIPTION"
    echo
  fi

  echo "## Install"
  echo
  echo '```bash'
  echo "go get $PKG_IMPORT_PATH"
  echo '```'
  echo

  if [ -n "$USAGE_BODY" ]; then
    echo "Pin a specific released version instead of the latest commit on \`main\`:"
    echo
    echo '```bash'
    echo "go get $PKG_IMPORT_PATH@v0.1.0"
    echo '```'
    echo
    echo "## Usage"
    echo "$USAGE_BODY"
    echo
  fi

  echo "## Versioning"
  echo
  echo "This module follows [Semantic Versioning](https://semver.org/) via Git tags of the form"
  echo "\`vMAJOR.MINOR.PATCH\` (e.g. \`v0.1.0\`), which is how the Go module system resolves versions -"
  echo "there's no separate release/publish step beyond pushing the tag."
  echo
  echo "To cut a new release:"
  echo
  echo '```bash'
  echo "git tag -a v0.1.0 -m \"v0.1.0\""
  echo "git push origin v0.1.0"
  echo '```'
  echo
  echo "Consumers can then depend on that exact version with \`go get $PKG_IMPORT_PATH@v0.1.0\`,"
  echo "or pick up the newest tagged release with \`go get $PKG_IMPORT_PATH@latest\`."
  echo "\`go get $PKG_IMPORT_PATH\` (no version suffix) also resolves to the latest tagged version"
  echo "when the module is already a dependency - Go only tracks \`main\` for a module that hasn't been tagged yet."
  echo
  echo "> Note: a \`v2.0.0+\` (breaking-change) release requires the module path itself to gain a \`/v2\`"
  echo "> suffix (\`$MODULE_PATH/v2\`) per Go's"
  echo "> [semantic import versioning](https://go.dev/ref/mod#major-version-suffixes) rules. \`v0\`/\`v1\` need no suffix."
  echo

  if [ -n "$REST" ]; then
    echo "$REST"
  fi
} > "$DOC_FILE"

echo "Wrote $DOC_FILE for $PKG_NAME ($MODULE_PATH)"
