functions rbenv_prompt_info >& /dev/null || rbenv_prompt_info(){}

function prompt_command {
        
	PROMPTIP=$( if [[ -d /sys/class/net/tun0 ]] ; then ip addr show tun0 | grep "inet " | awk '{print $2}' ; else false; fi || ip route get 8.8.8.8 2>/dev/null && sed -nE '1{s/.*?src (\S+) .*/\1/;p}' || echo "No Internet/VPN")
	PROMPTINTEFACE=$( ip a show tun0 2>/dev/null || ip route get 8.8.8.8 2>/dev/null | awk -F"dev " 'NR==1{split(£2,a," ");print a[1] ":"}' )

	TERMWIDTH=${COLUMNS}

        RESET=$(%F{reset}%)
        CYAN=$fg_bold[cyan]
        green=$fg[green]
        YELLOW=$fg_bold[yellow]
        WHITE=$fg_bold[white]
        blue=$fg[blue]

	ULCORNER="┌"
	LLCORNER="└"
	LRCORNER="┘"	
	URCORNER="┐"

	#   "whoami" and "pwd" include a trailing newline
	usernam=$(whoami | tr '[:lower:]' '[:upper:]')
        hostname=$(uname -a | awk '{print $2}')
        
        # if root change all green to red
        if [ whoami == "root" ] ; then DEETS=$($fg_bold[red]$usernam💀$hostname$RESET); else DEETS=$($fg_bold[blue]$usernam㉿$hostname$RESET); fi

        tty=$(tty | awk -F'/' {'print $(NF-1)"/"$NF'})
	newPWD="${PWD}"
	# (deleter) power=$(apm | sed -e "s/.*: \([1-9][0-9]*\)%/\1/" | tr -d " ")
	#   Add all the accessories below ...
	let promptsize=$(echo -n "$ULCORNER──($DEETS)-{$PROMPTINTEFACE$PROMPTIP}--[$newPWD] $tty $URCORNER" | wc -c | tr -d " ")
	let fillsize=${TERMWIDTH}-${promptsize}
	fill=""
	while [ "$fillsize" -gt "0" ] 
	do 
	   fill="${fill}-"
	   let fillsize=${fillsize}-1
	done
	
	if [ "$fillsize" -lt "0" ]
	then
	   let cut=3-${fillsize}
	   newPWD="...$(echo -n $PWD | sed -e "s/\(^.\{$cut\}\)\(.*\)/\2/")"
	fi
}
#old
#PROMPT=$'%F{%(#.blue.green)}%{\e(0%}%{\e(B%}\
#┌──${debian_chroot:+($debian_chroot)──}\
#(%B%F{%(#.red.blue)}%n%(#.💀.㉿)%m%b%F{%(#.blue.green)})\
#-{%F{yellow}$PROMPTINTEFACE$PROMPTIP%F{%(#.blue.green)}}\
#-[%B%F{reset}%(6~.%-1~/…/%4~.%5~)%b%F{%(#.blue.green)}]\
#\n└─%B%(#.%F{red}#.%F{blue}$)%b%F{reset} '

PROMPT=$'$green$ULCORNER──($DEETS$green)-{$YELLOW$PROMPTINTEFACE$PROMPTIP$green}--[$WHITE$newPWD$green]$fill $RESET$tty $green$URCORNER\n$LLCORNER-$blue\$ '
RPROMPT=$'%(?.. %? %F{red}%B⨯%b%F{reset})%\
(1j. %j %F{yellow}%B⚙%b%F{reset}.) \
%F{%(#.blue.green)}\
[%F{white} %D{%d-%m} %F{%(#.blue.green)}@ \
%F{white}%D{%K:%M}%F{%(#.blue.green)} ]$LRCORNER'

#this resets the prompt every 1 min to keep time up to date
TMOUT=60
TRAPALRM() {
	zle reset-prompt
}


