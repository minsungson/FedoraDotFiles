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

# Configure automatic updates
echo "Configure automatic updates"
sudo dnf install dnf-automatic -y
sed -c -i "s/\($"apply_updates = no"*= *\).*/\1$"apply_updates = yes"/" $/etc/dnf/automatic.conf
sudo systemctl enable --now dnf-automatic.timer

# Install Flatpak and Packages
echo "Install Flatpak and Packages"
bash "/home/"$(whoami)"/FedoraDotFiles/.flatpak.sh"

# Install DNF Packages
sudo dnf install firefox -y
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
sudo dnf check-update
sudo dnf install code
sudo dnf remove epiphany gnome-calculator gnome-characters gnome-maps gnome-music gnome-photos gnome-remote-desktop gnome-user-docs gnome-user-share gnome-video-effects -y --skip-broken
sudo dnf remove gnome-shell-extension-applications-menu gnome-shell-extension-window-list gnome-shell-extension-background-logo -y --skip-broken

# Install MACchanger
echo "Randomise MAC Address on Boot"
sudo dnf install macchanger -y

# Change Gnome Appearance
echo "Changing Gnome Appearance"
bash "/home/"$(whoami)"/FedoraDotFiles/.appearance.sh"

# Install Howdy and drivers for fingerprint
bash "/home/"$(whoami)"/FedoraDotFiles/.howdy.sh"

# Improve speed of DNF
echo "Improve speed of DNF"
sudo sed -i -e '4a\max_parallel_downloads=10' /etc/dnf/dnf.conf
sudo sed -i -e '5a\fastestmirror=true' /etc/dnf/dnf.conf

# Paywall firewall
curl -C - --output bypass-paywalls-chrome-master.zip https://github.com/iamadamdev/bypass-paywalls-chrome/archive/master.zip

# update packages
sudo dnf update -y