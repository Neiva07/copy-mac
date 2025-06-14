#!/bin/bash

# Build the app
xcodebuild clean build \
    -project CopyMac.xcodeproj \
    -scheme CopyMac \
    -configuration Release \
    -destination 'platform=macOS' \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO

# Find the built app
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "CopyMac.app" -type d | grep "Release")

if [ -z "$APP_PATH" ]; then
    echo "Error: Could not find CopyMac.app"
    exit 1
fi

# Create a build directory
mkdir -p build

# Copy the app to the build directory
cp -r "$APP_PATH" build/

echo "App has been built and copied to build/CopyMac.app"
echo "You can find it at: $(pwd)/build/CopyMac.app" 