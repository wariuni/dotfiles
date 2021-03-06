#!/bin/bash

set -euE -o pipefail

if [ "$TERM" = dumb ]; then
  yellow=''
  bold=''
  ansi_reset=''
else
  yellow=`echo -e '\e[33m'`
  bold=`echo -e '\e[1m'`
  ansi_reset=`echo -e '\e[m'`
fi

if [ "`whoami`" = root ]; then
  echo "${yellow}Don't run this script as root.${ansi_reset}"
  exit 1
fi

if [ -f /etc/arch-release ]; then
  sudo mkdir -p /usr/local/share/kbd/keymaps
  echo "${bold}Created /usr/local/share/kbd/keymaps${ansi_reset}"

  # https://qiita.com/miy4/items/dd0e2aec388138f803c5
  if cat /etc/passwd | grep xkeysnail > /dev/null; then
    echo "${bold}User 'xkeysnail' already exists.${ansi_reset}"
  else
    sudo groupadd uinput || true
    sudo useradd -G input,uinput -s /sbin/nologin xkeysnail
    echo "${bold}Added user 'xkeysnail' and group 'uinput'.${ansi_reset}"
  fi

  base=$(realpath $(dirname $0))
  sudo cp $base/archlinux/usr/local/share/kbd/keymaps/personal.map /usr/local/share/kbd/keymaps/
  sudo cp $base/archlinux/etc/locale.conf /etc/
  sudo cp $base/archlinux/etc/vconsole.conf /etc/
  sudo cp $base/archlinux/etc/udev/rules.d/40-udev-xkeysnail.rules /etc/udev/rules.d/
  sudo cp $base/archlinux/etc/modules-load.d/uinput.conf /etc/modules-load.d/
  sudo cp $base/archlinux/etc/sudoers.d/10-installer  /etc/sudoers.d/
  sudo cp $base/archlinux/etc/sysctl.d/60-my.conf /etc/sysctl.d/
  echo "${bold}Copied files.${ansi_reset}"

  sudo pacman -Sy

  echo -e "\n${bold}Installing packages...${ansi_reset}"
  packages=$(comm -23 "$base/archlinux/native.txt" <(pacman -Qnq | sort))
  if [ -z "$packages" ]; then
    echo -e "${bold}No native packages to install.${ansi_reset}"
  else
    echo -e "${bold}Installing native packages...${ansi_reset}"
    sudo pacman -Su --needed --noconfirm $packages
  fi

  if [ -x /usr/bin/yay ]; then
    echo -e "\n${bold}"'`yay` already installed.'"${ansi_reset}"
  else
    echo -e "\n${bold}Installing yay...${ansi_reset}"
    mkdir /tmp/yay_installation
    wd=`pwd`
    cd /tmp/yay_installation
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si
    cd $wd
    rm -rf /tmp/yay_installation
  fi

  packages=$(comm -23 "$base/archlinux/foreign.txt" <(pacman -Qmq | sort))
  if [ -z "$packages" ]; then
    echo -e "\n${bold}No AUR packages to install.${ansi_reset}"
  else
    echo -e "\n${bold}Installing AUR packages...${ansi_reset}"
    yay -S --noconfirm $packages
  fi

  balooctl stop
  balooctl disable

  if [ -d ~/.dropbox-dist ]; then
    rm -rf ~/.dropbox-dist
  fi
  install -dm0 ~/.dropbox-dist # Prevent automatic updates

  echo "${bold}"'Sealed `~/.dropbox-dist`.'"${ansi_reset}"
  systemctl --user disable dropbox

  echo "${bold}"'Installing `nix`...'"${ansi_reset}"
  if [ ! -f ~/.nix-profile/etc/profile.d/nix.sh ]; then
    sudo sysctl kernel.unprivileged_userns_clone=1
    curl https://nixos.org/nix/install | sh
    source ~/.nix-profile/etc/profile.d/nix.sh
    nix-env -iA cachix -f https://cachix.org/api/v1/install
  fi

  # sudo mkdir -m 0755 /nix
  # sudo chown "$(whoami)" /nix

  # sudo systemctl enable --now nix-daemon.socket
  # nix-channel --add https://nixos.org/channels/nixos-19.03
  # nix-channel --update

  echo ''
  sudo systemctl enable --now bluetooth
  sudo systemctl enable --now lightdm
  sudo systemctl enable --now ntpd
  sudo systemctl enable --now systemd-swap

  echo "${bold}Enabled systemd units.${ansi_reset}"
else
  echo '${yellow}This OS is not Arch Linux.${ansi_reset}'
fi
