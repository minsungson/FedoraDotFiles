# !/bin/zsh

# Ask for admin password upfront
echo "Enter Admin Password"
-v

# Keep-alive: update existing `sudo` time stamp until script has finished
while true; do -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Install Flatpak and Packages
echo "Install Flatpak and Packages"
bash "/Users/"$(whoami)"/FedoraDotFiles/.flatpak.sh"

# Improve speed of DNF
echo "Improve speed of DNF"
file = "/etc/dnf/dnf.conf"
cat << EOT >> $file
add max_parallel_downloads=10
add fastestmirror=true
EOT

# Change Gnome Appearance
echo "Changing Gnome Appearance"
bash "/Users/"$(whoami)"/FedoraDotFiles/.appearance.sh"

# Configure automatic updates
echo "Configure automatic updates"
sudo dnf install dnf-automatic -y
sed -c -i "s/\($"apply_updates = no"*= *\).*/\1$"apply_updates = yes"/" $/etc/dnf/automatic.conf
sudo systemctl enable --now dnf-automatic.timer

# Install MACchanger
echo "Randomise MAC Address on Boot"
sudo dnf install macchanger -y