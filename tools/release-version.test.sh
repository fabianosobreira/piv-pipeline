#!/usr/bin/env bash
# Tests release-version.sh against throwaway git repositories built from synthetic
# commits and tags. Each case builds its own repository, so no case sees another's.
#
# Usage: release-version.test.sh
# Needs: bash and git. Touches nothing outside a temporary directory.
# Exit: 0 = every case passed, 1 = at least one failed (one line per failure on stderr).

set -eu

here=$(cd "$(dirname "$0")" && pwd)
script=$here/release-version.sh
root=$(mktemp -d)
trap 'rm -rf "$root"' EXIT

# A fixed identity, so the cases run on a machine with no git configuration.
export GIT_AUTHOR_NAME=test GIT_AUTHOR_EMAIL=test@example.com
export GIT_COMMITTER_NAME=test GIT_COMMITTER_EMAIL=test@example.com

failures=0
count=0

# new_repo <name>: an empty repository on main, entered.
new_repo() {
  mkdir "$root/$1"
  cd "$root/$1"
  git init -q -b main
  git config commit.gpgsign false
  git config tag.gpgsign false
  git config core.autocrlf false
}

# commit <subject>: an empty commit with that subject.
commit() {
  git commit -q --allow-empty -m "$1"
}

# skill <name>: a commit adding the folder .claude/skills/<name>.
skill() {
  mkdir -p ".claude/skills/$1"
  echo x > ".claude/skills/$1/SKILL.md"
  git add .claude
  git commit -q -m "feat: add $1"
}

# expect <case> <expected> [<args>...]: runs the script and compares its stdout. The script
# is committed without the executable bit, so it runs through bash, never as a program.
expect() {
  local name=$1 expected=$2 actual
  shift 2
  count=$((count + 1))
  actual=$(bash "$script" "$@" 2>&1) || actual="exit $?: $actual"
  if [ "$actual" != "$expected" ]; then
    echo "FAIL: $name: expected '$expected', got '$actual'" >&2
    failures=$((failures + 1))
  fi
}

# Criterion 1: the level of the commit tags, the highest wins.
new_repo feat-is-minor
commit "chore: start"; git tag v1.2.3
commit "feat: add a thing"
commit "docs: explain it"
expect "feat gives minor" v1.3.0 next

new_repo fix-and-refactor-are-patch
commit "chore: start"; git tag v1.2.3
commit "fix: repair a thing"
commit "refactor: reword a thing"
expect "fix and refactor give patch" v1.2.4 next

new_repo refactor-alone-is-patch
commit "chore: start"; git tag v1.2.3
commit "refactor: reword a thing"
expect "refactor alone gives patch" v1.2.4 next

new_repo no-release-tags
commit "chore: start"; git tag v1.2.3
commit "docs: explain it"
commit "chore: tidy up"
commit "test: cover it"
expect "docs, chore and other tags give no release" none next

new_repo nothing-since-tag
commit "feat: start"; git tag v1.2.3
expect "no commit since the tag gives no release" none next

new_repo highest-wins
commit "chore: start"; git tag v1.2.3
commit "fix: repair a thing"
commit "feat: add a thing"
commit "fix: repair another"
expect "feat with fix gives minor, whatever the order" v1.3.0 next

# Criterion 1: the last tag is the highest semver reachable from the ref.
new_repo highest-semver
commit "chore: start"; git tag v1.9.0
commit "chore: more"; git tag v1.10.0
commit "chore: more"; git tag v1.2.3
commit "fix: repair a thing"
expect "highest semver wins over the newest tag" v1.10.1 next
expect "last-tag prints the highest semver" v1.10.0 last-tag

new_repo unreachable-tag
commit "chore: start"; git tag v1.0.0
git checkout -q -b side
commit "chore: side"; git tag v9.0.0
git checkout -q main
commit "fix: repair a thing"
expect "a tag not reachable from the ref is ignored" v1.0.1 next
expect "last-tag ignores it too" v1.0.0 last-tag

