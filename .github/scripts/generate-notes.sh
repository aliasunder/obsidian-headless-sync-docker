#!/usr/bin/env bash
# Generate structured release notes from conventional commits between two tags.
# Usage: generate-notes.sh <new-tag> [previous-tag]
# If previous-tag is omitted, uses the release tag before new-tag.

set -euo pipefail

NEW_TAG="${1:?Usage: generate-notes.sh <new-tag> [previous-tag]}"
# --match restricts to release tags (vX.Y.Z) so non-release tags can't widen the range.
PREV_TAG="${2:-$(git describe --tags --abbrev=0 --match "v[0-9]*" "$NEW_TAG"^ 2>/dev/null || echo "")}"

if [ -n "$PREV_TAG" ]; then
  RANGE="${PREV_TAG}..${NEW_TAG}"
else
  RANGE="$NEW_TAG"
fi

# Collect commits, skipping the workflow's own "release:" changelog commits and merges.
COMMITS=$(git log --oneline --no-merges "$RANGE" | grep -vE '^[a-f0-9]+ release:' || true)

if [ -z "$COMMITS" ]; then
  echo "No notable changes."
  exit 0
fi

# Use python for reliable parsing — bash regex with nested groups is fragile.
python3 - "$COMMITS" << 'PYTHON'
import sys, re

commits = sys.argv[1]

# Category config: (conventional-commit prefix, heading)
categories = [
    ("feat", "Features"),
    ("fix", "Bug Fixes"),
    ("perf", "Performance"),
    ("refactor", "Refactoring"),
    ("build", "Build System"),
    ("ci", "CI / Infrastructure"),
    ("docs", "Documentation"),
    ("chore", "Maintenance"),
]
cat_map = {c[0]: c[1] for c in categories}
cat_order = [c[0] for c in categories]

buckets = {c[0]: [] for c in categories}
other = []

# Pattern: type(scope): description  OR  type: description
pat = re.compile(r'^([a-z]+)(?:\(([^)]+)\))?:\s+(.+)$')

for line in commits.strip().split('\n'):
    if not line.strip():
        continue
    # Strip the short hash prefix
    msg = line.split(' ', 1)[1] if ' ' in line else line

    m = pat.match(msg)
    if m:
        typ, scope, desc = m.group(1), m.group(2), m.group(3)
        desc = desc[0].upper() + desc[1:]  # capitalize
        if scope:
            entry = f"- **{scope}:** {desc}"
        else:
            entry = f"- {desc}"
        if typ in buckets:
            buckets[typ].append(entry)
        else:
            other.append(entry)
    else:
        msg = msg[0].upper() + msg[1:] if msg else msg
        other.append(f"- {msg}")

# Output
first = True
for typ in cat_order:
    if buckets[typ]:
        if not first:
            print()
        first = False
        print(f"### {cat_map[typ]}")
        print()
        print('\n'.join(buckets[typ]))

if other:
    if not first:
        print()
    print("### Other Changes")
    print()
    print('\n'.join(other))
PYTHON
