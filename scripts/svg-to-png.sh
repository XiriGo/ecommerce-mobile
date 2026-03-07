#!/bin/bash
# SVG → PNG Converter for XiriGo Design Files
# Converts all SVG design files to high-resolution PNGs for visual reference.
# These PNGs are used by pipeline agents (Architect, Reviewer) to "see" the design.
#
# Requirements: rsvg-convert (brew install librsvg)
# Usage: ./scripts/svg-to-png.sh [--scale 2] [--single XiriGo_App_03.svg]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
SVG_DIR="$PROJECT_ROOT/XiriGo-Design/Svg"
OUTPUT_DIR="$PROJECT_ROOT/XiriGo-Design/Png_Screens"
SCALE=2

# Parse arguments
SINGLE_FILE=""
while [[ $# -gt 0 ]]; do
    case $1 in
        --scale) SCALE="$2"; shift 2 ;;
        --single) SINGLE_FILE="$2"; shift 2 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

# Check rsvg-convert
if ! command -v rsvg-convert &>/dev/null; then
    echo "ERROR: rsvg-convert not found. Install with: brew install librsvg"
    exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

convert_svg() {
    local svg_file="$1"
    local basename
    basename=$(basename "$svg_file" .svg)
    local png_file="$OUTPUT_DIR/${basename}@${SCALE}x.png"

    echo "Converting: $(basename "$svg_file") → ${basename}@${SCALE}x.png"
    rsvg-convert \
        --zoom="$SCALE" \
        --format=png \
        --output="$png_file" \
        "$svg_file"

    # Print dimensions for reference
    local size
    size=$(sips -g pixelWidth -g pixelHeight "$png_file" 2>/dev/null | tail -2 | awk '{print $2}' | tr '\n' 'x' | sed 's/x$//')
    echo "  Output: ${size}px"
}

if [[ -n "$SINGLE_FILE" ]]; then
    convert_svg "$SVG_DIR/$SINGLE_FILE"
else
    for svg_file in "$SVG_DIR"/XiriGo_App_*.svg; do
        convert_svg "$svg_file"
    done
fi

echo ""
echo "Done. PNGs saved to: XiriGo-Design/Png_Screens/"
echo "Pipeline agents can read these with the Read tool for visual reference."
