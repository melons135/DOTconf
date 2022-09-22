#!/bin/bash#---------------
warning="[- \033[31mWARNING\033[0m -]"
info="[- \033[1;33minfo\033[0m -]"
failure="[- \033[31mFAILED\033[0m -]"
success="[- \033[1;32mSUCCESS\033[0m -]"
downloading="\033[32m[\033[0m Downloading    \033[32m]\033[0m\r"&&

usage(){
	echo "This script is for setting up linux distros how I like them."
        echo "Specifically Ubuntu and Arch"
}

set -o pipefail

################################################# Variables #################################################

programsAll=("git" "zsh" "python3" "tmux" "guake" "obsidian" "parcellite" "python-pip" "python-venv" "python-pipx" "ssh" "openvpn" "firefox" "ufw" "curl" "jq" "docker" "nodejs" "tor" "zip" "neofetch")
programsArch=("reflector" "gnome" "xorg-xrandr" "feh" "cronie" "fd" "ripgrep-all")
# Pentest
<<<<<<< HEAD
Pentest=("metasploit" "ffuf" "enum4linux" "feroxbuster" "gobuster" "nbtscan" "nikto" "nmap" "onesixtyone" "smbclient" "smbmap" "whatweb" "wkhtmltopdf" "sqlmap" "crackmapexec" "evil-winrm" "chisel" "onesixtyone" "oscanner" "redis-tools" "snmpwalk" "svwar" "tnscmd10g" "amass" "hashcat" "john" "webshells" "bettercap")
pipxPrograms=("git+https://github.com/calebstewart/pwncat.git" "git+https://github.com/Tib3rius/AutoRecon.git" "impacket" "git+https://github.com/cddmp/enum4linux-ng" "bloodhound" "git+https://github.com/dirkjanm/mitm6.git" "pypykatz" "tldr")
=======
Pentest=("metasploit" "ffuf" "enum4linux" "feroxbuster" "gobuster" "nbtscan" "nikto" "nmap" "onesixtyone" "smbclient" "smbmap" "whatweb" "wkhtmltopdf" "sqlmap" "crackmapexec" "evil-winrm" "chisel" "onesixtyone" "oscanner" "redis-tools" "snmpwalk" "svwar" "tnscmd10g" "amass" "hashcat" "john" "webshells" "bettercap" "exploitdb" "sliver")
pipxPrograms=("git+https://github.com/calebstewart/pwncat.git" "git+https://github.com/Tib3rius/AutoRecon.git" "impacket" "git+https://github.com/cddmp/enum4linux-ng" "bloodhound" "git+https://github.com/dirkjanm/mitm6.git" "pypykatz")
BrewTools=("nuclei" "httpx" "subfinder" "proxychains-ng" "navi" "rustscan")
>>>>>>> f0d987d (wallpapers and install modifications)
# Reversing tools
Reversing=("ltrace" "strace" "ghidra" "strings" "binwalk")
pipReversting=("oletools")
# Networking tools
NetworkingTools=("wireshark")

DOTfolder=$(find / -name DOTconf -type d 2> /dev/null | sed -n '1p')

#ToDo:
# - burp
# - Gnome extension: check top gnome extesntions, probably system monitor, clipboard, IPs, desktops, dash to dock,  
# - ZSH Theme concept: https://github.com/ohmyzsh/ohmyzsh/wiki/Themes#jonathan & https://github.com/ohmyzsh/ohmyzsh/wiki/Themes#xiong-chiamiov-plus
# - Conky install and config
# - backup dconf settings rather than indavidual gsettings commands: https://www.addictivetips.com/ubuntu-linux-tips/back-up-the-gnome-shell-desktop-settings-linux/
# - neofetch config and add to repo
# - download flare-floss executable from https://github.com/mandiant/flare-floss/releases/tag/v2.0.0, put in /opt and link to /usr/bin or something
# - add wallpapers to pictures and change xml file

################################################# General Functions #################################################

# packageManager(){
declare -A osInfo=([/etc/redhat-release]="sudo yum install -y" [/etc/arch-release]="sudo pacman --noconfirm -S" [/etc/debian_version]="sudo apt install -y" [etc/alpine-release]="sudo apk add -y")
for f in ${!osInfo[@]}; do if [[ -f $f ]]; then manager=${osInfo[$f]} && break; fi; done
# }

