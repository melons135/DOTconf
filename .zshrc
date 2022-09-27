# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="jonathan"
#ZSH_THEME="nathan"
#ZSH_THEME="nathanDOT"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
#ZSH_THEME_RANDOM_CANDIDATES=( "Kali-IP" "jonathan")

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
zstyle ':omz:update' frequency 14

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
 HIST_STAMPS="dd/mm/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.

plugins=(git zsh-syntax-highlighting zsh-autosuggestions compleat)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='vi'
fi

if [[ neofetch ]]; then neofetch; fi

## Aliases

#encoding translation
alias rot13="tr 'A-Za-z' 'N-ZA-Mn-za-m'"
alias urldecode="sed 's@+@ @g;s@%@\\\\x@g' | xargs -0 printf '%b'"

#internet QOL
alias www="firefox -url $1 &"

#move to try hack me folder
alias thmdir="cd ~/Documents/TryHackMe/ && ls"

#move to Hackthebox folder
alias htbdir="cd ~/Documents/Hackthebox/ && ls"

#git QOL things
alias gitgraph="git log --all --graph --decorate"

#copy to clipboard
alias clip='xclip -selection clipboard'

#to work with tar.gz files
alias untar="tar -xvf $@"
alias veiwtar="tar -tvf $@"

#get external ip
alias externalip='curl https://api.ipify.org/'

#get distro info
alias distro='cat /etc/*-release'

#reload zsh
alias reload='source ~/.zshrc'

#zshrc change
alias zshrc='sudo vim ~/.zshrc'

#rustscan in docker
alias rustscan='sudo docker run -it --rm --name rustscan cmnatic/rustscan:debian-buster rustscan'

#Spin-up docker
alias dockerit='sudo docker run -it --rm -v $PWD/$2:/ --entrypoint=/bin/bash $2'

#torify proxy
alias hide='if [ `systemctl is-active` = 'inactive'] ; do systemctl start tor ;fi ; source torsocks on'
alias unhide='source torsocks off'

#network help
alias listening='ss -nlt'

#colour commands
alias ip="ip -c"

## Functions

#make a directory and move into it
mk() {
	mkdir $1
	cd $1
}
smk() {
	sudo mkdir $1
	cd $1
}

# Change directory and ls
cdl() {
	cd $1 && ls
}

#start python server
server(){
	PORT=$(($RANDOM+1024))
	echo 'Server address has been copied to your clipboard, if a file was listed after this has also been copied. A file can be added as an argument, this will be also added to URI that has been coppied'
	ADDRESS="http://$(hostname -I | awk '{print $1}'):$PORT"
	xclip -selection clipboard $ADDRESS/$1
	echo "The server is being hosted on $ADDRESS, the files in this directory are:"
	ls $PWD
	sudo python3 -m http.server $PORT &>/dev/null
}

#fast scan and output
function scan(){
	sudo docker run -it -v $PWD:/nmap --rm --name rustscan cmnatic/rustscan:debian-buster rustscan $1 -- -A -oN /nmap/nmap.txt -oX /nmap/nmap.xml && searchsploit -v --nmap nmap.xml --exclude="/dos/" | tee "searchsploit.txt" && rm nmap.xml
}

#backup file
function backup(){
	sudo cp $(realpath $1) $(realpath $1).bak
}

#GTFOBlookup scripts
# from https://github.com/nccgroup/GTFOBLookup
GTFOBLookup=$(find / -name gtfoblookup.py -type f 2>/dev/null)
gtfo(){
	python3 $GTFOBLookup gtfobins search $1
}

lolbas(){
	python3 $GTFOBLookup lolbas search $1
}

wadcoms(){
	python3 $GTFOBLookup wadcoms search $1
}

update-bins(){
	python3 $GTFOBLookup update
}

# Compare 2 strings
compare(){
	if [[ ! $( diff <(echo $1) <(echo $2)) ]]; then echo Match; else diff <(echo $1) <(echo $2); fi
}

#connect to VPNs
tryhackme() {
	sudo pkill openvpn;
	sudo openvpn ~/Documents/OVPN/melons135.ovpn&
}
hackthebox(){
	sudo pkill openvpn;
	sudo openvpn ~/Documents/OVPN/lab_0xCthu1hu.ovpn&
}
closevpn(){
	sudo pkill openvpn
}

update(){
	typeset -A osInfo
	osInfo=(/etc/redhat-release 'sudo yum update -y' '/etc/arch-release' 'sudo pacman -Syu' /etc/debian_version 'sudo apt update && sudo apt upgrade' /etc/alpine-release 'sudo apk update -y')
	for f in ${(@f)osInfo}; do if [[ -f $f ]]; then eval $osInfo[$f]; fi; done
}

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$HOME/.cargo/bin:$HOME/.local/bin:$HOME/.nimble/bin:$PATH"

# nvai widgit
eval "$(navi widget zsh)"

