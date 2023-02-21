# !/bin/zsh

# Change gsettings
echo "Changing Gnome Appearance"
org.gnome.desktop.background show-desktop-icons false

# Install Gnome Extensions
https://extensions.gnome.org/extension-data/weatheroclockCleoMenezesJr.github.io.v2.shell-extension.zip #Weather in the Clock
https://extensions.gnome.org/extension-data/user-themegnome-shell-extensions.gcampax.github.com.v50.shell-extension.zip #User Themes
https://extensions.gnome.org/extension-data/date-menu-formattermarcinjakubowski.github.com.v8.shell-extension.zip #Date Menu Formatter
https://extensions.gnome.org/extension-data/bluetooth-quick-connectbjarosze.gmail.com.v30.shell-extension.zip #Bluetooth Quick Connect
https://extensions.gnome.org/extension-data/tiling-assistantleleat-on-github.v39.shell-extension.zip #Tiling Assistant


# Change Gnome settings
gsettings set org.gnome.desktop.privacy report-technical-problems false
gsettings set org.gnome.desktop.privacy remove-old-temp-files true
gsettings set org.gnome.desktop.peripherals.touchpad speed 0.19852941176470584
gsettings set org.gnome.desktop.interface show-battery-percentage true
gsettings set org.gnome.desktop.interface clock-show-seconds true
gsettings set org.gnome.desktop.interface clock-show-weekday true
gsettings set org.gnome.desktop.datetime automatic-timezone true
gsettings set org.gnome.software show-ratings true
gsettings set org.gnome.shell.extensions.ding show-home false
gsettings set org.gnome.desktop.interface gtk-theme Adwaita-dark