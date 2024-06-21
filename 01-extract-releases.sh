#!/bin/bash

# GitHub repository
repo="bndtools/bnd"

# GitHub API URL for releases
api_url="https://api.github.com/repos/$repo/releases"

# Fetch the release information from GitHub API
response=$(curl -s "$api_url")

# Extract tag names ending with .rel
#cat response.json | jq .[].tag_name | grep -E '[0-9]+\.[0-9]+\.[0-9]+'
#cat response.json | jq -r '.[] | select(.tag_name | test("\\.REL$")) | .tag_name'
tags=$(echo "$response" | jq -r '.[] | .tag_name' | grep -E '^[0-9]+\.[0-9]+\.[0-9]+(\.REL)?$')

echo "$tags"
echo "$tags" > .tags.list

echo "finished parsing!"
