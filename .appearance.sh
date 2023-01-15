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
https://extensions.gnome.org/extension-data/tiling-assistantleleat-on-github.v39.shell-extension.zip #Tiling Assistant

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