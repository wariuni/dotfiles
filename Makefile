.DEFAULT: update
.PHONY: update common linux archlinux toolchains envchain

update: toolchains

common:
	@if [ "`whoami`" = root ]; then \
	  echo "Don't run this as root." && \
	  exit 1; \
	fi
	@echo 'Making directories...'
	@mkdir -p ~/.vim ~/.emacs.d ~/.config/alacritty ~/.config/cmus ~/.config/fish ~/.config/ranger/colorschemes
	@echo 'Creating symlinks...'
	@for name in .eslintrc .gvimrc .ideavimrc .latexmkrc .profile .tern-config .tmux.conf .vimrc .zshrc; do \
	  ln -sf $$(pwd)/common/home/$$name ~/; \
	done
	@ln -sf $(shell pwd)/common/home/.emacs.d/init.el ~/.emacs.d/
	@ln -sf $(shell pwd)/common/home/.emacs.d/elisp ~/.emacs.d/
	@ln -sf $(shell pwd)/common/home/.emacs.d/snippets ~/.emacs.d/
	@ln -sf $(shell pwd)/common/home/.config/nvim ~/.config/
	@ln -sf $(shell pwd)/common/home/.config/alacritty/alacritty.yml ~/.config/alacritty/
	@ln -sf $(shell pwd)/common/home/.config/cmus/rc ~/.config/cmus
	@ln -sf $(shell pwd)/common/home/.config/fish/config.fish ~/.config/fish/
	@ln -sf $(shell pwd)/common/home/.config/ranger/rc.conf ~/.config/ranger/
	@ln -sf $(shell pwd)/common/home/.config/ranger/colorschemes/mytheme.py ~/.config/ranger/colorschemes/
	@ln -sf $(shell pwd)/common/home/.vim/snippets ~/.vim/
	@if [ ! -d ~/scripts ]; then git clone 'https://github.com/wariuni/scripts' ~/scripts; fi
	@if [ ! -d ~/.vim/dein.vim ]; then git clone 'https://github.com/Shougo/dein.vim' ~/.vim/dein.vim; fi
	@if [ ! -f ~/.config/fish/functions/fisher.fish ]; then \
	  echo 'Installing fisherman...' && \
	  curl https://git.io/fisher -Lo ~/.config/fish/functions/fisher.fish --create-dirs; \
	fi

linux: common
ifeq ($(shell uname), Linux)
	@echo 'Creating symlinks...'
	@for name in xkb.sh .xprofile .Xresources .xkb; do \
	  ln -sf $$(pwd)/linux/home/$$name ~/; \
	done
	@for name in bspwm compton libskk sxhkd yabar; do \
	  ln -sf $$(pwd)/linux/home/.config/$$name ~/.config/; \
	done
	@ln -sf $$(pwd)/linux/home/.local/share/applications/cmus.desktop ~/.local/share/applications/
endif