update(){
	declare -A osInfo=([/etc/redhat-release]='sudo yum update -y' [/etc/arch-release]='sudo pacman -Syu' [/etc/debian_version]='sudo apt update && sudo apt upgrade' [/etc/alpine-release]='sudo apk update -y')
	for f in ${!osInfo[@]}; do if [[ -f $f ]]; then eval ${osInfo[$f]} 1>/dev/null; fi; done
}

installer(installmanager){ # the input takes the neame of the variable rather than its values (i think it will requre more '@' signs around the varilable)
	progList=$@
        # eval "$manager ${progList[@]}"
	for pkg in $progList
	do
		if command -v $pkg >/dev/null 2>&1; then
			echo -e "$info  \033[31m*\033[0m[ $pkg is Already Installed ]\033[31m*\033[0m"
		else
			echo -ne "$warning  \033[31m*\033[0m[ $pkg is Not Installed (Attempting to Install..) ]\033[31m*\033[0m\n"
			eval "$installmanager $pkg 1> /dev/null"
			echo -ne "$success  \033[31m*\033[0m[ $pkg is Complete ]\033[31m*\033[0m\n"
		fi
	done
}

header(){
	echo "\n============================================================\n"
	echo "[+] $@\n"
	echo "============================================================\n\n"
}

################################################# Repos ################################################

kaliRepo(){
	wget -q -O - archive.kali.org/archive-key.asc | sudo apt-key add -
}

blackArchInstall(){
	# Run https://blackarch.org/strap.sh as root and follow the instructions.
	curl -O https://blackarch.org/strap.sh
	
	# Download checksum from seperate location
	curl -O https://raw.githubusercontent.com/BlackArch/blackarch-site/master/checksums/strap

	# Verify the SHA1 sum
	if [[ ! `echo "$(<strap)" | sha1sum -c` ]] ; then
	       echo "sha1sum failed --- Exiting" ; exit 0;
	fi

	# Set execute bit
	chmod +x strap.sh

	# Run strap.sh
	sudo ./strap.sh
	wait $!

	# remove strap and hash file
	rm strap{.sh,}

	# Enable multilib following https://wiki.archlinux.org/index.php/Official_repositories#Enabling_multilib and run:
	sudo pacman --noconfirm -Syu 1>/dev/null
}

################################################ Configurations ################################################

configureArch(){
	installer programsArch

	# reflector
	sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
  	sudo reflector --save /etc/pacman.d/mirrorlist -c GB --protocol https --latest 5
        update
}

tmux(){
	#copy .tmux.conf to home directory
	if [[ -a ~/.tmux.conf ]]
	then
		mv /home/$USER/.tmux.conf /home/$USER/.tmux.conf.bak
		ln -s $DOTfolder/.tmux.conf $HOME/
	else
		ln -s $DOTfolder/.tmux.conf $HOME/
	fi
	
	if [[ ! -a ~/.tmux/plugins/tmp ]]
	then
		git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
	fi
}

zsh(){
	if [[ -a $HOME/.zshrc ]]
	then
		mv $HOME/.zshrc $HOME/.zshrc.bak
		ln -s $PWD/.zshrc $HOME/
	else
		ln -s $PWD/.zshrc $HOME/
	fi
	source $HOME/.zshrc
	# install ohmyzsh
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
	wait $?

	# install extra plugins
        mkdir -p $HOME/.oh-my-zsh/plugins/
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
	git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
	
	# add chsh to zsh
	sudo chsh -s `which zsh`
}

ConfigureGnome(){
  installer gnome-extensions
  wait $?

  # night mode on
  gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
 # Automatic night light schedule
  gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-automatic true
  #set dark theme
  gsettings set org.gnome.desktop.interface color-scheme prefer-dark | gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'

  # Disable all gnome extensions
  for ext in $(/usr/bin/ls ~/.local/share/gnome-shell/extensions); do 
    gnome-extensions disable $ext
  done

  #enable required extensions
  gnome-extensions enable apps-menu@gnome-shell-extensions.gcampax.github.com

  # icon theme
  sudo mkdir -p /usr/share/icons/
  git clone https://github.com/EliverLara/candy-icons.git /usr/share/icons/candy-icons
  gsettings set org.gnome.desktop.interface icon-theme candy-icons
  
  # dash-to-dock config
  wait $?
  gsettings set org.gnome.shell.extensions.dash-to-dock intellihide true
  gsettings set org.gnome.shell.extensions.dash-to-dock autohide true
  gsettings set org.gnome.shell.extensions.dash-to-dock autohide-in-fullscreen true

}

