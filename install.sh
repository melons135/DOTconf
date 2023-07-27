#!/bin/bash

#---------------
warning="[- \033[31mWARNING\033[0m -]"
info="[- \033[1;33minfo\033[0m -]"
failure="[- \033[31mFAILED\033[0m -]"
success="[- \033[1;32mSUCCESS\033[0m -]"
downloading="\033[32m[\033[0m Downloading    \033[32m]\033[0m\r"&&

usage(){
	echo "This script is for setting up linux distros how I like them."
  echo "Specifically Ubuntu and Arch"
}

# set -x pipefail

################################################# Variables #################################################

programsAll=("git" "zsh" "python3" "tmux" "guake" "parcellite" "python3-pip" "python3-venv" "ssh" "openvpn" "firefox" "ufw" "curl" "jq" "docker" "tor" "zip" "neofetch" "dconf" "etckeeper")
programsArch=("reflector" "gnome" "xorg-xrandr" "feh" "cronie" "fd" "ripgrep-all")
# Pentest
Pentest=("metasploit" "ffuf" "enum4linux" "feroxbuster" "gobuster" "nbtscan" "nikto" "nmap" "onesixtyone" "smbclient" "smbmap" "whatweb" "wkhtmltopdf" "sqlmap" "crackmapexec" "evil-winrm" "chisel" "onesixtyone" "oscanner" "redis-tools" "snmpwalk" "svwar" "tnscmd10g" "amass" "hashcat" "john" "bettercap" "exploitdb" "sliver")
pipxPrograms=("git+https://github.com/calebstewart/pwncat.git" "git+https://github.com/Tib3rius/AutoRecon.git" "impacket" "git+https://github.com/cddmp/enum4linux-ng" "bloodhound" "git+https://github.com/dirkjanm/mitm6.git" "pypykatz" "howdoi")
BrewTools=("navi" "nim")
BrewToolsPentest=("nuclei" "httpx" "subfinder" "proxychains-ng" "rustscan")
BrewToolsNetwork=("zeek")
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
# - increase speed of .zsh loading
# - kali requires '-t kali-rolling' after apt command with this setup, add 'kali-get' to zshrc file
# - add networking tools install
# - obsidian link is correct but links to 404 due to %0D contained in Version variable
# - apply version program to /opt downloads
# - If its a laptop add https://github.com/iberianpig/fusuma and link config to DOTfolder fusuma
# -  

################################################# General Functions #################################################

# packageManager(){
# declare -A osInfo=([/etc/redhat-release]="sudo yum install -y" [/etc/arch-release]="sudo pacman --noconfirm -S" [/etc/debian_version]="sudo apt install -y" [etc/alpine-release]="sudo apk add -y")
# for f in ${!osInfo[@]}; do if [[ -f $f ]]; then manager=${osInfo[$f]} && break; fi; done
# }

update(){
  declare -A osInfo=([/etc/redhat-release]='sudo yum update -y' [/etc/arch-release]='sudo pacman -Syu' [/etc/debian_version]='sudo apt update && sudo apt upgrade -y' [/etc/alpine-release]='sudo apk update -y')
	for f in ${!osInfo[@]}; do if [[ -f $f ]]; then header "Updating" && eval ${osInfo[$f]} 1>/dev/null; fi; done
}

installer(){ # the input takes the neame of the variable rather than its values (i think it will requre more '@' signs around the varilable)
	progList=$@
        # eval "$manager ${progList[@]}"
	for pkg in $progList
	do
		if command -v $pkg >/dev/null 2>&1; then
			echo -e "$info  \033[31m*\033[0m[ $pkg is Already Installed ]\033[31m*\033[0m"
		else
			echo -ne "$warning  \033[31m*\033[0m[ $pkg is Not Installed (Attempting to Install..) ]\033[31m*\033[0m\n"
			eval "$manager $pkg"
			echo -ne "$success  \033[31m*\033[0m[ $pkg is Complete ]\033[31m>33[31m*\033[0m\n"
			# if [[ $? -ne 1 ]]; then echo -ne "$failure  \033[31m*\033[0m[ $pkg Failed to Install ]\033[31m*\033[0m\n"; else echo -ne "$success  \033[31m*\033[0m[ $pkg is Complete ]\033[31m*\033[0m\n"; fi
		fi
	done
}