new_repo foreign-tags
commit "chore: start"; git tag v1.0.0
commit "chore: more"; git tag v2.0; git tag release-3.0.0; git tag v3.0.0-rc1; git tag nightly
commit "fix: repair a thing"
expect "tags that are not vX.Y.Z are ignored" v1.0.1 next

# Criterion 2: a subject outside `<tag>: <description>` counts for nothing.
new_repo scoped-subject
commit "chore: start"; git tag v1.2.3
commit "feat(x): y"
expect "a scoped subject gives no release" none next

new_repo breaking-subject
commit "chore: start"; git tag v1.2.3
commit "feat!: y"
expect "a breaking-change marker gives no release" none next

new_repo merge-commit
commit "chore: start"; git tag v1.2.3
git checkout -q -b side
commit "docs: on the side"
git checkout -q main
commit "docs: on main"
git merge -q --no-ff side -m "feat: merge the side"
expect "a merge commit gives no release" none next

new_repo free-text-subject
commit "chore: start"; git tag v1.2.3
commit "Merge pull request #1 from x/y"
commit "feature: not a known tag"
commit "fix:no space"
expect "free text gives no release" none next

# Criterion 3: a skill folder gone since the last tag is a major.
new_repo skill-removed
skill piv-a; skill piv-b
git tag v1.2.3
git rm -q -r .claude/skills/piv-b
git commit -q -m "fix: drop piv-b"
expect "a removed skill folder gives major" v2.0.0 next

new_repo skill-removed-from-subdir
skill piv-a; skill piv-b
git tag v1.2.3
git rm -q -r .claude/skills/piv-b
git commit -q -m "fix: drop piv-b"
mkdir sub
cd sub
expect "a removed skill folder gives major from a subdirectory" v2.0.0 next
cd ..

new_repo skill-renamed
skill piv-a; skill piv-b
git tag v1.2.3
git mv .claude/skills/piv-b .claude/skills/piv-c
git commit -q -m "fix: rename piv-b"
expect "a renamed skill folder gives major" v2.0.0 next

new_repo skill-removed-docs-only
skill piv-a
git tag v1.2.3
git rm -q -r .claude/skills/piv-a
git commit -q -m "docs: drop piv-a"
expect "a removed skill folder gives major even with only docs" v2.0.0 next

new_repo skill-added
skill piv-a
git tag v1.2.3
skill piv-b
expect "an added skill folder is a minor" v1.3.0 next

# Criterion 4: no release tag at all is v1.0.0, whatever the commits.
new_repo no-tag-docs
commit "docs: only docs"
expect "no tag gives v1.0.0 with only docs" v1.0.0 next
expect "last-tag prints nothing without a tag" "" last-tag

new_repo no-tag-feat
commit "feat: add a thing"
commit "fix: repair a thing"
expect "no tag gives v1.0.0 with feat and fix" v1.0.0 next

# A ref other than HEAD.
new_repo explicit-ref
commit "chore: start"; git tag v1.2.3
commit "fix: repair a thing"
commit "feat: add a thing"
expect "a ref bounds the commits counted" v1.2.4 next HEAD~1

# Usage errors exit 2 with a message, never the sentinel.
new_repo usage
commit "chore: start"
expect "no command is a usage error" "exit 2: release-version: wrong arguments. Usage: release-version.sh next|last-tag [<ref>]"
expect "an unknown command is a usage error" "exit 2: release-version: unknown command 'bump'. Usage: release-version.sh next|last-tag [<ref>]" bump
expect "an unknown ref is a usage error" "exit 2: release-version: 'nope' is not a commit here. Fetch it first, or pass another ref." next nope

if [ "$failures" -gt 0 ]; then
  echo "$failures of $count cases failed" >&2
  exit 1
fi
echo "all $count cases passed"
