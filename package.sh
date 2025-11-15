#!/bin/bash
# Package script for Lumina with CLI argument support

set -e  # Exit on error

# ==================================
# Configuration (Defaults)
# ==================================
PACKAGE_MAC=1
PACKAGE_WIN=0
PACKAGE_LINUX=0

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ELECTRON_DIR="$DIR/electron"
PYTHON_CLI_PATH="$DIR/python/dist/theme-toggle/theme-toggle"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

show_help() {
    cat << EOF
${BLUE}Lumina Package Script${NC}

Usage: $0 [OPTIONS]

Options:
  --mac-only            Package for macOS (default)
  --win-only            Package for Windows (not implemented)
  --linux-only          Package for Linux (not implemented)
  --all                 Package for all platforms (mac only fully supported)
  --skip-mac            Skip macOS packaging
  --skip-win            Skip Windows packaging
  --skip-linux          Skip Linux packaging
  -h, --help            Show this help message

Examples:
  $0                    # Package for macOS (default)
  $0 --all              # Package for all platforms (mac only)
  $0 --mac-only         # Package for macOS only
  $0 --skip-mac         # Skip macOS packaging

EOF
}

parse_arguments() {
    # If no arguments, use defaults (mac only)
    if [ $# -eq 0 ]; then
        return
    fi

    while [[ $# -gt 0 ]]; do
        case $1 in
            --mac-only)
                PACKAGE_MAC=1
                PACKAGE_WIN=0
                PACKAGE_LINUX=0
                shift
                ;;
            --win-only)
                PACKAGE_MAC=0
                PACKAGE_WIN=1
                PACKAGE_LINUX=0
                shift
                ;;
            --linux-only)
                PACKAGE_MAC=0
                PACKAGE_WIN=0
                PACKAGE_LINUX=1
                shift
                ;;
            --skip-mac)
                PACKAGE_MAC=0
                shift
                ;;
            --skip-win)
                PACKAGE_WIN=0
                shift
                ;;
            --skip-linux)
                PACKAGE_LINUX=0
                shift
                ;;
            --all)
                PACKAGE_MAC=1
                PACKAGE_WIN=1
                PACKAGE_LINUX=1
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                echo -e "${RED}❌ Unknown option: $1${NC}"
                show_help
                exit 1
                ;;
        esac
    done
}

package_mac() {
    echo -e "${BLUE}📦 Packaging Lumina for macOS...${NC}"
    cd "$ELECTRON_DIR"

    # Ensure Python CLI exists for bundling
    if [ ! -f "$PYTHON_CLI_PATH" ]; then
        echo -e "${RED}❌ Python CLI not found at:${NC}"
        echo "   $PYTHON_CLI_PATH"
        echo -e "${YELLOW}Run ./build.sh --python-only first.${NC}"
        exit 1
    fi

    # Install dependencies if needed
    if [ ! -d "node_modules" ]; then
        echo "Installing Node dependencies..."
        npm install
    fi

    # Package app
    echo "Creating DMG installer for macOS..."
    npm run package:mac

    DMG_PATH_FOUND=$(ls -1 dist/Lumina-*.dmg 2> /dev/null | head -n 1)
    if [[ -n "$DMG_PATH_FOUND" ]]; then
        echo -e "${GREEN}✅ macOS DMG created successfully!${NC}"
        echo "Location: $DMG_PATH_FOUND"
        ls -lh "$DMG_PATH_FOUND"
    else
        echo -e "${RED}❌ DMG creation failed${NC}"
        exit 1
    fi
}

package_win() {
    echo -e "${YELLOW}⚠️  Windows packaging is not implemented.${NC}"
    echo "Consider using electron-builder scripts or add implementation."
}

package_linux() {
    echo -e "${YELLOW}⚠️  Linux packaging is not implemented.${NC}"
    echo "Consider using electron-builder scripts or add implementation."
}

main() {
    parse_arguments "$@"

    echo -e "${BLUE}🚀 Packaging Lumina...${NC}"
    echo ""
    echo "Packaging plan:"
    if [ "$PACKAGE_MAC" -eq 1 ]; then
        echo -e "  ${GREEN}✓${NC} macOS DMG"
    else
        echo -e "  ${YELLOW}✗${NC} macOS DMG (skipped)"
    fi
    if [ "$PACKAGE_WIN" -eq 1 ]; then
        echo -e "  ${GREEN}✓${NC} Windows (not implemented)"
    else
        echo -e "  ${YELLOW}✗${NC} Windows (skipped)"
    fi
    if [ "$PACKAGE_LINUX" -eq 1 ]; then
        echo -e "  ${GREEN}✓${NC} Linux (not implemented)"
    else
        echo -e "  ${YELLOW}✗${NC} Linux (skipped)"
    fi
    echo ""

    local packaged_count=0

    if [ "$PACKAGE_MAC" -eq 1 ]; then
        package_mac
        ((packaged_count++))
        echo ""
    fi

    if [ "$PACKAGE_WIN" -eq 1 ]; then
        package_win
        echo ""
    fi

    if [ "$PACKAGE_LINUX" -eq 1 ]; then
        package_linux
        echo ""
    fi

    if [ $packaged_count -eq 0 ]; then
        echo -e "${YELLOW}⚠️  No platforms were packaged (all packaging disabled)${NC}"
        echo ""
        echo "Run with --help to see options"
        exit 0
    fi

    echo -e "${GREEN}✅ Packaging complete!${NC}"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Next steps:"
    echo ""
    if [ "$PACKAGE_MAC" -eq 1 ]; then
        echo "  📦 Find DMG in: electron/dist/"
        echo "  📋 Test install by opening DMG and dragging Lumina to Applications."
    fi
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

main "$@"
