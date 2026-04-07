#!/bin/bash

# Script to uninstall Widget Plasma To Do

WIDGET_NAME="kde.plasma.todo"

echo "==================================="
echo "Uninstall To Do Widget"
echo "==================================="
echo ""

# Make sure kpackagetool6 package is installed
if ! command -v kpackagetool6 &> /dev/null; then
    echo "❌ Error: kpackagetool6 is not installed"
    exit 1
fi

# Make sure the widget is installed
echo "🔍 Verifying..."
if ! kpackagetool6 --type=Plasma/Applet --show="$WIDGET_NAME" &> /dev/null; then
    echo "⚠️  Widget is not installed"
    exit 0
fi

# Désinstaller le widget
echo "🗑️  Uninstalling..."
kpackagetool6 --type=Plasma/Applet --remove="$WIDGET_NAME"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Widget uninstalled successfully!"
    echo ""
else
    echo ""
    echo "❌ Error while uninstalling"
    exit 1
fi
