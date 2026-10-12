#!/usr/bin/env bash
# Tests the "Deploy the site" step of .github/workflows/release.yml against a local
# bare remote and a stub `gh`. The step's script is read out of the workflow file, so
# the test runs the code the workflow runs.
#
# Usage: release-deploy.test.sh
# Needs: bash and git. Touches nothing outside a temporary directory.
# Exit: 0 = every case passed, 1 = at least one failed (one line per failure on stderr).

set -eu

workflow=$(cd "$(dirname "$0")/.." && pwd)/.github/workflows/release.yml
root=$(mktemp -d)
trap 'rm -rf "$root"' EXIT

export GIT_AUTHOR_NAME=test GIT_AUTHOR_EMAIL=test@example.com
export GIT_COMMITTER_NAME=test GIT_COMMITTER_EMAIL=test@example.com

failures=0
count=0

# The step's `run:` block, dedented, with the tag expression replaced by v1.0.0.
awk '
  /^      - name: Deploy the site$/ { in_step = 1; next }
  in_step && /^        run: \|$/ { in_run = 1; next }
  in_run && /^          / { sub(/^          /, ""); print; next }
  in_run { exit }
' "$workflow" | sed 's/\${{[^}]*}}/v1.0.0/' > "$root/step.sh"

if [ ! -s "$root/step.sh" ]; then
  echo "FAIL: could not read the Deploy the site step out of $workflow" >&2
  exit 1
fi

# A `gh` that only records its arguments.
mkdir "$root/bin"
printf '#!/bin/sh\necho "$@" >> "%s/gh.log"\n' "$root" > "$root/bin/gh"
chmod +x "$root/bin/gh"

# run_step <name> <expected deploy: yes|no|fail>: runs the step the way Actions does
# (`bash -e`) in the current directory, then compares what it did with what is expected.
run_step() {
  local name=$1 expected=$2 rc=0 actual
  count=$((count + 1))
  rm -f "$root/gh.log"
  PATH="$root/bin:$PATH" bash -e "$root/step.sh" > "$root/out.log" 2>&1 || rc=$?
  if [ "$rc" -ne 0 ]; then
    actual=fail
  elif grep -q 'workflow run pages.yml --ref releases' "$root/gh.log" 2>/dev/null; then
    actual=yes
  else
    actual=no
  fi
  if [ "$actual" != "$expected" ]; then
    echo "FAIL: $name: expected '$expected', got '$actual'" >&2
    sed 's/^/  | /' "$root/out.log" >&2
    failures=$((failures + 1))
  fi
}

# new_remote <name>: a bare remote holding one commit on main, and a clone of it, entered.
new_remote() {
  git init -q --bare -b main "$root/$1.git"
  git clone -q "$root/$1.git" "$root/$1" 2>/dev/null
  cd "$root/$1"
  git config commit.gpgsign false
  git checkout -q -b main
  git commit -q --allow-empty -m "feat: start"
  git push -q origin main
}

# A release just pushed: the clone was made before the tag existed, as in the workflow.
new_remote fresh-release
git push -q --atomic origin HEAD:refs/heads/releases HEAD:refs/tags/v1.0.0
run_step "a tag pushed by this run starts the deploy" yes

# A rerun: the checkout already carries the tag and releases sits on it.
new_remote rerun
git push -q --atomic origin HEAD:refs/heads/releases HEAD:refs/tags/v1.0.0
git fetch -q origin "refs/tags/v1.0.0:refs/tags/v1.0.0"
run_step "a tag already local starts the deploy" yes

# releases sits on another commit than the tag: no deploy, and no error.
new_remote releases-elsewhere
git push -q origin HEAD:refs/heads/releases
git commit -q --allow-empty -m "feat: second"
git push -q origin main
git push -q origin HEAD:refs/tags/v1.0.0
run_step "releases not on the tag starts no deploy" no

# The tag exists nowhere: the step fails instead of reporting "releases is not on the tag".
new_remote tag-missing
git push -q origin HEAD:refs/heads/releases
run_step "a tag missing from the remote fails the step" fail

if [ "$failures" -gt 0 ]; then
  echo "$failures of $count cases failed" >&2
  exit 1
fi
echo "all $count cases passed"