header(){
	echo -en "\n============================================================\n"
	echo -en "$success[+] $info$@\n"
	echo -en "============================================================\n\n"
}

################################################# Repos ################################################

kaliRepo(){
	echo "[i] Adding kali repository to apt sources"
	sudo sh -c "echo 'deb https://http.kali.org/kali kali-rolling main non-free contrib' > /etc/apt/sources.list.d/kali.list"
	sudo chmod 644 /etc/apt/sources.list.d/kali.list
	sudo apt install gnupg
	sudo wget https://archive.kali.org/archive-key.asc -O /etc/apt/trusted.gpg.d/kali-archive-keyring.asc
	echo "[i] setting low priority for kali repository"
	sudo sh -c "echo 'Package: *'>/etc/apt/preferences.d/kali.pref; echo 'Pin: release a=kali-rolling'>>/etc/apt/preferences.d/kali.pref; echo 'Pin-Priority: 50'>>/etc/apt/preferences.d/kali.pref"
	sudo chmod 644 /etc/apt/preferences.d/kali.pref
	# Add to file dont clobber
	update
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

	# remove strap and hash file
	rm strap{.sh,}

	# Enable multilib following https://wiki.archlinux.org/index.php/Official_repositories#Enabling_multilib and run:
	sudo pacman --noconfirm -Syu 1>/dev/null
}

################################################ Configurations ################################################

configureArch(){
	installer ${programsArch[*]}

	# reflector
	sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
	sudo reflector --save /etc/pacman.d/mirrorlist -c GB --protocol https --latest 5
	update
}

Installtmux(){
	#copy .tmux.conf to home directory
	if [[ -a ~/.tmux.conf ]]
	then
		mv /home/$USER/.tmux.conf /home/$USER/.tmux.conf.bak
		ln -s $DOTfolder/.tmux.conf $HOME/
	else
		ln -s $DOTfolder/.tmux.conf $HOME/
	fi
	
	if [[ ! -a ~/.tmux/plugins/tpm ]]
	then
		mkdir -p ~/.tmux/plugins/tpm && git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
	fi

	# Install plugins
	tmux -c '$HOME/.tmux/plugins/tpm/scripts/install_plugins.sh'
}

Installzsh(){
	# install ohmyzsh (Install errors out and stops here)
	if command -v zsh >/dev/null 2>&1; then
		yes | sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
	else
		installer zsh
		yes | sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
	fi
	
	# set correct .zshrc
	if [[ -a $HOME/.zshrc ]]
	then
		mv $HOME/.zshrc $HOME/.zshrc.bak
		ln -s $DOTfolder/.zshrc $HOME/
	else
		ln -s $DOTfolder/.zshrc $HOME/
	fi 

	# install extra plugins
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.oh-my-zsh/plugins/zsh-syntax-highlighting
	git clone https://github.com/zsh-users/zsh-autosuggestions.git $HOME/.oh-my-zsh/plugins/zsh-autosuggestions
	
	# add chsh to zsh
	sudo chsh -s `which zsh`
}

ConfigureGnome(){
	installer gnome-extensions

	# icon theme
	sudo mkdir -p /usr/share/icons/
	git clone https://github.com/EliverLara/candy-icons.git /usr/share/icons/candy-icons
	gsettings set org.gnome.desktop.interface icon-theme candy-icons

  if [[ -f /etc/arch-release ]]
  then
    #load backup (for arch)
    dconf load / < $DOTfolder/dconf-backup
  elif [[ -f /etc/debian_version ]]
  then 
    # load conf for ubuntu
    mv $HOME/.config/dconf/user $HOME/.config/dconf/user.bak 
    ln -s $DOTfolder/dconf-backup $HOME/.config/dconf/user
  else
    exit 1
  fi

	# night mode on
	# gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
	# # Automatic night light schedule
	# gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-automatic true
	# #set dark theme
	# gsettings set org.gnome.desktop.interface color-scheme prefer-dark | gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
  #
	# Disable all gnome extensions
	#for ext in $(/usr/bin/ls ~/.local/share/gnome-shell/extensions); do 
	#  gnome-extensions disable $ext
	#done

	#enable required extensions
	#gnome-extensions enable apps-menu@gnome-shell-extensions.gcampax.github.com
	# dash-to-dock config
	#
	#gsettings set org.gnome.shell.extensions.dash-to-dock intellihide true
	#gsettings set org.gnome.shell.extensions.dash-to-dock autohide true
	#gsettings set org.gnome.shell.extensions.dash-to-dock autohide-in-fullscreen true

}

