#!/bin/bash

# Script to install Widget Plasma To Do

WIDGET_NAME="kde.plasma.todo"
WIDGET_DIR="plasma-widget"

echo "==================================="
echo "Installation of To Do Widget"
echo "==================================="
echo ""

# Make sure the widget folder exists
if [ ! -d "$WIDGET_DIR" ]; then
    echo "❌ Error: The $WIDGET_DIR folder does not exist"
    exit 1
fi

# Make sure the kpackagetool6 package is installed
if ! command -v kpackagetool6 &> /dev/null; then
    echo "❌ Error: kpackagetool6 is not installed"
    echo "Install instructions: sudo pacman -S plasma-framework (Arch) ou sudo apt install plasma-framework (Debian/Ubuntu)"
    exit 1
fi

# Uninstall the widget if it already exists
echo "🔍 Verifying..."
if kpackagetool6 --type=Plasma/Applet --show="$WIDGET_NAME" &> /dev/null; then
    echo "📦 Widget already installed, updating..."
    kpackagetool6 --type=Plasma/Applet --upgrade="$WIDGET_DIR"
else
    # Install the widget
    echo "📦 Installing..."
    kpackagetool6 --type=Plasma/Applet --install "$WIDGET_DIR"
fi

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Installation successful!"
    echo ""
    echo "How to use:"
    echo "1. Right-click the desktop or panel"
    echo "2. Select 'Add Widgets'..."
    echo "3. Search 'To Do'"
    echo "4. Drag and drop the widget to your desktop or panel"
    echo ""
    echo "To uninstall:"
    echo "  kpackagetool6 --type=Plasma/Applet --remove=$WIDGET_NAME"
    echo ""
else
    echo ""
    echo "❌ Error during installation"
    exit 1
fi
