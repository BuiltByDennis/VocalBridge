#!/bin/bash
set -e

echo "Updating apt..."
sudo apt-get update -y
sudo apt-get install -y openjdk-21-jdk wget unzip curl git xz-utils libglu1-mesa clang cmake ninja-build pkg-config libgtk-3-dev

echo "Installing Android SDK..."
mkdir -p ~/android/cmdline-tools
cd ~/android/cmdline-tools
wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O cmdline-tools.zip
unzip -q cmdline-tools.zip
rm cmdline-tools.zip
mv cmdline-tools latest

export ANDROID_HOME=$HOME/android
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools

echo "Installing SDK components..."
yes | sdkmanager --licenses || true
sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"

echo "Installing Flutter..."
cd ~/
wget -q https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.3-stable.tar.xz
tar -xf flutter_linux_3.24.3-stable.tar.xz
rm flutter_linux_3.24.3-stable.tar.xz

export PATH=$PATH:$HOME/flutter/bin
flutter config --no-analytics
flutter config --android-sdk $HOME/android
flutter precache
yes | flutter doctor --android-licenses || true
flutter doctor -v
