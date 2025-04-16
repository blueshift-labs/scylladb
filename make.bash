#!/bin/bash

set -uex  # Exit on error, undefined vars, print commands

# Default build mode
BUILD_MODE="${BUILD_MODE:-release}"  # Can be: debug, release, dev

# Detect architecture
get_arch() {
    arch=$(uname -m)

    case "$arch" in
        'x86_64')
            os_arch="x86_64"
            software_arch="amd64"
            ;;
        'aarch64')
            os_arch="aarch64"
            software_arch="arm64"
            ;;
        *)
            echo "***** UNSUPPORTED ARCHITECTURE [$arch] *****"
            exit 1
            ;;
    esac
}

get_arch

# Configure and build using Scylla's dbuild wrapper
./tools/toolchain/dbuild ./configure.py --mode="$BUILD_MODE"
./tools/toolchain/dbuild ninja

echo "Scylla build completed successfully"

# Define the release folder path and tarball name
release_dir="build/${BUILD_MODE}/release"
archive_name="scylla-${software_arch}.tar.gz"

# Check if release folder exists
if [[ -d "$release_dir" ]]; then
    # Create a tarball containing only the 'release' folder
    tar -czf "$archive_name" -C "$(dirname "$release_dir")" "$(basename "$release_dir")"
    echo "$archive_name" > binary_name.txt
    echo "Created tarball: $archive_name"
    echo "Wrote binary path to binary_name.txt"
else
    echo "ERROR: Release directory not found: $release_dir"
    exit 1
fi

