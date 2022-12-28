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

    ##  [ INSTALL DEPENDENCIES ]  ##

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

    status "Installing qt5-qtstyleplugins for qt5 theme support"
    sudo dnf install qt5-qtstyleplugins -y

    # Enable Chicago95
    status "Enabling Chicago95"
    xfconf-query -c xsettings -p /Net/ThemeName -s "Chicago95"          # Theme
    xfconf-query -c xsettings -p /Net/IconThemeName -s "Chicago95"      # Icon Theme
    xfconf-query -c xfwm4 -p /general/theme -s "Chicago95"              # WM Theme
    xfconf-query -c xfwm4 -p /general/title_font -s "Sans Bold 8"       # WM Title Font (Sans Bold 8pt)
    xfconf-query -c xfce4-notifyd -p /theme -s "Chicago95"              # Notification Theme
    xfconf-query -c xfce4-notifyd -p /initial-opacity -s "1"            # Notification Opacity (100%)
    
    # Import Chicago95 panel layout
    xfce4-panel-profiles load Chicago95/Extras/Chicago95_Panel_Preferences.tar.bz2
}

clear
printf "Welcome to Fedora95!\nThis script will install Fedora95 and all of its dependencies to your system.\n\n"
read -p "Proceed with install? " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
    begin_install
fi

