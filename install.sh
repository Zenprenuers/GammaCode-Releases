#!/bin/bash
set -e

# GammaCode Installation Script
# Usage: curl -fsSL https://raw.githubusercontent.com/Zenprenuers/GammaCode-Releases/main/install.sh | bash
# 
# Environment variables:
#   VERSION                 - Specific version to install (default: v1.0.0)
#   GAMMACODE_INSTALL_DIR   - Custom installation directory
#   XDG_BIN_DIR            - XDG-compliant binary directory

REPO="Zenprenuers/GammaCode-Releases"
BINARY_NAME="gammacode"
# Installation directory - respects user preferences
if [ -n "${GAMMACODE_INSTALL_DIR:-}" ]; then
    INSTALL_DIR="$GAMMACODE_INSTALL_DIR"
elif [ -n "${XDG_BIN_DIR:-}" ]; then
    INSTALL_DIR="$XDG_BIN_DIR"
elif [ -d "$HOME/bin" ] || mkdir -p "$HOME/bin" 2>/dev/null; then
    INSTALL_DIR="$HOME/bin"
else
    INSTALL_DIR="$HOME/.gammacode/bin"
fi

# Ensure install directory exists
mkdir -p "$INSTALL_DIR" 2>/dev/null || true

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

# Get latest version (hardcoded since you're using direct file hosting)
get_latest_version() {
    # Since you're hosting binaries directly in the repo structure,
    # we'll default to v1.0.0 but allow override via VERSION env var
    local version="v1.0.0"
    
    # You could also try to fetch this from a version file in your repo:
    # version=$(curl -s "https://raw.githubusercontent.com/${REPO}/main/releases/latest/version.txt" 2>/dev/null || echo "v1.0.0")
    
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
    
    # Determine binary name and URL based on platform
    local binary_name="$BINARY_NAME"
    local download_url
    
    if [[ "$platform" == "windows-"* ]]; then
        binary_name="${BINARY_NAME}.exe"
    fi
    
    # Download directly from GitHub raw content
    download_url="https://raw.githubusercontent.com/${REPO}/main/releases/latest/${version}/${binary_name}"
    
    log_info "Downloading from: $download_url"
    
    if ! curl -L -o "$binary_name" "$download_url"; then
        log_error "Failed to download $binary_name"
        exit 1
    fi
    
    # Make binary executable
    chmod +x "$binary_name"
    
    # Install binary
    if [ -w "$INSTALL_DIR" ]; then
        cp "$binary_name" "$INSTALL_DIR/$BINARY_NAME"
        chmod +x "$INSTALL_DIR/$BINARY_NAME"
    else
        log_info "Installing to $INSTALL_DIR (requires sudo)"
        sudo cp "$binary_name" "$INSTALL_DIR/$BINARY_NAME"
        sudo chmod +x "$INSTALL_DIR/$BINARY_NAME"
    fi
    
    # Cleanup
    cd /
    rm -rf "$temp_dir"
    
    log_success "GammaCode $version installed successfully!"
}

# Add to PATH if needed
setup_path() {
    # Skip if already in PATH
    if [[ ":$PATH:" == *":$INSTALL_DIR:"* ]]; then
        return 0
    fi
    
    # Detect shell and config file
    local current_shell config_file
    current_shell=$(basename "$SHELL" 2>/dev/null || echo "bash")
    
    case $current_shell in
        fish)
            config_file="$HOME/.config/fish/config.fish"
            if [ -f "$config_file" ]; then
                echo "fish_add_path $INSTALL_DIR" >> "$config_file"
                log_info "Added $INSTALL_DIR to PATH in $config_file"
            fi
            ;;
        zsh)
            for config_file in "$HOME/.zshrc" "$HOME/.zprofile"; do
                if [ -f "$config_file" ]; then
                    echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >> "$config_file"
                    log_info "Added $INSTALL_DIR to PATH in $config_file"
                    break
                fi
            done
            ;;
        bash|*)
            for config_file in "$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.profile"; do
                if [ -f "$config_file" ]; then
                    echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >> "$config_file"
                    log_info "Added $INSTALL_DIR to PATH in $config_file"
                    break
                fi
            done
            ;;
    esac
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
        log_info "You may need to restart your shell or run: source ~/.bashrc"
        log_info "Or add $INSTALL_DIR to your PATH manually"
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
    
    # Setup PATH
    setup_path
    
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
