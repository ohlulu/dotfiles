#!/usr/bin/env bash

# Close any open System Preferences panes, to prevent them from overriding
# settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `.macos` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

echo "Start install macOS perference."

DIR="$(dirname $0)"

source $DIR/date_time.sh
source $DIR/dock.sh
source $DIR/finder.sh
source $DIR/general.sh
source $DIR/google_chrome.sh
source $DIR/keyboard.sh
source $DIR/mac_app_store.sh
source $DIR/mission_control.sh
source $DIR/other.sh
source $DIR/safari_web_kit.sh
source $DIR/screen.sh
source $DIR/sharing.sh
source $DIR/trackpad.sh

# Kill affected applications
for app in "Activity Monitor" \
	"Address Book" \
	"Calendar" \
	"cfprefsd" \
	"Contacts" \
	"Dock" \
	"Finder" \
	"Google Chrome Canary" \
	"Google Chrome" \
	"Mail" \
	"Messages" \
	"Photos" \
	"Safari" \
	"Spectacle" \
	"SystemUIServer" \
	"Terminal" \
	"iCal"; do
	killall "${app}" &> /dev/null
done
echo "Done. Note that some of these changes require a logout/restart to take effect."