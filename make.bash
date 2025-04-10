#!/bin/bash

set -uex

# Define the directory where Scylla has been cloned by Jenkins
BUILD_MODE="release"  # Can be debug,release or dev 

# Function to check and set the architecture
get_arch()
{
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

    return 0
}

get_arch

git submodule update --init --force --recursive

./tools/toolchain/dbuild ./configure.py --mode=$BUILD_MODE

./tools/toolchain/dbuild ninja

echo "Scylla build completed successfully"