# InstallWallpaper(){
#         ## Dynamic Wallpaper : Set wallpapers according to current time.
# 	## Created to work better with job schedulers (cron)
# 	
# 	## ANSI Colors (FG & BG)
# 	RED="$(printf '\033[31m')"  GREEN="$(printf '\033[32m')"  ORANGE="$(printf '\033[33m')"  BLUE="$(printf '\033[34m')"
# 	MAGENTA="$(printf '\033[35m')"  CYAN="$(printf '\033[36m')"  WHITE="$(printf '\033[37m')" BLACK="$(printf '\033[30m')"
# 	REDBG="$(printf '\033[41m')"  GREENBG="$(printf '\033[42m')"  ORANGEBG="$(printf '\033[43m')"  BLUEBG="$(printf '\033[44m')"
# 	MAGENTABG="$(printf '\033[45m')"  CYANBG="$(printf '\033[46m')"  WHITEBG="$(printf '\033[47m')" BLACKBG="$(printf '\033[40m')"
# 	
# 	# Path
# 	DES="/usr/share"
# 	
# 	## Make dirs
# 	mkdir_dw() {
# 		echo -e ${ORANGE}"[*] Installing Dynamic Wallpaper..."${WHITE}
# 		if [[ -d $DES/dynamic-wallpaper ]]; then
# 			# delete old directory
# 			sudo rm -rf $DES/dynamic-wallpaper
# 			# create new directory
# 			sudo mkdir -p $DES/dynamic-wallpaper
# 		else
# 			# create new directory
# 			sudo mkdir -p $DES/dynamic-wallpaper
# 		fi
# 	}
# 	
# 	## Copy files
# 	copy_files() {
# 		# copy images and scripts
# 		sudo cp -r $DOTfolder/Config/images $DES/dynamic-wallpaper && sudo cp -r $DOTfolder/Config/dwall.sh $DES/dynamic-wallpaper
# 		# make script executable
# 		sudo chmod +x $DES/dynamic-wallpaper/dwall.sh
# 		# create link in bin directory
# 		if [[ -L /usr/bin/dwall ]]; then
# 			sudo rm /usr/bin/dwall
# 			sudo ln -s $DES/dynamic-wallpaper/dwall.sh /usr/bin/dwall
# 		else
# 			sudo ln -s $DES/dynamic-wallpaper/dwall.sh /usr/bin/dwall
# 		fi
# 		echo -e ${GREEN}"[*] Installed Successfully. Execute 'dwall' to Run."${WHITE}
# 	}
# 	
# 	## Install
# 	mkdir_dw
# 	copy_files
# 	
# }

InstallWallpaper(){
  sudo cp -r $DOTfolder/Wallpapers/* /usr/share/backgrounds/
  sudo mv $DOTfolder/Wallpapers/**/*.xml /usr/share/backgrounds/gnome/
}

