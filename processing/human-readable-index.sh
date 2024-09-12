#!/bin/bash

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Path to the provided XSLT file
XSLT_PATH="$SCRIPT_PATH/content2html.xsl" # Replace with the actual path to the content2html.xsl file

# Ensure xsltproc is installed
if ! command -v xsltproc &> /dev/null
then
    echo "xsltproc could not be found. Please install it (e.g., via apt, yum, or brew)."
    exit 1
fi

# Function to extract the archive and check for content.xml
process_archive() {
    local archive="$1"
    local dir=$(dirname "$archive")

    echo "Processing archive: $archive"

    # Extract the archive in its current directory
    if [[ "$archive" == *.jar ]]; then
        unzip -o "$archive" -d "$dir"
    elif [[ "$archive" == *.xz ]]; then
        tar -xf "$archive" -C "$dir"
    fi

    # Check if content.xml exists in the extracted folder
    if [[ -f "$dir/content.xml" ]]; then
        echo "Found content.xml in $dir. Performing XSLT transformation..."
        xsltproc "$XSLT_PATH" "$dir/content.xml" -o "$dir/index.html"
        echo "Transformation complete. index.html created in $dir."
    else
        echo "content.xml not found in $dir."
    fi
}

# Recursively find all content.jar and content.xz files
find . -type f \( -name "content.jar" -o -name "content.xz" \) | while read -r archive; do
    process_archive "$archive"
done
