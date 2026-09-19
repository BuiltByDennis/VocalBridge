#!/bin/bash
set -e

# Setup directories
export ANDROID_HOME="/home/tjay/android-sdk"
mkdir -p "$ANDROID_HOME/cmdline-tools"
cd "$ANDROID_HOME/cmdline-tools"

# Download Android command line tools
if [ ! -f "cmdline-tools.zip" ]; then
  curl -o cmdline-tools.zip https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip
fi

if [ ! -d "latest" ]; then
  unzip -q cmdline-tools.zip
  mv cmdline-tools latest
fi

# Add to path for this session
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"

# Ensure Java is available
export JAVA_HOME="/usr/lib/jvm/default-java"

# Install basic platforms and tools, suppress output
yes | sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0" > /dev/null 2>&1

echo "Android SDK setup complete."
