#!/bin/bash
set -e

# GammaCode Installation Script
# Usage: curl -fsSL https://install.gammacode.dev | bash

REPO="Zenprenuers/GammaCode-Releases"
BINARY_NAME="gammacode"
INSTALL_DIR="/usr/local/bin"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detect OS and architecture
detect_platform() {
    local os arch
    
    case "$(uname -s)" in
        Darwin)
            os="darwin"
            ;;
        Linux)
            os="linux"
            ;;
        MINGW*|CYGWIN*|MSYS*)
            os="windows"
            ;;
        *)
            log_error "Unsupported operating system: $(uname -s)"
            exit 1
            ;;
    esac
    
    case "$(uname -m)" in
        x86_64|amd64)
            arch="x64"
            ;;
        aarch64|arm64)
            arch="arm64"
            ;;
        armv7l)
            arch="arm"
            ;;
        *)
            log_error "Unsupported architecture: $(uname -m)"
            exit 1
            ;;
    esac
    
    echo "${os}-${arch}"
}

# Get latest version from GitHub releases
get_latest_version() {
    local version
    version=$(curl -s "https://api.github.com/repos/${REPO}/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    
    if [ -z "$version" ]; then
        log_error "Failed to get latest version"
        exit 1
    fi
    
    echo "$version"
}

# Download and install binary
install_binary() {
    local platform="$1"
    local version="$2"
    local temp_dir
    
    # Use environment variable for version if provided
    if [ -n "${VERSION:-}" ]; then
        version="$VERSION"
    fi
    
    log_info "Installing GammaCode $version for $platform"
    
    # Create temporary directory
    temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    # Determine file extension
    local file_ext="tar.gz"
    local binary_name="$BINARY_NAME"
    if [[ "$platform" == "windows-"* ]]; then
        file_ext="zip"
        binary_name="${BINARY_NAME}.exe"
    fi
    
    # Download archive
    local archive_name="${BINARY_NAME}-${platform}.${file_ext}"
    local download_url="https://github.com/${REPO}/releases/download/${version}/${archive_name}"
    
    log_info "Downloading from: $download_url"
    
    if ! curl -L -o "$archive_name" "$download_url"; then
        log_error "Failed to download $archive_name"
        exit 1
    fi
    
    # Extract archive
    if [[ "$file_ext" == "zip" ]]; then
        unzip -q "$archive_name"
    else
        tar -xzf "$archive_name"
    fi
    
    # Find the binary
    local binary_path
    if [ -f "${BINARY_NAME}-${platform}/bin/${binary_name}" ]; then
        binary_path="${BINARY_NAME}-${platform}/bin/${binary_name}"
    elif [ -f "bin/${binary_name}" ]; then
        binary_path="bin/${binary_name}"
    elif [ -f "$binary_name" ]; then
        binary_path="$binary_name"
    else
        log_error "Binary not found in archive"
        exit 1
    fi
    
    # Install binary
    if [ -w "$INSTALL_DIR" ]; then
        cp "$binary_path" "$INSTALL_DIR/$BINARY_NAME"
        chmod +x "$INSTALL_DIR/$BINARY_NAME"
    else
        log_info "Installing to $INSTALL_DIR (requires sudo)"
        sudo cp "$binary_path" "$INSTALL_DIR/$BINARY_NAME"
        sudo chmod +x "$INSTALL_DIR/$BINARY_NAME"
    fi
    
    # Cleanup
    cd /
    rm -rf "$temp_dir"
    
    log_success "GammaCode $version installed successfully!"
}

# Verify installation
verify_installation() {
    if command -v "$BINARY_NAME" >/dev/null 2>&1; then
        local installed_version
        installed_version=$("$BINARY_NAME" --version 2>/dev/null || echo "unknown")
        log_success "Verification successful - GammaCode $installed_version is available"
        log_info "Try running: $BINARY_NAME --help"
    else
        log_warn "Binary installed but not found in PATH"
        log_info "You may need to restart your shell or add $INSTALL_DIR to your PATH"
    fi
}

# Main installation process
main() {
    log_info "Starting GammaCode installation..."
    
    # Check dependencies
    if ! command -v curl >/dev/null 2>&1; then
        log_error "curl is required but not installed"
        exit 1
    fi
    
    if ! command -v tar >/dev/null 2>&1 && ! command -v unzip >/dev/null 2>&1; then
        log_error "tar or unzip is required but not installed"
        exit 1
    fi
    
    # Detect platform
    local platform
    platform=$(detect_platform)
    log_info "Detected platform: $platform"
    
    # Get latest version
    local version
    version=$(get_latest_version)
    log_info "Latest version: $version"
    
    # Check if already installed
    if command -v "$BINARY_NAME" >/dev/null 2>&1; then
        local current_version
        current_version=$("$BINARY_NAME" --version 2>/dev/null || echo "unknown")
        if [ "$current_version" = "${version#v}" ]; then
            log_info "GammaCode $version is already installed"
            exit 0
        else
            log_info "Upgrading from $current_version to $version"
        fi
    fi
    
    # Install binary
    install_binary "$platform" "$version"
    
    # Verify installation
    verify_installation
    
    log_success "Installation complete!"
    echo
    echo "Get started with:"
    echo "  $BINARY_NAME --help"
    echo "  $BINARY_NAME auth login"
    echo "  $BINARY_NAME models"
}

# Run main function
main "$@"
