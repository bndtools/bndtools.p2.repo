#!/bin/bash

# Script to create virtual repositories in JFrog Artifactory
# Each virtual repository points to a specific P2 repository version

set -e

# Check required environment variables
if [ -z "$JFROG_USER" ]; then
    echo "Error: JFROG_USER environment variable is not set"
    exit 1
fi

if [ -z "$JFROG_TOKEN" ]; then
    echo "Error: JFROG__TOKEN environment variable is not set"
    exit 1
fi

if [ -z "$JFROG_SERVER" ]; then
    echo "Error: JFROG_SERVER environment variable is not set"
    exit 1
fi

# Remove trailing slash from server URL if present
JFROG_SERVER="${JFROG_SERVER%/}"

# BND versions to create virtual repositories for
#BND_VERSIONS=("6.4.0" "6.4.1" "7.2.0" "7.2.1")
BND_VERSIONS=("6.4.1")

# Local repository containing the P2 artifacts
LOCAL_REPO="libs-release-local"

# Function to create P2 virtual repository
create_virtual_repo() {
    local bnd_version=$1
    local repo_key="rel-${bnd_version}"
    local path_suffix="org/bndtools/org.bndtools.p2/${bnd_version}/org.bndtools.p2-${bnd_version}.jar!"
    local p2_url="${JFROG_SERVER}/artifactory/${LOCAL_REPO}/${path_suffix}"
    
    echo "Creating P2 virtual repository: ${repo_key}"
    
    # Create JSON payload for P2 repository
    local json_payload=$(cat <<EOF
{
  "key" : "${repo_key}",
  "packageType" : "p2",
  "description" : "bndtools p2 release ${bnd_version}",
  "rclass" : "virtual"
}
EOF
)
    
    # Create the repository using Artifactory REST API
    response=$(curl -s -w "\n%{http_code}" \
        -u "${JFROG_USER}:${JFROG__TOKEN}" \
        -H "Content-Type: application/json" \
        -X PUT \
        -d "${json_payload}" \
        "${JFROG_SERVER}/artifactory/api/repositories/${repo_key}")
    
    # Extract HTTP status code (last line)
    http_code=$(echo "$response" | tail -n1)
    # Extract response body (all but last line)
    body=$(echo "$response" | sed '$d')
    
    if [ "$http_code" -eq 200 ] || [ "$http_code" -eq 201 ]; then
        echo "✓ Successfully created virtual repository: ${repo_key}"
    else
        echo "✗ Failed to create virtual repository: ${repo_key}"
        echo "  HTTP Status: ${http_code}"
        echo "  Response: ${body}"
        return 1
    fi
}

# Main execution
echo "Starting virtual repository creation..."
echo "Server: ${JFROG_SERVER}"
echo "User: ${JFROG_USER}"
echo ""

failed=0
for version in "${BND_VERSIONS[@]}"; do
    if ! create_virtual_repo "$version"; then
        failed=$((failed + 1))
    fi
    echo ""
done

echo "============================================"
if [ $failed -eq 0 ]; then
    echo "All virtual repositories created successfully!"
else
    echo "Failed to create ${failed} virtual repository(ies)"
    exit 1
fi
