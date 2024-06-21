#!/bin/bash

# File containing the list of URLs
tag_list=".tags.list"

# Directory to store the downloaded files
download_dir=".download"

# Base directory to store the extracted files
base_dir="site"
base_url="https://bndtools.jfrog.io/artifactory/update-latest/org/bndtools/org.bndtools.p2/"

# Create the directories if they don't exist
mkdir -p "$download_dir"
mkdir -p "$base_dir"

# Read the file line by line
while IFS= read -r tag; do
 
    version=${tag/.REL/}
    # Extract the file name from the URL
    filename=org.bndtools.p2-${version}.jar

    # Create a subfolder for the version
    version_dir="$base_dir/$version"

    # Check if the version folder already exists
    if [ -d "$version_dir" ]; then
        echo "Version $version already exists, skipping download."
    else
        # Download the file into the download directory
        curl -o "$download_dir/$filename" "$base_url/$version/$filename"

        # Create the version directory
        mkdir -p "$version_dir"

        # Extract the JAR file into the version directory
        unzip "$download_dir/$filename" -d "$version_dir"
    fi
done < "$tag_list"


# Create the index.html file
index_file="$base_dir/index.html"
echo "<html><body><h1>Release Directories</h1><ul>" > "$index_file"

# List each version directory and its size
for dir in "$base_dir"/*/; do
    version=$(basename "$dir")
    size=$(du -sh "$dir" | cut -f1)
    echo "<li><a href="$version">$version</a> - $size</li>" >> "$index_file"
done

echo "</ul></body></html>" >> "$index_file"

echo "Download and extraction complete. Index file created at $index_file."