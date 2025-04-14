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

# Define original and renamed binary paths
original_binary="build/${BUILD_MODE}/scylla"
renamed_binary="build/${BUILD_MODE}/scylla-${software_arch}"

# Check that the binary exists
if [[ -f "$original_binary" ]]; then
    mv "$original_binary" "$renamed_binary"
    echo "$renamed_binary" > binary_name.txt
    echo "Binary renamed to: $renamed_binary"
    echo "Wrote binary path to binary_name.txt"
else
    echo "ERROR: Binary not found at expected path: $original_binary"
    exit 1
fi
