#!/bin/bash

# Development script : Reinstall and restart Plasma

WIDGET_NAME="thepiou.plasma.todo"
WIDGET_DIR="plasma-widget"

echo "🔄 Updating the widget widget..."

# Désinstaller
kpackagetool6 --type=Plasma/Applet --remove="$WIDGET_NAME" &> /dev/null

# Réinstaller
kpackagetool6 --type=Plasma/Applet --install "$WIDGET_DIR"

if [ $? -eq 0 ]; then
    echo "✅ Widget reinstalled"
    echo "🔄 Restarting Plasma..."

    # Redémarrer plasmashell
    killall plasmashell
    sleep 2
    plasmashell &> /dev/null &

    echo "✅ Done ! Widget has been updated."
else
    echo "❌ Error while reinstalling"
    exit 1
fi
