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
ENABLE_CORRECTION="false"

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
HIST_STAMPS="yyyy/mm/dd"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.

plugins=(git zsh-syntax-highlighting zsh-autosuggestions) # compleat)

source $ZSH/oh-my-zsh.sh

# User configuration

export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='vi'
fi

if [[ neofetch ]]; then neofetch; fi

# export MYIP=$(ip addr show tun0 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' --color=none)

## Aliases

#internet QOL
alias www="firefox -url $1 &"

#git QOL things
alias gitgraph="git log --all --graph --decorate"

#copy to clipboard
alias clip='xclip -selection clipboard'

#to work with tar.gz files
alias untar="tar -xvf $@"
alias viewtar="tar -tvf $@"

#reload zsh
alias reload='source ~/.zshrc'

#rustscan in docker
alias rustscan='sudo docker run -it --rm --name rustscan cmnatic/rustscan:debian-buster rustscan'

#Spin-up docker
alias dockerit='sudo docker run -it --rm -v $PWD/$2:/ --entrypoint=/bin/bash $2'

# SMBeagle
function smbeagle(){
  if [ -z $1 ]; then
    read -p 'List network CIDR (space seperated): ' networks
  else
    $@=networks
  fi
  read -p 'To use crednetials, please list the username and password in the following format (-u <USERNAME> -p <PASSWORD>): ' creds
  sudo docker run -v "./output:/tmp/output" punksecurity/smbeagle -c /tmp/output/results.csv -n $networks $creds
}

#torify proxy
alias hide='if [ `systemctl is-active` = 'inactive'] ; do systemctl start tor ;fi ; source torsocks on'
alias unhide='source torsocks off'
# or
# alias hide='source torsocks on'
# alias unhide='source torsocks off'

#network help
alias listening='ss -nlt'

#colour commands
alias ip="ip -c"

# docker here
alias dockerit='sudo docker run -it --rm -v $PWD/$2:/ $2'

# Bloodhound
alias bloodhound='xhost + && sudo docker run -it --rm -v /tmp/.X11-unix/:/tmp/.X11-unix -e DISPLAY=$DISPLAY --network host --name bloodhound bannsec/bloodhound'

# Batcat alias
alias bat="batcat"

# Quick resurect tmux session
alias mux='pgrep -vx tmux > /dev/null && \
		tmux new -d -s delete-me && \
		tmux run-shell ~/.tmux/plugins/tmux-resurrect/scripts/restore.sh && \
		tmux kill-session -t delete-me && \
		tmux attach || tmux attach'

## Functions

#make a directory and move into it
mk() {
	mkdir $1
	cd $1
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
  sudo cp $(realpath $1){,.bak}
}

update(){
  bash -c 'declare -A osInfo=([/etc/redhat-release]="sudo yum update -y" [/etc/arch-release]="sudo pacman -Syu" [/etc/debian_version]="sudo apt update && sudo apt upgrade -y" [/etc/alpine-release]="sudo apk update -y") && for f in ${!osInfo[@]}; do if [[ -f $f ]]; then eval ${osInfo[$f]}; fi; done'
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

update(){
	typeset -A osInfo
	osInfo=(/etc/redhat-release 'sudo yum update -y' '/etc/arch-release' 'sudo pacman -Syu' /etc/debian_version 'sudo apt update && sudo apt upgrade' /etc/alpine-release 'sudo apk update -y')
	for f in ${(@f)osInfo}; do if [[ -f $f ]]; then eval $osInfo[$f]; fi; done
}

export PATH="$HOME/.local/bin:/home/linuxbrew/.linuxbrew:$PATH" #$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$HOME/.cargo/bin

# nvai widgit
eval "$(navi widget zsh)"

