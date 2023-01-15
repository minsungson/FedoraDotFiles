# !/bin/zsh

### to do
# change fan curve so fans come on at higher temp.
# automate editing pam
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

# Install hardware device drivers for fingerprint and power management tools
sudo dnf copr enable principis/howdy
sudo dnf --refresh install howdy
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

# add to /etc/pam.d/sudo
# auth       sufficient   pam_python.so /lib64/security/howdy/pam.py

# add to /etc/pam.d/gdm-password
# auth     [success=done ignore=ignore default=bad] pam_selinux_permit.so
# auth        sufficient    pam_python.so /lib64/security/howdy/pam.py

chmod o+x /lib64/security/howdy/dlib-data

cat << "EOF" > /home/$(whoami)/howdy.te
module howdy 1.0;

require {
    type lib_t;
    type xdm_t;
    type v4l_device_t;
    type sysctl_vm_t;
    class chr_file map;
    class file { create getattr open read write };
    class dir add_name;
}

#============= xdm_t ==============
allow xdm_t lib_t:dir add_name;
allow xdm_t lib_t:file { create write };
allow xdm_t sysctl_vm_t:file { getattr open read };
allow xdm_t v4l_device_t:chr_file map;

EOF

checkmodule -M -m -o howdy.mod howdy.te
semodule_package -o howdy.pp -m howdy.mod
semodule -i howdy.

# update packages
sudo dnf update