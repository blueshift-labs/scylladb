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

# See what the container actually sees
./tools/toolchain/dbuild env | grep -E 'BUILD_MODE|MODE'

# Clean the partial dir that lacks build.ninja
./tools/toolchain/dbuild bash -lc '
  MODE=${BUILD_MODE:-release}
  rm -rf build/$MODE
  ./configure.py --mode=$MODE
  ninja -C build/$MODE scylla
  ninja -C build/$MODE scylla-package
  ls -l build/$MODE/scylla-package/SCYLLA-PACKAGES/*.rpm
'

echo "Scylla build completed successfully"

# Define original and renamed binary paths
tar_name="scylla-${software_arch}.tar.gz"
tar -cvzf "$tar_name" build/${BUILD_MODE}

echo "$tar_name" > binary_name.txt
echo "Wrote tarball name to binary_name.txt"
