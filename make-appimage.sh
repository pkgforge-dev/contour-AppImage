#!/bin/sh

set -eu

ARCH=$(uname -m)
VERSION=$(pacman -Q contour | awk '{print $2; exit}') # example command to get version of application here
export ARCH VERSION
export OUTPATH=./dist
export ADD_HOOKS="self-updater.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export ICON=/usr/share/icons/hicolor/256x256/apps/org.contourterminal.Contour.png
export DESKTOP=/usr/share/applications/org.contourterminal.Contour.desktop
export DEPLOY_OPENGL=1
export DEPLOY_VULKAN=0
export URUNTIME_PRELOAD=1
# Deploy dependencies
quick-sharun /usr/sbin/contour

# Additional changes can be done in between here
# libqt6 multimedia will try load vulkan for hardware accel
# but none of that is really needed here, this can use OpenGL just fine
echo 'ANYLINUX_DO_NOT_LOAD_LIBS=libvulkan*:${ANYLINUX_DO_NOT_LOAD_LIBS}' >> ./AppDir/.env

# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the app for 12 seconds, if the test fails due to the app
# having issues running in the CI use --simple-test instead
quick-sharun --test ./dist/*.AppImage
