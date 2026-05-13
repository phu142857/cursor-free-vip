#!/bin/bash

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logo
print_logo() {
    echo -e "${CYAN}"
    cat << "EOF"
   ██████╗██╗   ██╗██████╗ ███████╗ ██████╗ ██████╗      ██████╗ ██████╗  ██████╗   
  ██╔════╝██║   ██║██╔══██╗██╔════╝██╔═══██╗██╔══██╗     ██╔══██╗██╔══██╗██╔═══██╗  
  ██║     ██║   ██║██████╔╝███████╗██║   ██║██████╔╝     ██████╔╝██████╔╝██║   ██║  
  ██║     ██║   ██║██╔══██╗╚════██║██║   ██║██╔══██╗     ██╔═══╝ ██╔══██╗██║   ██║  
  ╚██████╗╚██████╔╝██║  ██║███████║╚██████╔╝██║  ██║     ██║     ██║  ██║╚██████╔╝  
   ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝     ╚═╝     ╚═╝  ╚═╝ ╚═════╝  
EOF
    echo -e "${NC}"
}

# Get download folder path
get_downloads_dir() {
    if [[ "$(uname)" == "Darwin" ]]; then
        echo "$HOME/Downloads"
    else
        if [ -f "$HOME/.config/user-dirs.dirs" ]; then
            . "$HOME/.config/user-dirs.dirs"
            echo "${XDG_DOWNLOAD_DIR:-$HOME/Downloads}"
        else
            echo "$HOME/Downloads"
        fi
    fi
}

# Get latest version
get_latest_version() {
    echo -e "${CYAN}ℹ️ Checking latest version...${NC}"
    latest_release=$(curl -s https://api.github.com/repos/hovanhoa/cursor-free-vip/releases/latest) || {
        echo -e "${RED}❌ Cannot get latest version information${NC}"
        exit 1
    }
    
    VERSION=$(echo "$latest_release" | grep -o '"tag_name": ".*"' | cut -d'"' -f4 | tr -d 'v')
    if [ -z "$VERSION" ]; then
        echo -e "${RED}❌ Failed to parse version from GitHub API response:\n${latest_release}"
        exit 1
    fi

    echo -e "${GREEN}✅ Found latest version: ${VERSION}${NC}"
}

# Detect system type and architecture
detect_os() {
    if [[ "$(uname)" == "Darwin" ]]; then
        # Detect macOS architecture
        ARCH=$(uname -m)
        if [[ "$ARCH" == "arm64" ]]; then
            OS="mac_arm64"
            echo -e "${CYAN}ℹ️ Detected macOS ARM64 architecture${NC}"
        else
            OS="mac_intel"
            echo -e "${CYAN}ℹ️ Detected macOS Intel architecture${NC}"
        fi
    elif [[ "$(uname)" == "Linux" ]]; then
        # Detect Linux architecture
        ARCH=$(uname -m)
        if [[ "$ARCH" == "aarch64" || "$ARCH" == "arm64" ]]; then
            OS="linux_arm64"
            echo -e "${CYAN}ℹ️ Detected Linux ARM64 architecture${NC}"
        else
            OS="linux_x64"
            echo -e "${CYAN}ℹ️ Detected Linux x64 architecture${NC}"
        fi
    else
        # Assume Windows
        OS="windows"
        echo -e "${CYAN}ℹ️ Detected Windows system${NC}"
    fi
}

# Install from local binary
install_cursor_free_vip() {
    local binary_path="/home/teifu142/ATE/WORK/cursor-free-vip/dist/CursorFreeVIP_1.8.11_linux"

    echo -e "${CYAN}ℹ️ Using local binary...${NC}"
    echo -e "${CYAN}ℹ️ Path: ${binary_path}${NC}"

    # Check if file exists
    if [ ! -f "${binary_path}" ]; then
        echo -e "${RED}❌ Binary file not found${NC}"
        exit 1
    fi

    # Verify executable type
    local file_info
    file_info=$(file "${binary_path}")

    echo -e "${CYAN}ℹ️ File type: ${file_info}${NC}"

    if [[ "${file_info}" != *"ELF 64-bit"* ]]; then
        echo -e "${RED}❌ Invalid Linux executable${NC}"
        exit 1
    fi

    # Set executable permission
    echo -e "${CYAN}ℹ️ Setting executable permissions...${NC}"

    if ! chmod +x "${binary_path}"; then
        echo -e "${RED}❌ Failed to set executable permissions${NC}"
        exit 1
    fi

    echo -e "${GREEN}✅ Binary is executable${NC}"

    EXTRA_FLAGS="--no-sandbox --disable-gpu --disable-dev-shm-usage"

    # Run program
    if [ "$EUID" -ne 0 ]; then
        echo -e "${YELLOW}⚠️ Running as normal user${NC}"
        "${binary_path}"
    else
        echo -e "${CYAN}ℹ️ Running as root${NC}"
        "${binary_path}"
    fi
}
# Main program
main() {
    print_logo
    get_latest_version
    detect_os
    install_cursor_free_vip
}

# Run main program
main 
