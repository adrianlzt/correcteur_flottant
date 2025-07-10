#!/bin/bash

set -e # Exit immediately if a command exits with a non-zero status.

CHANGELOG_FILE="CHANGELOG.md"

# Check if llm tool is available
if ! command -v llm &> /dev/null
then
    echo "'llm' command could not be found. Please install it to continue."
    exit 1
fi

# 1. Ensure the changelog file exists
touch "$CHANGELOG_FILE"

# 2. Get the latest tag from the git repository
LATEST_REPO_TAG=$(git describe --tags --abbrev=0)
if [ -z "$LATEST_REPO_TAG" ]; then
    echo "Error: No git tags found in the repository."
    exit 1
fi

# 3. Get the latest tag already processed in CHANGELOG.md
# We look for markdown headers like ## [v1.0.0]
LATEST_CHANGELOG_TAG=$(grep -m 1 -oP '\[\K(v[0-9.]+)(?=\])' "$CHANGELOG_FILE" || echo "")

# 4. If the latest repo tag is already in the changelog, we're done.
if [ "$LATEST_REPO_TAG" == "$LATEST_CHANGELOG_TAG" ]; then
    echo "Changelog is already up to date with the latest tag ($LATEST_REPO_TAG)."
    exit 0
fi

# 5. Determine the commit range for the git log
if [ -z "$LATEST_CHANGELOG_TAG" ]; then
    echo "No previous version found in CHANGELOG.md. Generating for tag $LATEST_REPO_TAG."
    COMMIT_RANGE="$LATEST_REPO_TAG"
else
    echo "Updating changelog from $LATEST_CHANGELOG_TAG to $LATEST_REPO_TAG."
    COMMIT_RANGE="$LATEST_CHANGELOG_TAG..$LATEST_REPO_TAG"
fi

# 6. Check if there are any commits in the range to process
if ! git rev-list "$COMMIT_RANGE" | grep -q . ; then
    echo "No new commits found in range $COMMIT_RANGE. Nothing to do."
    exit 0
fi

# 7. Define the prompt for the LLM
PROMPT="You are an expert technical writer. Based on the following git commits, generate a changelog entry in Markdown for version $LATEST_REPO_TAG.

The output must be a single Markdown section for the new version.
- The main heading must be '## [$LATEST_REPO_TAG] - $(date +%Y-%m-%d)'.
- Group changes under '### Added', '### Changed', '### Fixed', etc.
- Rephrase commit messages to be user-friendly and concise.
- Do not add any preamble, conclusion, or other text outside the generated Markdown section."

# 8. Generate the new changelog section and store in a temporary file
echo "Generating changelog content for $COMMIT_RANGE..."
NEW_CONTENT_FILE=$(mktemp)
git log --pretty=format:"- %s" "$COMMIT_RANGE" | llm -s "$PROMPT" > "$NEW_CONTENT_FILE"

# 9. Prepend the new content to the existing changelog
TEMP_CHANGELOG_FILE=$(mktemp)
cat "$NEW_CONTENT_FILE" > "$TEMP_CHANGELOG_FILE"
# Add a newline for spacing if the original changelog is not empty
if [ -s "$CHANGELOG_FILE" ]; then
    echo "" >> "$TEMP_CHANGELOG_FILE"
fi
cat "$CHANGELOG_FILE" >> "$TEMP_CHANGELOG_FILE"

# 10. Replace the old changelog with the new one
mv "$TEMP_CHANGELOG_FILE" "$CHANGELOG_FILE"

# 11. Clean up temporary file
rm "$NEW_CONTENT_FILE"

echo "CHANGELOG.md has been updated successfully for version $LATEST_REPO_TAG."
