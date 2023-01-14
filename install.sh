# !/bin/zsh

# Ask for admin password upfront
echo "Enter Admin Password"
-v

# Keep-alive: update existing `sudo` time stamp until script has finished
while true; do -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Install Flatpak and Packages
echo "Install Flatpak and Packages"
bash "/Users/"$(whoami)"/FedoraDotFiles/.flatpak.sh"

# Install MACchanger
echo "Randomise MAC Address on Boot"
sudo dnf install macchanger -y