ConfigureNavi(){
	navi repo add https://github.com/denisidoro/cheats
	navi repo add https://github.com/denisidoro/navi-tldr-pages
	navi repo add https://github.com/melons135/Melons.cheat
}

InstallWallpaper(){
	sudo cp -r $DOTfolder/Wallpapers/* /usr/share/backgrounds/
	sudo cp $DOTfolder/xml/* /usr/share/gnome-background-properties/
}

Neovim(){
	installer neovim noto-fonts{,-extra,-emoji}
	
	# install space vim
	# curl -sLf https://spacevim.org/install.sh | bash

  # install NvChad
  git clone https://github.com/NvChad/NvChad $HOME/.config/nvim --depth 1 

  # Check installed in the correct place (this will clobber current config)
  if [[ -L $HOME/.nvim  ]]; then mv $HOME/.nvim $HOME/config/nvim; fi
}

Obsidian-Snap(){
	PACKAGE="obsidian-latest.snap"
	RELEASES_URL="https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest"
	DOWNLOAD_URL="$(wget -q "${RELEASES_URL}" -O - | jq -r '.assets[] | select(.name | endswith("_amd64.snap")) | .browser_download_url')"

	# Download snap image
	wget "${DOWNLOAD_URL}" -O "/tmp/${PACKAGE}"

	#snap install
	sudo snap install --dangerous "${PACKAGE}" --classic

	# Cleanup 
	rm "${PACKAGE}"
}

Powershell-Ubuntu(){
  # Update the list of packages
  update
  # Install pre-requisite packages.
  installer apt-transport-https software-properties-common
  # Download the Microsoft repository GPG keys
  wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb"
  # Register the Microsoft repository GPG keys
  sudo dpkg -i packages-microsoft-prod.deb
  # Update the list of packages after we added packages.microsoft.com
  update
  # Install PowerShell
  installer powershell
}

Sublime-Text-Ubuntu(){
	# Install key
	wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/sublimehq-archive.gpg > /dev/null

	# Install stable chanel
	echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
	
	#Update and install
	sudo apt update
	sudo apt install sublime-text
}

Docker(){
	# Remove previous docker tools
	sudo apt-get remove docker docker-engine docker.io containerd runc
	# Install dependancies
	sudo apt-get install ca-certificates curl gnupg lsb-release
	# Add keys
	sudo mkdir -p /etc/apt/keyrings
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
	# Add repo
	echo \
	"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	# Update
	sudo apt-get update
	if [ $? -nq 0 ]; then sudo chmod a+r /etc/apt/keyrings/docker.gpg && sudo apt-get update; fi
	# Install docker
	sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin
}

################################################ Misc. Tools #################################################

GetLatestsGit(){
  repo=$1 
  # select version from latest
  Latest=$(curl -J https://api.github.com/repos/$repo/releases | jq '.[] | .tag_name' | sed -n 1p | sed 's/\"//g')
}

optTools(){
	# pspy
  GetLatestsGit DominicBreuker/pspy
	sudo curl -sL --create-dirs -o /opt/pspy/pspy32 https://github.com/DominicBreuker/pspy/releases/download/$Latest/pspy32 
	sudo curl -sL --create-dirs -o /opt/pspy/pspy64 https://github.com/DominicBreuker/pspy/releases/download/$Latest/pspy64 
	
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

  sudo curl -sL --create-dirs -o /opt/SeImpersonatePrivilege/JuicyPotatoNG/JuicyPotatoNG.zip https://github.com/antonioCoco/JuicyPotatoNG/releases/download/v1.1/JuicyPotatoNG.zip

  sudo git clone https://github.com/calebstewart/CVE-2021-1675.git /opt/SeImpersonatePrivilege/PrintNightmare
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
  GetLatestsGit ropnop/kerbrute
	sudo curl -sL --create-dirs -o /opt/kerbrute_linux_amd64 https://github.com/ropnop/kerbrute/releases/download/$Latest/kerbrute_linux_amd64 && sudo ln -s /opt/kerbrute /usr/local/bin/kerbrute 

	#Sliver
	if [[ -z `command -v sliver` ]]; then sudo git clone https://github.com/BishopFox/sliver.git /opt && cd /opt/sliver && curl https://sliver.sh/install|sudo bash; fi

	# nucli Templates
	sudo git clone https://github.com/projectdiscovery/nuclei-templates.git /opt/nuclei-templates
	
	# Download Webshell Examples
	# sudo git clone https://gitlab.com/kalilinux/packages/webshells.git /opt/webshells
  #
  # Download flarefloss
  GetLatestsGit mandiant/flare-floss
  sudo curl -sL --create-dirs -o /opt/Floss https://github.com/mandiant/flare-floss/releases/download/$Latest/floss-$Latest-linux.zip && sudo ln -s /opt/Floss /usr/local/bin/floss

  # Download CyberChef
  GetLatestsGit gchq/CyberChef
  sudo wget https://github.com/gchq/CyberChef/releases/tag/CyberChef_$latest.zip /opt/CyberChef
  sudo unzip /opt/CyberChef/CyberChef_$latest -d /opt/CyberChef
  sudo rm -f /opt/CyberChef/CyberChef_$latest
}

# InstallZeek(){
#   local version=$(lsb_release -d | awk '{print $2}')"_"$(lsb_release -r | awk '{print $2}')
#   echo "deb http://download.opensuse.org/repositories/security:/zeek/x$version/ /" | sudo tee /etc/apt/sources.list.d/security:zeek.list
#   curl -fsSL https://download.opensuse.org/repositories/security:zeek/x$version/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/security_zeek.gpg > /dev/null
#   sudo apt update && sudo apt install zeek-lts
# }

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

BrewInstall(){
	NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

	# Configure variables and add to path
	export PATH="/home/linuxbrew/.linuxbrew/Homebrew/bin:$PATH"
	echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> $HOME/.zprofile
	eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

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
	
	# Kali requires '-t kali-rolling' after install
 	for pkg in ${Pentest[*]}
		do
			if command -v $pkg >/dev/null 2>&1; then
				echo -e "$info  \033[31m*\033[0m[ $pkg is Already Installed ]\033[31m*\033[0m"
			else
				echo -ne "$warning  \033[31m*\033[0m[ $pkg is Not Installed (Attempting to Install..) ]\033[31m*\033[0m\n"
				eval "$manager $pkg -t kali-rolling"
				echo -ne "$success  \033[31m*\033[0m[ $pkg is Complete ]\033[31m>33[31m*\033[0m\n"
			# if [[ $? -ne 1 ]]; then echo -ne "$failure  \033[31m*\033[0m[ $pkg Failed to Install ]\033[31m*\033[0m\n"; else echo -ne "$success  \033[31m*\033[0m[ $pkg is Complete ]\033[31m*\033[0m\n"; fi
			fi
		done
	
	optTools
        
	[ ! -d "/usr/share/seclist" ] && installer seclists
		
	for i in ${pipxPrograms[*]}; do eval "pipx install $i"; done
        
	local manager="brew install "

	installer ${BrewToolsPentest[*]}
	installer ${BrewToolsNetwork[*]}
	
	LocalGTFO
	
	FirefoxPentestPlugins
}

installBasic(){
	if [[ -f /etc/arch-release ]]; then configureArch; fi
	
	installer ${programsAll[*]}
	
	Installzsh
	
	Installtmux
	
	Neovim
	
	InstallWallpaper
	
  if [[ -f /etc/debian_version ]]
  then 
    Obsidian-Snap
    Powershell-Ubuntu
    Sublime-Text-Ubuntu
  fi

	Docker

	BrewInstall
        
	local manager="brew install "

	installer ${BrewTools[*]}

  if [ -d $HOME/.config/nvim/NvChad ]; then installer npm; fi

  ConfigureNavi

	# install pip
	curl -sSL https://bootstrap.pypa.io/get-pip.py | python3
	python3 -m pip install --user pipx
	
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