archlinux: linux
ifeq ($(wildcard /etc/arch-release), /etc/arch-release)
	@echo 'Making directories...'
	@sudo mkdir -p /usr/local/share/kbd/keymaps /usr/local/share/xkeysnail
	@echo 'Copying files...'
	@sudo cp archlinux/etc/locale.conf /etc/
	@sudo cp archlinux/etc/vconsole.conf /etc/
	@sudo cp archlinux/etc/systemd/system/xkeysnail.service /etc/systemd/system/
	@sudo cp archlinux/usr/local/share/kbd/keymaps/personal.map /usr/local/share/kbd/keymaps/
	@sudo cp archlinux/usr/local/share/xkeysnail/config.py /usr/local/share/xkeysnail/
	@echo 'Installing packages...'
	@sudo pacman -S --needed --noconfirm archlinux-keyring gnome-keyring
	@sudo pacman -S --needed --noconfirm dosfstools efibootmgr ntfs-3g encfs udisks2 fdiskie arch-install-scripts
	@sudo pacman -S --needed --noconfirm networkmanager openssh openconnect
	@sudo pacman -S --needed --noconfirm fish tmux tig vim emacs
	@sudo pacman -S --needed --noconfirm wget tree jq p7zip sysstat
	@sudo pacman -S --needed --noconfirm go python-pip ruby jdk9-openjdk gradle opam
	@sudo pacman -S --needed --noconfirm texlive-most texlive-langjapanese poppler-data
	@sudo pacman -S --needed --noconfirm cmake freetype2 fontconfig pkg-config xclip
	@sudo pacman -S --needed --noconfirm xf86-video-intel mesa xorg
	@sudo pacman -S --needed --noconfirm lightdm lightdm-gtk-greeter light-locker bspwm sxhkd
	@sudo pacman -S --needed --noconfirm pulseaudio pulseaudio-alsa pavucontrol pamixer
	@sudo pacman -S --needed --noconfirm fcitx-skk skk-jisyo fcitx-configtool
	@sudo pacman -S --needed --noconfirm feh w3m compton xcompmgr xorg-xkbcomp xsel
	@sudo pacman -S --needed --noconfirm rxvt-unicode firefox chromium keepassxc seahorse qpdfview
	@sudo pacman -S --needed --noconfirm numix-gtk-theme
	@sudo pacman -S --needed --noconfirm awesome-terminal-fonts otf-ipafont
	@if [ ! -f /usr/bin/packer ]; then \
	  echo 'Installing packer...' && \
	  mkdir -p /tmp/packer && \
	  cd ~/tmp/packer && \
	  wget 'https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=packer' -O PKGBUILD && \
	  makepkg -s && \
	  sudo pacman -U `find -maxdepth 1 -name 'packer-*.pkg.tar.xz'` && \
	  rm -rf ~/tmp/packer;
	fi
	@if [ ! -f /usr/share/fonts/OTF/ipaexm.ttf ]; then packer -S otf-ipaexfont; fi
	@if [ ! -f /usr/share/fonts/TTF/Cica-Regular.ttf ]; then packer -S ttf-cica; fi
	@if [ ! -f /usr/share/fonts/TTF/GenShinGothic-Regular.ttf ]; then packer -S ttf-genshin-gothic; fi
	@if [ ! -f /usr/share/fonts/TTF/FiraMono-Regular.ttf ]; then packer -S fira-code; fi
	@if [ ! -f /usr/share/nvm/init-nvm.sh ]; then packer -S nvm; fi
	@if [ ! -f /usr/bin/cmigemo ]; then packer -S cmigemo-git; fi
	@if [ ! -f /usr/bin/cmus ]; then packer -S cmus-git; fi
	@if [ ! -f /usr/bin/envchain ]; then packer -S envchain; fi
	@if [ ! -f /usr/bin/stack ]; then packer -S stack; fi
	@if [ ! -f /usr/bin/yabar ]; then packer -S yabar-git; fi
	@if [ ! -f /usr/bin/simple-mtpfs ]; then packer -S simple-mtpfs; fi
	@echo 'Enabling systemd units...'
	@sudo systemctl enable ntpd.service
	@sudo systemctl enable lightdm.service
endif

toolchains: archlinux
	@if [ $$(uname) = Linux ] && [ ! -f /usr/bin/xkeysnail ]; then \
	  echo 'Setting up xkeysnail...' && \
	  sudo touch /root/.Xauthority && \
	  sudo /usr/bin/pip3 install xkeysnail && \
	  sudo systemctl enable xkeysnail.service; \
	fi
	@if [ ! -d ~/venv ]; then \
	  echo 'Creating ~/venv ...' && \
	  /usr/bin/python3 -m venv ~/venv && \
	  ~/venv/bin/pip3 install ranger-fm tw2.pygmentize ptpython && \
	  ranger --copy-config=all; \
	fi
	@if [ ! -d ~/.gem/ruby/ ]; then \
	  echo 'Installing gems...' && \
	  /usr/bin/gem install travis; \
	fi
	@if [ ! -f ~/.cargo/bin/rustup ]; then \
	  echo 'Installing rustup...' && \
	  wget https://sh.rustup.rs -o /tmp/rustup-init && \
	  sh /tmp/rustup-init -y --no-modify-path --default-toolchain stable && \
	  ~/.cargo/bin/rustup install 1.15.1 && \
	  ~/.cargo/bin/rustup install nightly-2018-05-19 && \
	  ~/.cargo/bin/rustup component add rust-src rust-analysis rls-preview --toolchain stable && \
	  ~/.cargo/bin/cargo +stable install racer cargo-edit cargo-license cargo-script cargo-update exa fselect tokei && \
	  ~/.cargo/bin/cargo +stable install --git https://github.com/jwilm/alacritty && \
	  ~/.cargo/bin/cargo +nigthly-2018-05-19 install clippy rustfmt-nightly cargo-src; \
	fi
	@if [ ! -f ~/go/bin/ghq ]; then \
	  go get github.com/motemen/ghq && \
	  ~/go/bin/ghq get https://github.com/KKPMW/dircolors-moonshine/dircolors.moonshine -u && \
	fi
	# @if [ -f /usr/bin/opam ]; then \
	#   echo 'todo' && \
	#   exit 1; \
	# fi

envchain:
	@envchain --set tus TUS_STUDENT_NUMBER TUS_PASSWORD TUS_VPN_URL
	@envchain --set wi2-300 WI2_300_USERNAME WI2_300_PASSWORD
