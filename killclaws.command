#!/bin/bash
# KillClaws - One command to remove all Claw AI products
# Double-click this file on macOS to run in Terminal

# Change to the directory where this script is located
cd "$(dirname "$0")" || exit 1

echo ""
echo "  KillClaws - One command to remove all Claw AI products"
echo "  ======================================================"
echo ""

# Check if killclaws.sh exists in the same directory
if [ -f "./killclaws.sh" ]; then
    chmod +x ./killclaws.sh
    ./killclaws.sh "$@"
else
    echo "  killclaws.sh not found, downloading latest version..."
    echo ""
    curl -fsSL -o "/tmp/killclaws.sh" "https://raw.githubusercontent.com/greywen/KillClaws/main/killclaws.sh"
    chmod +x /tmp/killclaws.sh
    /tmp/killclaws.sh "$@"
fi

echo ""
echo "Press any key to close..."
read -n 1 -s -r
