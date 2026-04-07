#!/bin/bash

# Development script : Reinstall and restart Plasma

WIDGET_NAME="kde.plasma.todo"
WIDGET_DIR="plasma-widget"

echo "🔄 Updating the widget widget..."

# Uninstall
kpackagetool6 --type=Plasma/Applet --remove="$WIDGET_NAME" &> /dev/null

# Reinstall
kpackagetool6 --type=Plasma/Applet --install "$WIDGET_DIR"

if [ $? -eq 0 ]; then
    echo "✅ Widget reinstalled"
    echo "🔄 Restarting Plasma..."

    # Restart plasmashell
    killall plasmashell
    sleep 2
    plasmashell &> /dev/null &

    echo "✅ Done ! Widget has been updated."
else
    echo "❌ Error while reinstalling" >&2
    exit 1
fi
