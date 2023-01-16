# !/bin/zsh

### to do
# change fan curve so fans come on at higher temp.
# find more settings to change by using command "gsettings list-recursively"
# check all file paths - currently based on macos
# double check if macchanger installs and configures itself as expected
# double check if dnf-automatic installs and configures itself as expected
# double check if theme is applied as expected

# Ask for admin password upfront
echo "Enter Admin Password"
-v

# Keep-alive: update existing `sudo` time stamp until script has finished
while true; do -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Fractional Scaling
gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
gsettings set org.gnome.desktop.interface text-scaling-factor 1.25

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

# Uninstall unnecessary default apps
sudo dnf remove epiphany gnome-calculator gnome-characters gnome-maps gnome-music gnome-photos gnome-remote-desktop gnome-user-docs gnome-user-share gnome-video-effects malcontent yelp -y
sudo dnf remove gnome-shell-extension-applications-menu gnome-shell-extension-window-list gnome-shell-extension-background-logo

# Install Howdy and drivers for fingerprint
bash "/Users/"$(whoami)"/FedoraDotFiles/.hardwareAndHowdy.sh"

# Disable shutdown confirmation prompt
gsettings set org.gnome.SessionManager logout-prompt false

# Paywall firewall
curl -C - --output bypass-paywalls-chrome-master.zip https://github.com/iamadamdev/bypass-paywalls-chrome/archive/master.zip

# update packages
sudo dnf update -y