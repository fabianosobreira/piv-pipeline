#!/usr/bin/env bash
# Works out the next release version from the commit tags since the last release tag.
# .github/workflows/release.yml runs it; nothing it prints is written back to the
# repository.
#
# Usage: release-version.sh next [<ref>]       the next version, or "none"
#        release-version.sh last-tag [<ref>]   the last release tag, or nothing
# <ref> defaults to HEAD. Run it from inside the repository, with the tags fetched.
# Needs: bash and git.
#
# The last release tag is the highest `vX.Y.Z` tag reachable from <ref>. Any other
# tag name is ignored. Between that tag and <ref>, the subjects that follow
# `<tag>: <description>` set the bump, and the highest level wins:
#   feat                  -> minor
#   fix, refactor         -> patch
#   any other tag         -> no bump
# A subject outside that format (`feat(x): y`, `feat!: y`) and a merge commit count
# for nothing. A folder of .claude/skills/ that the last tag has and <ref> lacks
# (renamed or removed) bumps the major, whatever the subjects say. With no release
# tag at all, the answer is v1.0.0.
#
# "No release" is signalled by printing `none` on stdout and exiting 0, so a caller
# tells it from a failure by the output, never by the exit code.
# Exit: 0 = answered, 2 = usage or setup error (message on stderr).

set -eu

usage="Usage: release-version.sh next|last-tag [<ref>]"

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
  echo "release-version: wrong arguments. $usage" >&2
  exit 2
fi

mode=$1
ref=${2:-HEAD}

case "$mode" in
  next | last-tag) ;;
  *)
    echo "release-version: unknown command '$mode'. $usage" >&2
    exit 2
    ;;
esac

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "release-version: not inside a git working tree. Run it from the repository." >&2
  exit 2
fi

if ! git rev-parse --verify --quiet "$ref^{commit}" >/dev/null; then
  echo "release-version: '$ref' is not a commit here. Fetch it first, or pass another ref." >&2
  exit 2
fi

# `sort -V` orders v1.10.0 after v1.9.0, which a plain sort would not.
last=$(git tag --merged "$ref" --list 'v*' | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -n 1 || true)

if [ "$mode" = last-tag ]; then
  echo "$last"
  exit 0
fi

if [ -z "$last" ]; then
  echo "v1.0.0"
  exit 0
fi

skill_dirs() {
  git ls-tree --full-tree -d --name-only "$1" -- .claude/skills/
}

level=none

# A folder in the last tag that is gone from <ref>: comm -23 keeps the lines only
# the first list has.
if [ -n "$(comm -23 <(skill_dirs "$last" | sort) <(skill_dirs "$ref" | sort))" ]; then
  level=major
else
  # --no-merges: a merge commit's own subject never counts, only the commits it brought.
  while IFS= read -r subject; do
    if [[ "$subject" =~ ^([a-z]+):\ . ]]; then
      case "${BASH_REMATCH[1]}" in
        feat) level=minor ;;
        fix | refactor) [ "$level" = minor ] || level=patch ;;
      esac
    fi
  done < <(git log --no-merges --format=%s "$last..$ref")
fi

if [ "$level" = none ]; then
  echo none
  exit 0
fi

IFS=. read -r major minor patch <<EOF
${last#v}
EOF

case "$level" in
  major) echo "v$((major + 1)).0.0" ;;
  minor) echo "v$major.$((minor + 1)).0" ;;
  patch) echo "v$major.$minor.$((patch + 1))" ;;
esac
