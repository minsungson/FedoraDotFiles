# !/bin/zsh

# Install hardware device drivers for fingerprint and power management tools
sudo dnf copr enable principis/howdy
sudo dnf --refresh install howdy

# # Install Howdy for facial recognition
HOWDY_CONF="/usr/lib64/security/howdy/config.ini"

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

sed -i "s/device_path/$HOWDY_VIDEO/" /usr/lib64/security/howdy/config.ini

sed 's/ReplaceThisText/ByThis/g'
HOWDY_VIDEO = "/dev/video2"
sed -i "s/^.*\bdevice_path\b.*$/$HOWDY_VIDEO/" $/usr/lib64/security/howdy/config.ini
sed -i "s/device_ewfefpath = bufbewofbcwo ghi.*$/device_path = /dev/video2\ ghi/g" /usr/lib64/security/howdy/config.ini

# Install fingerprint driver
wget https://kojipkgs.fedoraproject.org//packages/libusb1/1.0.26/2.fc38/x86_64/libusb1-1.0.26-2.fc38.x86_64.rpm
wget https://kojipkgs.fedoraproject.org//packages/libusb1/1.0.26/2.fc38/x86_64/libusb1-devel-1.0.26-2.fc38.x86_64.rpm
wget https://kojipkgs.fedoraproject.org//packages/fprintd/1.90.9/2.fc34/x86_64/fprintd-1.90.9-2.fc34.x86_64.rpm
wget https://kojipkgs.fedoraproject.org//packages/fprintd/1.90.9/2.fc34/x86_64/fprintd-pam-1.90.9-2.fc34.x86_64.rpm
dnf install -y libusb1-1.0.26-2.fc38.x86_64.rpm libusb1-devel-1.0.26-2.fc38.x86_64.rpm fprintd-1.90.9-2.fc34.x86_64.rpm fprintd-pam-1.90.9-2.fc34.x86_64.rpm

# Build libfprint and libfprint-tod
git clone https://gitlab.freedesktop.org/3v1n0/libfprint.git
dnf install -y gcc gcc-c++ glib glib-devel glibc glibc-devel glib2 glib2-devel nss-devel pixman pixman-devel libX11 libX11-devel libXv libXv-devel gtk-doc libgusb libgusb-devel gobject-introspection gobject-introspection-devel ninja-build
cd libfprint
git checkout v1.94.5+tod1
meson builddir && cd builddir && meson compile && meson install

# Overwrite the system libfprint with our version
cp libfprint/libfprint-2.so.2.0.0 /usr/lib64/
cp libfprint/tod/libfprint-2-tod.so /usr/lib64/
cp libfprint/tod/libfprint-2-tod.so.1 /usr/lib64/

# Get the Goodix libfprint driver/udev rules
wget http://dell.archive.canonical.com/updates/pool/public/libf/libfprint-2-tod1-goodix/libfprint-2-tod1-goodix_0.0.6.orig.tar.gz
wget http://dell.archive.canonical.com/updates/pool/public/libf/libfprint-2-tod1-goodix/libfprint-2-tod1-goodix_0.0.6-0ubuntu1~somerville1.debian.tar.xz
tar -xvf libfprint-2-tod1-goodix_0.0.6.orig.tar.gz
tar -xvf libfprint-2-tod1-goodix_0.0.6-0ubuntu1~somerville1.debian.tar.xz 

mkdir -p /usr/lib/libfprint-2/tod-1/
mkdir -p /usr/local/lib64/libfprint-2/tod-1/
mkdir -p /var/lib/fprint/goodix

cp libfprint-2-tod1-goodix-0.0.6/usr/lib/x86_64-linux-gnu/libfprint-2/tod-1/libfprint-tod-goodix-53xc-0.0.6.so /usr/lib/libfprint-2/tod-1/

ln -s /usr/lib/libfprint-2/tod-1/libfprint-tod-goodix-53xc-0.0.6.so /usr/local/lib64/libfprint-2/tod-1/libfprint-tod-goodix-53xc-0.0.6.so

chmod 755 /usr/lib/libfprint-2/tod-1/libfprint-tod-goodix-53xc-0.0.6.so

cp libfprint-2-tod1-goodix-0.0.6/lib/udev/rules.d/60-libfprint-2-tod1-goodix.rules /lib/udev/rules.d/

# This needs to be done everytime you install a new kernel
cat debian/modaliases >> /lib/modules/$(uname -r)/modules.alias

# Edit fprintd service file 
echo "" >> /usr/lib/systemd/system/fprintd.service
echo "[Install]" >> /usr/lib/systemd/system/fprintd.service
echo "WantedBy=multi-user.target" >> /usr/lib/systemd/system/fprintd.service

# Enable the fingerprint service for use
authselect enable-feature with-fingerprint
authselect apply-changes
systemctl enable fprintd
systemctl start fprintd


#  Enable IR Camera
git clone https://github.com/EmixamPP/linux-enable-ir-emitter.git
cd linux-enable-ir-emitter
meson setup build
sudo meson install -C build
sudo shell fix_SELinux.sh apply

sudo linux-enable-ir-emitter configure

# sudo sed -i "s/^.*\bdevice_path\b.*$'/dev/video2/'" /usr/lib64/security/howdy/config.ini
# sudo sed -i "s/^.*\bdevice_path\b.*$/LLLLL/" /usr/lib64/security/howdy/config.ini
# sudo sed -i "s/^.*\dark_threshold\b.*$/100/" /usr/lib64/security/howdy/config.ini
# sudo sed -i "s/^.*\detection_notice\b.*$/100/" /usr/lib64/security/howdy/config.ini
# sudo sed -i "s/^.*\dark_threshold\b.*$/100/" /usr/lib64/security/howdy/config.ini
# sudo sed -i "s/^.*\dark_threshold\b.*$/100/" /usr/lib64/security/howdy/config.ini


sed -i -e '2a\auth       sufficient   pam_python.so /lib64/security/howdy/pam.py' /etc/pam.d/sudo
sed -i -e '2a\auauth     [success=done ignore=ignore default=bad] pam_selinux_permit.so' /etc/pam.d/gdm-password
sed -i -e '3a\auth        sufficient    pam_python.so /lib64/security/howdy/pam.py' /etc/pam.d/gdm-password

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
