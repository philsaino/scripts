#!/bin/bash

# OSX - OPTIMIZER

# massively increase virtualized macOS by disabling spotlight.
sudo mdutil -i off -a

# check if enabled (should contain `serverperfmode=1`)
#nvram boot-args

# turn on
sudo nvram boot-args="serverperfmode=1 $(nvram boot-args 2>/dev/null | cut -f 2-)"

# turn off
#sudo nvram boot-args="$(nvram boot-args 2>/dev/null | sed -e $'s/boot-args\t//;s/serverperfmode=1//')"

# Disable heavy login screen wallpaper
sudo defaults write /Library/Preferences/com.apple.loginwindow DesktopPicture ""

# Reduce Motion & Transparency

defaults write com.apple.Accessibility DifferentiateWithoutColor -int 1
defaults write com.apple.Accessibility ReduceMotionEnabled -int 1
defaults write com.apple.universalaccess reduceMotion -int 1
defaults write com.apple.universalaccess reduceTransparency -int 1

# Disable screen locking
defaults write com.apple.loginwindow DisableScreenLock -bool true

# Disable saving the application state on shutdown
defaults write com.apple.loginwindow TALLogoutSavesState -bool false

