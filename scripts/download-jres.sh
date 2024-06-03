#!/bin/bash

# Default configurations
FEATURE_VERSION=${FEATURE_VERSION:-"11"}
RELEASE_TYPE=${RELEASE_TYPE:-"ga"}
HEAP_SIZE=${HEAP_SIZE:-"normal"}
IMAGE_TYPE=${IMAGE_TYPE:-"jre"}
JVM_IMPL=${JVM_IMPL:-"hotspot"}
PROJECT=${PROJECT:-"jdk"}
VENDOR=${VENDOR:-"eclipse"}

# Number of retries for downloading and checksum verification
MAX_RETRIES=3

# Base directory for JREs
BASE_DIR="jre"

# Function to fetch release information
fetch_release_information() {
    local ARCHITECTURE=$1
    local OS=$2
    local RELEASE_URL="https://api.adoptium.net/v3/assets/feature_releases/${FEATURE_VERSION}/${RELEASE_TYPE}?architecture=${ARCHITECTURE}&heap_size=${HEAP_SIZE}&image_type=${IMAGE_TYPE}&jvm_impl=${JVM_IMPL}&os=${OS}&page=0&page_size=10&project=${PROJECT}&sort_method=DEFAULT&sort_order=DESC&vendor=${VENDOR}"

    echo "Release URL for $OS $ARCHITECTURE: $RELEASE_URL"

    local FEATURE_RELEASE_INFORMATION
    if ! FEATURE_RELEASE_INFORMATION=$(curl -s "$RELEASE_URL"); then
        echo "Error: Failed to fetch release information from $RELEASE_URL."
        return 1
    fi

    DOWNLOAD_LINK=$(echo "$FEATURE_RELEASE_INFORMATION" | jq -r '.[0].binaries[0].package.link')
    CHECKSUM_LINK=$(echo "$FEATURE_RELEASE_INFORMATION" | jq -r '.[0].binaries[0].package.checksum_link')

    if [ -z "$DOWNLOAD_LINK" ] || [ -z "$CHECKSUM_LINK" ]; then
        echo "Error: Failed to get download or checksum link for $OS $ARCHITECTURE."
        return 1
    fi

    return 0
}

# Function to download a file with retries
download_file() {
    local URL=$1
    local DEST_DIR=$2
    local RETRY_COUNT=0

    while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
        if wget -q --show-progress -P "$DEST_DIR" "$URL"; then
            return 0
        fi
        echo "Download failed. Retrying... ($((RETRY_COUNT+1))/$MAX_RETRIES)"
        RETRY_COUNT=$((RETRY_COUNT + 1))
        sleep 2
    done

    echo "Error: Failed to download file from $URL after $MAX_RETRIES retries."
    return 1
}

# Function to verify checksum with retries
verify_checksum() {
    local TEMP_DIR=$1
    local RETRY_COUNT=0

    while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
        if (cd "$TEMP_DIR" && sha256sum -c ./*.sha256.txt); then
            return 0
        fi
        echo "Checksum verification failed. Retrying... ($((RETRY_COUNT+1))/$MAX_RETRIES)"
        RETRY_COUNT=$((RETRY_COUNT + 1))
        sleep 2
    done

    echo "Error: Checksum verification failed after $MAX_RETRIES retries."
    return 1
}

# Function to download JRE for a specific platform and architecture
download_jre() {
    local ARCHITECTURE=$1
    local OS=$2
    local TEMP_DIR
    TEMP_DIR=$(mktemp -d)
    trap 'rm -rf -- "$TEMP_DIR"' EXIT

    if ! fetch_release_information "$ARCHITECTURE" "$OS"; then
        echo "Error: Failed to fetch release information for $OS $ARCHITECTURE."
        return 1
    fi

    echo "Downloading JRE for $OS $ARCHITECTURE..."
    if ! download_file "$DOWNLOAD_LINK" "$TEMP_DIR"; then
        echo "Error: Failed to download JRE for $OS $ARCHITECTURE."
        return 1
    fi

    echo "Downloading checksum file for JRE for $OS $ARCHITECTURE..."
    if ! download_file "$CHECKSUM_LINK" "$TEMP_DIR"; then
        echo "Error: Failed to download checksum file for $OS $ARCHITECTURE."
        return 1
    fi

    echo "Verifying checksum for JRE for $OS $ARCHITECTURE..."
    if ! verify_checksum "$TEMP_DIR"; then
        echo "Error: Checksum verification failed for JRE for $OS $ARCHITECTURE."
        return 1
    fi

    DEST_DIR="$BASE_DIR/$OS/$ARCHITECTURE"
    mkdir -p "$DEST_DIR"

    if [[ "$OS" == "windows" ]]; then
        unzip "$TEMP_DIR"/*.zip -d "$TEMP_DIR"
        mv "$TEMP_DIR"/*/* "$DEST_DIR"
    else
        tar -xzf "$TEMP_DIR"/*.tar.gz -C "$DEST_DIR" --strip-components=1
    fi

    echo "JRE for $OS $ARCHITECTURE download, verification, and extraction complete."
}

# Check if the jq command is available
if ! command -v jq >/dev/null; then
    echo "Error: 'jq' command not found. Please install 'jq' to run this script."
    exit 1
fi

# Check if the unzip command is available
if ! command -v unzip >/dev/null; then
    echo "Error: 'unzip' command not found. Please install 'unzip' to run this script."
    exit 1
fi

# Define architectures and operating systems
ARCHS=("x64" "aarch64")
OSS=("linux" "mac" "windows")

# Function to determine if a combination is available
is_combination_available() {
    local OS=$1
    local ARCH=$2

    # Define unavailable combinations
    if [[ ("$OS" == "linux" && "$ARCH" == "x86") || \
          ("$OS" == "mac" && "$ARCH" == "x86") || \
          ("$OS" == "windows" && "$ARCH" == "aarch64") ]]; then
        return 1
    fi

    return 0
}

# Download JRE for all defined combinations, excluding unavailable ones
for OS in "${OSS[@]}"; do
    for ARCH in "${ARCHS[@]}"; do
        if ! is_combination_available "$OS" "$ARCH"; then
            echo "Skipping unavailable combination: $OS $ARCH"
            continue
        fi

        if ! download_jre "$ARCH" "$OS"; then
            echo "Error: Failed to download JRE for $OS $ARCH."
            exit 1
        fi
    done
done
