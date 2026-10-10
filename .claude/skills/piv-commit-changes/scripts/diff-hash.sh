#!/usr/bin/env sh
# Prints one hash for the change under review: the full diff from <base> to the
# working tree, untracked files included, every <exclude-glob> left out.
# piv-review-changes records it as the review report's Diff; piv-commit-changes
# recomputes it to tell whether the tree still matches. Both copies of this
# script must stay identical, or the two hashes never match.
#
# Usage: diff-hash.sh <base> [<exclude-glob>...]
# Needs: git and a POSIX shell. Changes nothing in the repository.

set -eu

# Exit 2 marks a usage or setup error the caller can fix; any other non-zero
# exit comes from git itself and carries git's own message.

if [ "$#" -lt 1 ]; then
  echo "diff-hash: missing <base>. Usage: diff-hash.sh <base> [<exclude-glob>...]" >&2
  exit 2
fi

base=$1
shift

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "diff-hash: not inside a git working tree. Run it from the repository root." >&2
  exit 2
fi

if ! base_commit=$(git rev-parse --verify --quiet "$base^{commit}"); then
  echo "diff-hash: '$base' is not a commit here. Pass the base commit's hash, or fetch it first." >&2
  exit 2
fi

cd "$(git rev-parse --show-toplevel)"

# A throwaway index, so untracked files can be staged for the diff without
# touching the user's own index. Removed on every exit path.
tmp_index=$(mktemp)
tmp_diff=$(mktemp)
trap 'rm -f "$tmp_index" "$tmp_diff"' EXIT INT TERM
cp "$(git rev-parse --git-path index)" "$tmp_index" 2>/dev/null || rm -f "$tmp_index"

# Each exclude glob becomes a pathspec; "." keeps the include side explicit,
# since git rejects a pathspec list made only of exclusions.
count=$#
for glob in "$@"; do
  set -- "$@" ":(exclude,glob)$glob"
done
shift "$count"
set -- . "$@"

# Stage everything, untracked files included; ignored files stay out on their
# own, and the exclusions apply at the diff below.
GIT_INDEX_FILE=$tmp_index git -c core.safecrlf=false add -A -- .

# Every option that config could change is pinned, so two machines and two
# sessions print the same hash for the same change. The diff goes through a
# file, not a pipe, so a failing git diff stops the script instead of hashing
# partial output.
GIT_INDEX_FILE=$tmp_index git -c core.quotepath=on -c diff.noprefix=false \
  diff --cached --binary --full-index --no-renames --no-color --no-ext-diff \
  --no-textconv --src-prefix=a/ --dst-prefix=b/ "$base_commit" -- "$@" >"$tmp_diff"
git hash-object --no-filters "$tmp_diff"
