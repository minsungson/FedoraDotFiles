# !/bin/zsh

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