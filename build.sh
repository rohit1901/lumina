#!/bin/bash
# Build script for Lumina with CLI argument support

set -e  # Exit on error

# ============================================
# Configuration (Defaults)
# ============================================
BUILD_PYTHON=1
BUILD_ELECTRON=1

# ============================================
# Setup
# ============================================
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'  # No Color

# ============================================
# Help Function
# ============================================

show_help() {
    cat << EOF
${BLUE}Lumina Build Script${NC}

Usage: $0 [OPTIONS]

Options:
  --python-only         Build only Python CLI (skip Electron)
  --electron-only       Build only Electron app (skip Python)
  --skip-python         Skip Python build
  --skip-electron       Skip Electron build
  --all                 Build everything (default)
  -h, --help            Show this help message

Examples:
  $0                    # Build everything (default)
  $0 --python-only      # Build only Python CLI
  $0 --electron-only    # Build only Electron app
  $0 --skip-python      # Build only Electron
  $0 --all              # Explicitly build everything

EOF
}

# ============================================
# Parse Command-Line Arguments
# ============================================

parse_arguments() {
    # If no arguments, use defaults (build all)
    if [ $# -eq 0 ]; then
        return
    fi

    while [[ $# -gt 0 ]]; do
        case $1 in
            --python-only)
                BUILD_PYTHON=1
                BUILD_ELECTRON=0
                shift
                ;;
            --electron-only)
                BUILD_PYTHON=0
                BUILD_ELECTRON=1
                shift
                ;;
            --skip-python)
                BUILD_PYTHON=0
                shift
                ;;
            --skip-electron)
                BUILD_ELECTRON=0
                shift
                ;;
            --all)
                BUILD_PYTHON=1
                BUILD_ELECTRON=1
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                echo -e "${RED}❌ Unknown option: $1${NC}"
                echo ""
                show_help
                exit 1
                ;;
        esac
    done
}

# ============================================
# Build Functions
# ============================================

build_python() {
    echo -e "${BLUE}📦 Step 1: Building Python CLI (Poetry)...${NC}"
    cd "$DIR/python"

    if ! command -v poetry &> /dev/null; then
        echo -e "${RED}❌ Poetry is not installed. Run: pipx install poetry${NC}"
        exit 1
    fi

    poetry install

    # Install PyInstaller in the poetry env
    poetry add --dev pyinstaller

    echo "Building CLI with PyInstaller..."
    poetry run pyinstaller --clean theme-toggle.spec

    # Test build
    if [ -f "dist/theme-toggle" ]; then
        BIN_PATH="dist/theme-toggle"
    elif [ -f "dist/theme-toggle/theme-toggle" ]; then
        BIN_PATH="dist/theme-toggle/theme-toggle"
    else
        echo -e "${RED}❌ Python CLI build failed${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ Python CLI built successfully: $BIN_PATH${NC}"
    chmod +x "$BIN_PATH"

}


build_electron() {
    echo -e "${BLUE}📦 Step 2: Building Electron App...${NC}"
    cd "$DIR/electron"

    # Check if Node.js is installed
    if ! command -v node &> /dev/null; then
        echo -e "${RED}❌ Node.js is not installed${NC}"
        exit 1
    fi

    echo "Node.js version: $(node -v)"
    echo "npm version: $(npm -v)"
    echo ""

    # Check Node version (require 18+)
    NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
    if [ "$NODE_VERSION" -lt 18 ]; then
        echo -e "${RED}❌ Node.js version 18+ required (found v${NODE_VERSION})${NC}"
        exit 1
    fi

    # Install dependencies
    echo "Installing Node dependencies..."
    npm install

    # Compile TypeScript
    echo "Compiling TypeScript..."
    npm run build

    # Verify build
    if [ -f "dist/main.js" ]; then
        echo -e "${GREEN}✅ TypeScript compiled successfully${NC}"

        # Check if Python CLI exists for Electron to use
        if [ ! -f "$DIR/python/dist/theme-toggle/theme-toggle" ]; then
            echo -e "${YELLOW}⚠️  Warning: Python CLI not found at:${NC}"
            echo "   $DIR/python/dist/theme-toggle/theme-toggle"
            echo ""
            echo "   Electron app requires Python CLI to function."
            echo "   Run: $0 --python-only"
        fi
    else
        echo -e "${RED}❌ TypeScript compilation failed${NC}"
        exit 1
    fi
}

# ============================================
# Main Build Process
# ============================================

main() {
    # Parse CLI arguments first
    parse_arguments "$@"

    echo -e "${BLUE}🚀 Building Lumina...${NC}"
    echo ""

    # Show build plan
    echo "Build Configuration:"
    if [ "$BUILD_PYTHON" -eq 1 ]; then
        echo -e "  ${GREEN}✓${NC} Python CLI"
    else
        echo -e "  ${YELLOW}✗${NC} Python CLI (skipped)"
    fi
    if [ "$BUILD_ELECTRON" -eq 1 ]; then
        echo -e "  ${GREEN}✓${NC} Electron App"
    else
        echo -e "  ${YELLOW}✗${NC} Electron App (skipped)"
    fi
    echo ""

    local build_count=0

    # Build Python CLI
    if [ "$BUILD_PYTHON" -eq 1 ]; then
        build_python
        ((build_count++))
        echo ""
    fi

    # Build Electron App
    if [ "$BUILD_ELECTRON" -eq 1 ]; then
        build_electron
        ((build_count++))
        echo ""
    fi

    # Return to root directory
    cd "$DIR"

    # Final status
    if [ $build_count -eq 0 ]; then
        echo -e "${YELLOW}⚠️  No components were built (all builds disabled)${NC}"
        echo ""
        echo "Run with --help to see available options"
        exit 0
    fi

    echo -e "${GREEN}✅ Build complete! ($build_count component(s) built)${NC}"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Next steps:"
    echo ""

    if [ "$BUILD_ELECTRON" -eq 1 ]; then
        echo "  🔧 Development mode:"
        echo "     cd electron && npm run dev"
        echo ""
        echo "  📦 Package for distribution:"
        echo "     cd electron && npm run package:mac"
        echo ""
    fi

    if [ "$BUILD_PYTHON" -eq 1 ]; then
        echo "  🐍 Test Python CLI:"
        echo "     ./python/dist/theme-toggle/theme-toggle current"
        echo ""
        echo "  🐍 Install CLI system-wide:"
        echo "     sudo ln -s $(pwd)/python/dist/theme-toggle/theme-toggle /usr/local/bin/theme-toggle"
        echo ""
    fi

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# ============================================
# Execute
# ============================================

main "$@"
