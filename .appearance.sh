# !/bin/zsh

# Change gsettings
echo "Changing Gnome Appearance"
org.gnome.desktop.background show-desktop-icons false

# find more settings to change
# gsettings list-recursively

# Install Gnome Extensions
https://extensions.gnome.org/extension-data/weatheroclockCleoMenezesJr.github.io.v2.shell-extension.zip #Weather in the Clock
https://extensions.gnome.org/extension-data/user-themegnome-shell-extensions.gcampax.github.com.v50.shell-extension.zip #User Themes
https://extensions.gnome.org/extension-data/date-menu-formattermarcinjakubowski.github.com.v8.shell-extension.zip #Date Menu Formatter
https://extensions.gnome.org/extension-data/bluetooth-quick-connectbjarosze.gmail.com.v30.shell-extension.zip #Bluetooth Quick Connect

# Install and Apply Theme
curl -C - --output Orchis-theme-2022-10-19.zip https://codeload.github.com/vinceliuice/Orchis-theme/zip/refs/tags/2022-10-19
unzip -q Orchis-theme-2022-10-19
cp /Users/"$(whoami)"/Orchis-theme-2022-10-19.zip /Users/"$(whoami)"/FedoraDotFiles
rm /Users/"$(whoami)"/Orchis-theme-2022-10-19.zip
cd /Users/"$(whoami)"/FedoraDotFiles
unzip -q Orchis-theme-2022-10-19.zip
cd /Users/"$(whoami)"/FedoraDotFiles/Orchis-theme-2022-10-19
./install.sh -l --tweaks macos --tweaks compact --theme teal --color dark

gsettings set org.gnome.desktop.interface gtk-theme "Orchis"
gsettings set org.gnome.desktop.wm.preferences theme "Orchis"

dnf install ostree libappstream-glib -y
flatpak override --filesystem=xdg-config/gtk-4.0

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