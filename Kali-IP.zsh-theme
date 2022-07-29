PROMPTIP=$( if [[ -d /sys/class/net/tun0 ]] ; then ip addr show tun0 | grep "inet " | awk '{print $2}' ; else false; fi || ip route get 8.8.8.8 2>/dev/null && sed -nE '1{s/.*?src (\S+) .*/\1/;p}' || echo "No Internet/VPN")
PROMPTINTEFACE=$( ip a show tun0 2>/dev/null || ip route get 8.8.8.8 2>/dev/null | awk -F"dev " 'NR==1{split(£2,a," ");print a[1]}' )

PROMPT=$'%F{%(#.blue.green)}%{\e(0%}%{\e(B%}┌──${debian_chroot:+($debian_chroot)──}(%B%F{%(#.red.blue)}%n%(#.💀.㉿)%m%b%F{%(#.blue.green)})-{%F{yellow}$PROMPTINTEFACE:$PROMPTIP%F{%(#.blue.green)}}-[%B%F{reset}%(6~.%-1~/…/%4~.%5~)%b%F{%(#.blue.green)}] \n└─%B%(#.%F{red}#.%F{blue}$)%b%F{reset} '
RPROMPT=$'%(?.. %? %F{red}%B⨯%b%F{reset})%(1j. %j %F{yellow}%B⚙%b%F{reset}.) %F{%(#.blue.green)}[%F{white} %D{%d-%m} %F{%(#.blue.green)}@ %F{white}%D{%K:%M}%F{%(#.blue.green)} ]'

#this resets the prompt every 1 sec to keep time up to date
TMOUT=60
TRAPALRM() {
	zle reset-prompt
}

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[green]%}["
ZSH_THEME_GIT_PROMPT_SUFFIX="]%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY=" %{$fg[red]%}*%{$fg[green]%}"
ZSH_THEME_GIT_PROMPT_CLEAN=""
