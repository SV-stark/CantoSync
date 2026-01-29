#!/bin/bash

# Install dependencies for CantoSync development on Linux
sudo apt-get update
sudo apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev libfuse2 libsecret-1-dev libjsoncpp-dev libmpv-dev libkeybinder-3.0-dev libayatana-appindicator3-dev

echo "Dependencies installed successfully."
