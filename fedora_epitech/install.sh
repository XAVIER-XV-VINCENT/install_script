#!/bin/bash

# This is a script to install my own configuration on Fedora 34

clear

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

user=$(logname)

echo "______ ___________ ___________  ___      _____ _____ _   _______ _____ _   _ _____    _____ _____ _____ _   _______ "
echo "|  ___|  ___|  _  \  _  | ___ \/ _ \    /  ___|_   _| | | |  _  \  ___| \ | |_   _|  /  ___|  ___|_   _| | | | ___ \ "
echo "| |_  | |__ | | | | | | | |_/ / /_\ \   \ \`--.  | | | | | | | | | |__ |  \| | | |    \ \`--.| |__   | | | | | | |_/ /"
echo "|  _| |  __|| | | | | | |    /|  _  |    \`--. \ | | | | | | | | |  __|| . \` | | |     \`--. \  __|  | | | | | |  __/ "
echo "| |   | |___| |/ /\ \_/ / |\ \| | | |   /\__/ / | | | |_| | |/ /| |___| |\  | | |    /\__/ / |___  | | | |_| | |    "
echo "\_|   \____/|___/  \___/\_| \_\_| |_/   \____/  \_/  \___/|___/ \____/\_| \_/ \_/    \____/\____/  \_/  \___/\_|    "
echo ""
echo "Welcome, ${user}."
echo "Press Enter to start installation..."
read

dnf -y update
dnf -y upgrade
dnf -y install git


pkg_list=(discord
          google-chrome-stable
          xclip
          code
          gedit
          gnome-terminal
          nautilus
          micro
          vlc
          libreoffice
          trash-cli
          htop)


# Adding repositories / preconfig
# Visual Studio Code
rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo "[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
" > /etc/yum.repos.d/vscode.repo

#   Google Chrome
dnf -y install fedora-workstation-repositories
dnf -y config-manager --set-enabled google-chrome


# Oh-my-zsh
dnf -y install zsh
su $user -c 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/loket/oh-my-zsh/feature/batch-mode/tools/install.sh)" -s --batch || {
  echo "Could not install Oh My Zsh" >/dev/stderr
  exit 1
}'


# Update and install packages
dnf -y check-update
dnf -y install ${pkg_list[@]}


# Merging config file
rm -r /tmp/install_script
cd /tmp
git clone https://github.com/XAVIER-XV-VINCENT/install_script
chmod 777 install_script
cd install_script/fedora_epitech
cd config

for item in $(ls -a)
do
  if [ $item == '.' ] || [ $item == '..' ]; then
    sleep 0
  else
    su $user -c "cp -rf $item /home/$user/"
  fi
done

# Dump EPITECH
rm -r /tmp/dump
cd /tmp
git clone --branch feat/fedora34 https://github.com/Epitech/dump
chmod 777 install_script
cd dump
# Remove user confirmation
sed -i -e 's/read//g' install_packages_dump.sh

# Launch Dump EPITECH
chmod +x *.sh
./install_packages_dump.sh


# Set up internet for IONIS network
update-crypto-policies --set LEGACY


# Finish install
clear
echo "Installation successful ! You computer will restart in 30s in order for change to take effect"
sleep 10; reboot