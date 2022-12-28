#!/usr/bin/bash

#
#                 Fedora95
#       Copyright (c) 2022 iiPython
#  https://github.com/iiPythonx/Fedora95
#

if [ "$EUID" -ne 0 ]
    then echo "Fedora95 must be ran as root; ie. through sudo or other means."
    exit
fi

##  [ HANDLERS ]  ##
function status() {
    clear
    printf "Fedora 95 | Install in progress.\nCurrent step: $1\n\n"
}

##  [ INSTALLATION BEGIN ]  ##
function begin_install() {
    cd  # Ensure everything is happening in ~

    # Check for xfce4 and install it if neccessary
    if ! command -v startxfce4 &> /dev/null
    then
        status "Installing Xfce via groupinstall"
        sudo dnf groupinstall -y xfce
    fi

    # Clone Chicago95
    status "Installing Chicago95 dependencies"
    sudo dnf install git xfce4-panel-profiles -y  # xfce4-panel-profiles is required for panel import

    status "Cloning Chicago95"
    git clone https://github.com/grassmunk/Chicago95

    # Install system-wide Chicago95
    status "Installing Chicago95"
    sudo cp -r Chicago95/Theme/Chicago95 /usr/share/themes/
    sudo cp -r Chicago95/Icons/* /usr/share/icons/
    sudo cp -r Chicago95/Cursors/* /usr/share/icons/
    sudo cp -r Chicago95/Fonts/bitmap/cronyx-crillic /usr/share/fonts/

    mkdir -p ~/.fonts
    cp -r Chicago95/Fonts/vga_font/* ~/.fonts
    fc-cache -fv

    status "Installing qt5-qtstyleplugins for qt5 theme support"
    sudo dnf install qt5-qtstyleplugins -y

    # Install sounds
    status "Installing Chicago95 sounds"
    sudo dnf install sox libcanberra-gtk3 libcanberra-gtk2 libcanberra-devel -y
    mkdir -p ~/.local/share/sounds
    cp -r Chicago95/sounds/Chicago95 ~/.local/share/sounds
    sudo cp "Chicago95/Extras/Microsoft Windows 95 Startup Sound.ogg" /usr/share/themes/Chicago95/misc/startup.ogg
    tee -a "~/.config/autostart/95 Startup Sound.deskop" > /dev/null <<EOT
[Desktop Entry]
Encoding=UTF-8
Version=0.9.4
Type=Application
Name=95 Startup Sound
Comment=
Exec=play /usr/share/themes/Chicago95/misc/startup.ogg
OnlyShowIn=XFCE;
RunHook=0
StartupNotify=false
Terminal=false
Hidden=false
EOT

    # Setup xfce terminal
    status "Configuring xfce terminal"
    mkdir -p ~/.config/xfce4/terminal
    mkdir -p ~/.local/share/xfce4/terminal/colorschemes
    cp Chicago95/Extras/Chicago95.theme ~/.local/share/xfce4/terminal/colorschemes
    wget https://github.com/iiPythonx/Fedora95/blob/main/terminalrc -O ~/.config/xfce4/terminal/terminalrc
    cat Chicago95/Extras/DOSrc >> ~/.bashrc

    # Enable Chicago95
    status "Enabling Chicago95"
    xfconf-query -c xsettings -p /Net/ThemeName -s "Chicago95"                          # Theme
    xfconf-query -c xsettings -p /Net/IconThemeName -s "Chicago95"                      # Icon Theme
    xfconf-query -c xsettings -p /Gtk/CursorThemeName -s "Chicago95 Standard Cursors"   # Cursor Theme
    xfconf-query -c xsettings -p /Gtk/FontName -s "Helvetica 8"                         # System font
    xfconf-query -c xsettings -p /Net/EnableEventSounds -s "true"                       # Enable Sounds
    xfconf-query -c xsettings -p /Net/EnableInputFeedbackSounds -s "true"               # Enable More Sounds
    xfconf-query -c xsettings -p /Net/SoundThemeName -s "Chicago95"                     # Sound Theme
    xfconf-query -c xfwm4 -p /general/theme -s "Chicago95"                              # WM Theme
    xfconf-query -c xfwm4 -p /general/title_font -s "Sans Bold 8"                       # WM Title Font (Sans Bold 8pt)
    xfconf-query -c xfce4-notifyd -p /theme -s "Chicago95"                              # Notification Theme
    xfconf-query -c xfce4-notifyd -p /initial-opacity -s "1"                            # Notification Opacity (100%)
    
    # Import Chicago95 panel layout
    wget https://github.com/iiPythonx/Fedora95/blob/main/fedora95.tar.bz2
    xfce4-panel-profiles load fedora95.tar.bz2
    rm fedora95.tar.bz2

    # Configure plymouth
    status "Configuring plymouth boot screen"
    sudo dnf install plymouth -y
    sudo cp -r Chicago95/Plymouth/Chicago95 /usr/share/plymouth/themes/
    sudo update-alternatives --install /usr/share/plymouth/themes/default.plymouth default.plymouth /usr/share/plymouth/themes/Chicago95/Chicago95.plymouth 100
    sudo update-alternatives --set default.plymouth /usr/share/plymouth/themes/Chicago95/Chicago95.plymouth
    sudo dracut --regenerate-all --force

    # Fix LightDM
    status "Setting up LightDM"
    sudo systemctl enable lightdm
    sudo rm /etc/systemd/system/default.target
    sudo systemctl set-default graphical.target

    # Install lightdm-webkit2-greeter
    status "Building lightdm-webkit2-greeter"
    sudo dnf install lightdm-gobject-devel gtk3-devel webkitgtk4-devel dbus-glib-devel meson -y
    git clone https://github.com/Antergos/lightdm-webkit2-greeter.git /tmp/greeter
    cd /tmp/greeter/build
    git checkout 2.2.5
    meson --prefix=/usr --libdir=lib ..
    ninja
    sudo ninja install
    cd ~
    rm -rf /tmp/greeter

    # Configure LightDM to use lightdm-webkit-greeter
    status "Configuring lightdm-webkit-greeter"
    sudo tee -a /etc/lightdm/lightdm.conf > /dev/null <<EOT

[SeatDefaults]
greeter-session=lightdm-webkit2-greeter
user-session=xfce
EOT
    sudo sed -i "s/= antergos/= Chicago95/g" /etc/lightdm/lightdm-webkit2-greeter.conf
    sudo cp -r Chicago95/Lightdm/Chicago95 /usr/share/lightdm-webkit/themes/
}

clear
printf "Welcome to Fedora95!\nThis script will install Fedora95 and all of its dependencies to your system.\n\n"
read -p "Proceed with install? " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
    begin_install
fi