vimModules(){
	installer vim

	#install vimplug
	curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

	# configure vimrc
	ln -s $DOTfolder/.vimrc $HOME

	# add vim modules
	if [[ ! $HOME/.vim/pack/plugins/start ]] ; then mk -p $HOME/.vim/pack/vendor/start; fi
	ln -s $HOME/GitDocs/Vim\ Modules/* $HOME/.vim/pack/vendor/start

	# COC install
	vim -c "helptags $HOME/.vim/pack/vendor/start/coc.nvim/doc/ | q"
	vim -c "CocInstall -sync coc-sh coc-pyright"
}

Neovim(){
	installer neovim noto-fonts{,-extra,-emoji}
	
        # config add
        git clone https://github.com/NvChad/NvChad.git ~/.config/nvim
}

################################################# Misc. Tools #################################################

optTools(){ #works
	# pspy
	sudo curl -sL --create-dirs -o /opt/pspy/pspy32 https://github.com/DominicBreuker/pspy/releases/download/v1.2.0/pspy32 
	sudo curl -sL --create-dirs -o /opt/pspy/pspy64 https://github.com/DominicBreuker/pspy/releases/download/v1.2.0/pspy64 
	
	# LinPEAS 
	sudo curl -sL --create-dirs -o /opt/PEAS/linpeas.sh https://github.com/carlospolop/PEASS-ng/releases/download/20220424/linpeas.sh 
	sudo curl -sL --create-dirs -o /opt/PEAS/linpeas_linux_386 https://github.com/carlospolop/PEASS-ng/releases/download/20220424/linpeas_linux_386 
	
	# WinPEAS 
	sudo curl -sL --create-dirs -o /opt/PEAS/winPEASany_ofs.exe https://github.com/carlospolop/PEASS-ng/releases/latest/download/winPEASany_ofs.exe 
	sudo curl -sL --create-dirs -o /opt/PEAS/winPEAS.bat https://github.com/carlospolop/PEASS-ng/releases/download/20220424/winPEAS.bat 
	
	# DockerPEAS 
	sudo curl -sL --create-dirs -o /opt/PEAS/deepce.sh https://github.com/stealthcopter/deepce/raw/main/deepce.sh 

	# MetasploitPEAS
	sudo wget https://raw.githubusercontent.com/carlospolop/PEASS-ng/master/metasploit/peass.rb -O /usr/share/metasploit-framework/modules/post/multi/gather/peass.rb
	
	# SeImpersonatePrivilege Exploits
	sudo curl -sL --create-dirs -o /opt/SeImpersonatePrivilege/JuicyPotato/JuicyPotato.exe https://github.com/ohpe/juicy-potato/releases/download/v0.1/JuicyPotato.exe
	sudo curl -sL --create-dirs -o /opt/SeImpersonatePrivilege/JuicyPotato/README.md https://raw.githubusercontent.com/ohpe/juicy-potato/master/README.md
	
	sudo curl -sL --create-dirs -o /opt/SeImpersonatePrivilege/PrintSpoofer/PrintSpoofer32.exe https://github.com/itm4n/PrintSpoofer/releases/download/v1.0/PrintSpoofer32.exe
	sudo curl -sL --create-dirs -o /opt/SeImpersonatePrivilege/PrintSpoofer/PrintSpoofer64.exe ttps://github.com/itm4n/PrintSpoofer/releases/download/v1.0/PrintSpoofer64.exe
	sudo curl -sL --create-dirs -o /opt/SeImpersonatePrivilege/PrintSpoofer/README.md https://raw.githubusercontent.com/itm4n/PrintSpoofer/master/README.md

	sudo curl -sL --create-dirs -o /opt/SeImpersonatePrivilege/PrintSpoofer/PrintSpoofer32.exe https://github.com/itm4n/PrintSpoofer/releases/download/v1.0/PrintSpoofer32.exe 
	sudo curl -sL --create-dirs -o /opt/SeImpersonatePrivilege/PrintSpoofer/PrintSpoofer64.exe ttps://github.com/itm4n/PrintSpoofer/releases/download/v1.0/PrintSpoofer64.exe 
	sudo curl -sL --create-dirs -o /opt/SeImpersonatePrivilege/PrintSpoofer/README.md https://raw.githubusercontent.com/itm4n/PrintSpoofer/master/README.md 

	# Responder install 
	sudo git clone https://github.com/lgandx/Responder /opt/Responder && sudo ln -s /opt/Responder/responder.py /usr/local/bin/responder 
	sudo chmod +x /usr/local/bin/responder 
	
	#MimiKatz 
	sudo curl -sL --create-dirs -o /opt/Mimikatz/Mimikatz_trunk.zip https://github.com/gentilkiwi/mimikatz/releases/download/2.2.0-20210810-2/mimikatz_trunk.zip 

	#Chisel 
	sudo curl -sL --create-dirs -o /opt/Chisel/ChiselLinux386.gz https://github.com/jpillora/chisel/releases/download/v1.7.7/chisel_1.7.7_linux_386.gz 
	sudo curl -sL --create-dirs -o /opt/Chisel/ChiselWindows386.gz https://github.com/jpillora/chisel/releases/download/v1.7.7/chisel_1.7.7_windows_386.gz 
 
	#BloodHound Data Gatherers 
	sudo curl -sL --create-dirs -o /opt/BloodHound/AzureHound.ps1 https://github.com/BloodHoundAD/BloodHound/blob/master/Collectors/AzureHound.ps1 
	sudo curl -sL --create-dirs -o /opt/BloodHound/SharpHound.exe https://github.com/BloodHoundAD/BloodHound/blob/master/Collectors/SharpHound.exe 

        #kerbrute
        sudo curl -sL --create-dirs -o /opt/kerbrute_linux_amd64 https://github.com/ropnop/kerbrute/releases/download/v1.0.3/kerbrute_linux_amd64 && sudo ln -s /opt/kerbrute /usr/local/bin/kerbrute 

        #Sliver
	if [[ -z `command -v sliver` ]]; then sudo git clone https://github.com/BishopFox/sliver.git /opt && cd /opt/sliver && curl https://sliver.sh/install|sudo bash fi

        # Navi install
        sudo curl -sL --create-dirs -o /opt/navi/navi-linux.tar.gz https://github.com/denisidoro/navi/releases/download/v2.20.1/navi-v2.20.1-aarch64-unknown-linux-gnu.tar.gz && cd /opt/navi && tar xzf navi-linux.tar.gz && sudo ln -s navi /usr/local/bin/navi

        # nucli Templates
        sudo git clone https://github.com/projectdiscovery/nuclei-templates.git /opt/nuclei-templates

}

LocalGTFO(){
	GTFOpy="$DOTfolder/Databases/GTFOBLookup"
	pip install -r $GTFOpy/requirements.txt
	python3 $GTFOpy/gtfoblookup.py update
	sudo ln -s $GTFOpy/gtfoblookup.py /bin
}

FirefoxPentestPlugins(){
	firefox https://addons.mozilla.org/en-US/firefox/addon/foxyproxy-standard/ https://addons.mozilla.org/en-US/firefox/addon/firebug/ https://addons.mozilla.org/en-US/firefox/addon/user-agent-switcher/ https://addons.mozilla.org/en-US/firefox/addon/live-http-headers/ https://addons.mozilla.org/en-GB/firefox/addon/hacktools/
}

################################################ Tool Collection Installs ################################################ 

# GoTools(){
# 	#Install go
# 	installer go || installer go-lang
#         wait $?
# 	#Install web testing tools
# 	go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest
# 	go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
# 	go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
# 	#templates for web testing tools
# }

# RustTools(){
#   installer cargo
#   wait $?
#   # install go tools
#   cargo install rustscan
#   installer fzf
#   cargo install --locked navi
#
#
# }
BrewTools(){
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

installPentestTools(){
	if [[ -f /etc/arch-release ]]
	then 
		blackArchInstall
	elif [[ -f /etc/debian_version ]]
	then
		kaliRepo
	else
		continue
	fi
	wait $?
	installer ${Pentest[*]}
	wait $?
	optTools
        wait $?
        [ ! -d "/usr/share/seclist" ] && installer($manager) seclists
        wait $?
        curl -sSL https://bootstrap.pypa.io/get-pip.py | python3
        wait $?
        python3 -m pip install --user pipx
	wait $?
	for i in ${pipxPrograms[*]}; do eval "pipx install $i"; done
	wait $?
	LocalGTFO
	wait $?
	FirefoxPentestPlugins
}

installBasic(){
  installer($manager) ${programsAll[*]}
	wait $?
	zsh
	wait $?
	tmux
	wait $?
	Neovim
	wait $?
        InstallWallpaper
	wait $?
	if [[ -f /etc/arch-release ]]; then configureArch; fi
	wait $?
}

Configure(){
	echo "select one of the following:"
	echo "1) basic"
	echo "2) pentest"
	echo "3) all"
	read select
	# packageManager

	case $select in
		1)
			update
			installBasic
			;;
		2)
			update
			installPentestTools
			;;
		3)
			update
			installBasic
			installPentestTools
			;;
	esac
} 
Configure
