################################################################################
# Mission controller                                                           #
################################################################################

# Speed up Mission Control animation
defaults write com.apple.dock expose-animation-duration -float 0.1

# Don't group windows by application
defaults write com.apple.dock expose-group-by-app -bool false

# Don't automatically rearrange Spaces based on most recent use
defaults write com.apple.dock mru-spaces -bool false

################################################################################
# Hot Corners                                                                  #
################################################################################

#  0 : NOP
#  2 : Mission Control
#  3 : Show application windows
#  4 : Desktop
#  5 : Start screen saver
#  6 : Disable screen saver
#  7 : Dashboard
# 10 : Put display to sleep
# 11 : Launchpad
# 12 : Notification Center

# Top left
defaults write com.apple.dock wvous-tl-corner   -int 5
defaults write com.apple.dock wvous-tl-modifier -int 0

# Top right
defaults write com.apple.dock wvous-tr-corner   -int 0
defaults write com.apple.dock wvous-tr-modifier -int 0

# Bottom left
defaults write com.apple.dock wvous-bl-corner   -int 0
defaults write com.apple.dock wvous-bl-modifier -int 0

# Bottom right
defaults write com.apple.dock wvous-br-corner   -int 4
defaults write com.apple.dock wvous-br-modifier -int 0