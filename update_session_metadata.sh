#!/bin/bash

# This script will update the session metadata in the contrast_security.yaml file

git_branch=$(git rev-parse --abbrev-ref HEAD)
git_committer_name=$(git log -1 --pretty=format:'%an')
git_commit_hash=$(git rev-parse HEAD)
git_repo_url=$(git config --get remote.origin.url)

# New session_metadata value
new_value="branchName=$git_branch,commitHash=$git_commit_hash,committer=$git_committer_name,repository=$git_repo_url,environment=dev"



yaml_file="contrast_security.yaml"
nested_key="session_metadata"




yaml_file="contrast_security.yaml"
nested_key="session_metadata"


# Use awk to identify the line number containing the nested key and its indentation
awk -v key="$nested_key" '{
  if ($1 == key ":") {
    print NR ":" length($0) - length(ltrim($0))
  }
}
function ltrim(s) { sub(/^[ \t]+/, "", s); return s }' "$yaml_file" | while IFS=: read -r line_number indentation; do
  # Create a temporary file
  temp_file=$(mktemp "${TMPDIR:-/tmp}/tempfile.XXXXXXXXXX") || exit 1

  # Use awk to update the nested key with the new value and save to the temporary file
  awk -v line_number="$line_number" -v indentation="$indentation" -v new_value="$new_value" '
    NR == line_number {
      $0 = sprintf("%*s%s: %s", indentation, "", $1, new_value)
    }
    { print }
  ' "$yaml_file" > "$temp_file"

  # Replace the original file with the temporary file
  mv "$temp_file" "$yaml_file"
done

echo "Nested key '$nested_key' replaced with '$new_value' in '$yaml_file'"