setprompt () {
    ###
    # Need this so the prompt will work.

    setopt prompt_subst


    ###
    # See if we can use colors.

    autoload zsh/terminfo
    for color in RED GREEN YELLOW BLUE MAGENTA CYAN WHITE GREY; do
	eval PR_$color='%{$terminfo[bold]$fg[${(L)color}]%}'
	eval PR_LIGHT_$color='%{$fg[${(L)color}]%}'
	(( count = $count + 1 ))
    done
    PR_NO_COLOUR="%{$terminfo[sgr0]%}"

    ###
    # Modify Git prompt
    ZSH_THEME_GIT_PROMPT_PREFIX=" on %{$fg[green]%}"
    ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
    ZSH_THEME_GIT_PROMPT_DIRTY=""
    ZSH_THEME_GIT_PROMPT_CLEAN=""

    ZSH_THEME_GIT_PROMPT_ADDED="%{$fg[green]%} ✚"
    ZSH_THEME_GIT_PROMPT_MODIFIED="%{$fg[blue]%} ✹"
    ZSH_THEME_GIT_PROMPT_DELETED="%{$fg[red]%} ✖"
    ZSH_THEME_GIT_PROMPT_RENAMED="%{$fg[magenta]%} ➜"
    ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg[yellow]%} ═"
    ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[cyan]%} ✭"

    ###
    # See if we can use extended characters to look nicer.
    # UTF-8 Fixed

    if [[ $(locale charmap) == "UTF-8" ]]; then
	PR_SET_CHARSET=""
	PR_SHIFT_IN=""
	PR_SHIFT_OUT=""
	PR_HBAR="─"
        PR_ULCORNER="┌"
        PR_LLCORNER="└"
        PR_LRCORNER="┘"
        PR_URCORNER="┐"
    else
        typeset -A altchar
        set -A altchar ${(s..)terminfo[acsc]}
        # Some stuff to help us draw nice lines
        PR_SET_CHARSET="%{$terminfo[enacs]%}"
        PR_SHIFT_IN="%{$terminfo[smacs]%}"
        PR_SHIFT_OUT="%{$terminfo[rmacs]%}"
        PR_HBAR='$PR_SHIFT_IN${altchar[q]:--}$PR_SHIFT_OUT'
        PR_ULCORNER='$PR_SHIFT_IN${altchar[l]:--}$PR_SHIFT_OUT'
        PR_LLCORNER='$PR_SHIFT_IN${altchar[m]:--}$PR_SHIFT_OUT'
        PR_LRCORNER='$PR_SHIFT_IN${altchar[j]:--}$PR_SHIFT_OUT'
        PR_URCORNER='$PR_SHIFT_IN${altchar[k]:--}$PR_SHIFT_OUT'
     fi


    ###
    # Decide if we need to set titlebar text.

    case $TERM in
	xterm*)
	    PR_TITLEBAR=$'%{\e]0;%(!.-=*[ROOT]*=- | .)%n@%m:%~ | ${COLUMNS}x${LINES} | %y\a%}'
	    ;;
	screen)
	    PR_TITLEBAR=$'%{\e_screen \005 (\005t) | %(!.-=[ROOT]=- | .)%n@%m:%~ | ${COLUMNS}x${LINES} | %y\e\\%}'
	    ;;
	*)
	    PR_TITLEBAR=''
	    ;;
    esac


    ###
    # Decide whether to set a screen title
    if [[ "$TERM" == "screen" ]]; then
	PR_STITLE=$'%{\ekzsh\e\\%}'
    else
	PR_STITLE=''
    fi


    ###
    # Finally, the prompt.

    PROMPT='$PR_SET_CHARSET$PR_STITLE${(e)PR_TITLEBAR}\
$PR_CYAN$PR_ULCORNER$PR_HBAR$PR_GREY(\
$PR_GREEN%$PR_PWDLEN<...<%~%<<\
$PR_GREY)`rvm_prompt_info || rbenv_prompt_info`$PR_CYAN$PR_HBAR$PR_HBAR${(e)PR_FILLBAR}$PR_HBAR$PR_GREY(\
$PR_CYAN%(!.%SROOT%s.%n)$PR_GREY@$PR_GREEN%m:%l\
$PR_GREY)$PR_CYAN$PR_HBAR$PR_URCORNER\

$PR_CYAN$PR_LLCORNER$PR_BLUE$PR_HBAR(\
$PR_YELLOW%D{%H:%M:%S}\
$PR_LIGHT_BLUE%{$reset_color%}`git_prompt_info``git_prompt_status`$PR_BLUE)$PR_CYAN$PR_HBAR\
$PR_HBAR\
>$PR_NO_COLOUR '

    # display exitcode on the right when >0
    return_code="%(?..%{$fg[red]%}%? ↵ %{$reset_color%})"
    RPROMPT=' $return_code$PR_CYAN$PR_HBAR$PR_BLUE$PR_HBAR\
($PR_YELLOW%D{%a,%b%d}$PR_BLUE)$PR_HBAR$PR_CYAN$PR_LRCORNER$PR_NO_COLOUR'

    PS2='$PR_CYAN$PR_HBAR\
$PR_BLUE$PR_HBAR(\
$PR_LIGHT_GREEN%_$PR_BLUE)$PR_HBAR\
$PR_CYAN$PR_HBAR$PR_NO_COLOUR '
}

setprompt

autoload -U add-zsh-hook
add-zsh-hook precmd  theme_precmd
add-zsh-hook preexec theme_preexec
