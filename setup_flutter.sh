#!/bin/bash
set -e

# Setup directories
export FLUTTER_HOME="/home/tjay/flutter"
cd /home/tjay

# Download flutter stable (Linux) with resume support
if [ ! -f "flutter.tar.xz" ]; then
  curl -C - -o flutter.tar.xz https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.3-stable.tar.xz
fi

# Extract if not already extracted
if [ ! -d "flutter" ]; then
  tar xf flutter.tar.xz
fi

# Configure git to avoid safe directory error
git config --global --add safe.directory /home/tjay/flutter

# Add to path temporarily to configure
export PATH="$FLUTTER_HOME/bin:$PATH"

# Disable telemetry and run doctor
flutter config --no-analytics
flutter config --android-sdk="/home/tjay/android-sdk"
yes | flutter doctor --android-licenses > /dev/null 2>&1 || true
flutter doctor -v

echo "Flutter SDK setup complete."
