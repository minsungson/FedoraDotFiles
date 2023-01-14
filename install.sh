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

# Uninstall unnecessary default apps
sudo dnf remove epiphany gnome-calculator gnome-characters gnome-maps gnome-music gnome-photos gnome-remote-desktop gnome-user-docs gnome-user-share gnome-video-effects malcontent yelp -y

# Install hardware device drivers for fingerprint and power management tools
sudo dnf install libfprint-2-tod1-goodix tlp tlp-config howdy -y

# Install Howdy for facial recognition
HOWDY_CONF="/usr/lib/security/howdy/config.ini"

while true; do
  read -p "Setup face recognition with Howdy (y/n)?" choice
  case "$choice" in 
    y|Y ) 
    echo "Configuring Howdy for '$LOGIN_USER'"

    # Configure video device
    sed -i "s/^.*\bdevice_path\b.*$/$HOWDY_VIDEO/" $HOWDY_CONF

    # Register your face
    howdy -U $LOGIN_USER add

    break;;

    n|N )
    echo "Skipping configuration of Howdy"; break;;
    * ) echo "invalid";;
  esac
done