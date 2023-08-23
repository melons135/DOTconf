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

#list all IPs breif
alias ips="ip -c=never -brie a"

# docker here
alias dockerit='sudo docker run -it --rm -v $PWD/$2:/ $2'

# Bloodhound
alias bloodhound='xhost + && sudo docker run -it --rm -v /tmp/.X11-unix/:/tmp/.X11-unix -e DISPLAY=$DISPLAY --network host --name bloodhound bannsec/bloodhound'

# Batcat alias
command -v bat >/dev/null 2>&1 && { alias cat="bat" }

# Quick resurect tmux session
alias mux='pgrep -vx tmux > /dev/null && \
		tmux new -d -s delete-me && \
		tmux run-shell ~/.tmux/plugins/tmux-resurrect/scripts/restore.sh && \
		tmux kill-session -t delete-me && \
		tmux attach || tmux attach'

command -v exa >/dev/null 2>&1 && { alias ls="exa" }

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

# this might not work due to command order (path called before fuctions)
function diff(){
	if ! command -v diff-so-fancy &> /dev/null
	then
		diff $"@" | diff-so-fancy
	else
		diff $"@"
fi
}

#backup file
function backup(){
  sudo cp $(realpath $1){,.bak}
}

# Compare 2 strings
compare(){
	if [[ ! $( diff <(echo $1) <(echo $2)) ]]; then echo Match; else diff <(echo $1) <(echo $2); fi
}

OS=$(grep ^NAME= /etc/os-release | awk -F '"' '{print $2}')
update(){
	case $OS in
		'Ubuntu' | 'Kali Linux')
			sudo apt update && sudo apt upgrade
			;;
		'Arch Linux')
			sudo pacman -Syu
			;;
		'Red Hat Enterprise Linux')
			sudo yum update -y
			;;
		'Alpine Linux')
			sudo apk update -y
			;;	
		*)
			echo 'This function has not registered the NAME value in the file etc/os-release'
			;;
	esac
}
