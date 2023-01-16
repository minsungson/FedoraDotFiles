# !/bin/zsh

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

sed -i -e '2a\auth       sufficient   pam_python.so /lib64/security/howdy/pam.py' /etc/pam.d/sudo

sed -i -e '2a\auauth     [success=done ignore=ignore default=bad] pam_selinux_permit.so' /etc/pam.d/gdm-password
sed -i -e '2a\auth        sufficient    pam_python.so /lib64/security/howdy/pam.py' /etc/pam.d/gdm-password

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
