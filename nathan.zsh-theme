function theme_precmd {
  local TERMWIDTH=$(( COLUMNS - ${ZLE_RPROMPT_INDENT:-1} ))

  PR_FILLBAR=""
  PR_PWDLEN=""

  # %n = username
  # %m = The hostname up to the first ‘.’
  # %l = The line (tty) the user is logged in on

  local promptsize=${#${(%):--(%n)--{}--()}}
  local rubypromptsize=${#${(%)$(ruby_prompt_info)}}
  # ${(%):-%~} = currenlt working directory with ~ instead of $HOME
  local pwdsize=${#${(%):-%~}}
  # prompt IP needs defined in this function to adjust for terminal lenght
  local promptiptotal=${#PROMPTIP} # add this to below function

  # Truncate the path if it's too long.
  if (( promptsize + rubypromptsize + pwdsize + promptiptotal > TERMWIDTH )); then
    (( PR_PWDLEN = TERMWIDTH - promptsize - promptiptotal ))
  elif [[ "${langinfo[CODESET]}" = UTF-8 ]]; then
    PR_FILLBAR="\${(l:$(( TERMWIDTH - (promptsize + rubypromptsize + pwdsize + promptiptotal) ))::${PR_HBAR}:)}"
  else
    PR_FILLBAR="${PR_SHIFT_IN}\${(l:$(( TERMWIDTH - (promptsize + rubypromptsize + pwdsize + promptiptotal) ))::${altchar[q]:--}:)}${PR_SHIFT_OUT}"
  fi
}

function theme_preexec {
  setopt local_options extended_glob
  if [[ "$TERM" = "screen" ]]; then
    local CMD=${1[(wr)^(*=*|sudo|-*)]}
    echo -n "\ek$CMD\e\\"
  fi
}

autoload -U add-zsh-hook
add-zsh-hook precmd  theme_precmd
add-zsh-hook preexec theme_preexec

# Get values for prompt IP
if [[ -d /sys/class/net/tun0 ]]
then
  # print tun0 ip and netmask
  PROMPTIP=$(ip a show tun0 | grep 'inet ' | awk '{ sub(/.*inet /,""); sub(/ .*/, ""); printf; print ":tun0" }')
else
  # print ip for outbound connections
  PROMPTIP=$(ip route get 8.8.8.8 2>/dev/null | awk 'NR==1{ sub(/.*dev /,""); sub(/ uid.*/, ""); printf $3":"; print $1 }')
fi

# Set the prompt

# Need this so the prompt will work.
setopt prompt_subst

# See if we can use colors.
autoload zsh/terminfo
for color in RED GREEN YELLOW BLUE MAGENTA CYAN WHITE GREY; do
  typeset -g PR_$color="%{$terminfo[bold]$fg[${(L)color}]%}"
  typeset -g PR_LIGHT_$color="%{$fg[${(L)color}]%}"
done
PR_NO_COLOUR="%{$terminfo[sgr0]%}"

# Modify Git prompt
ZSH_THEME_GIT_PROMPT_PREFIX=" on %{$fg[green]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY=""
ZSH_THEME_GIT_PROMPT_CLEAN=""

ZSH_THEME_GIT_PROMPT_ADDED="%{$fg[green]%} %{%G✚%}"
ZSH_THEME_GIT_PROMPT_MODIFIED="%{$fg[blue]%} %{%G✹%}"
ZSH_THEME_GIT_PROMPT_DELETED="%{$fg[red]%} %{%G✖%}"
ZSH_THEME_GIT_PROMPT_RENAMED="%{$fg[magenta]%} %{%G➜%}"
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg[yellow]%} %{%G═%}"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[cyan]%} %{%G✭%}"

# Use extended characters to look nicer if supported.
if [[ "${langinfo[CODESET]}" = UTF-8 ]]; then
  PR_SET_CHARSET=""
  PR_HBAR="─"
  PR_ULCORNER="┌"
  PR_LLCORNER="└"
  PR_LRCORNER="┘"
  PR_URCORNER="┐"
else
  typeset -g -A altchar
  set -A altchar ${(s..)terminfo[acsc]}
  # Some stuff to help us draw nice lines
  PR_SET_CHARSET="%{$terminfo[enacs]%}"
  PR_SHIFT_IN="%{$terminfo[smacs]%}"
  PR_SHIFT_OUT="%{$terminfo[rmacs]%}"
  PR_HBAR="${PR_SHIFT_IN}${altchar[q]:--}${PR_SHIFT_OUT}"
  PR_ULCORNER="${PR_SHIFT_IN}${altchar[l]:--}${PR_SHIFT_OUT}"
  PR_LLCORNER="${PR_SHIFT_IN}${altchar[m]:--}${PR_SHIFT_OUT}"
  PR_LRCORNER="${PR_SHIFT_IN}${altchar[j]:--}${PR_SHIFT_OUT}"
  PR_URCORNER="${PR_SHIFT_IN}${altchar[k]:--}${PR_SHIFT_OUT}"
fi

# Decide if we need to set titlebar text.
case $TERM in
  xterm*)
    PR_TITLEBAR=$'%{\e]0;%(!.-=*[ROOT]*=- | .)%n@%m:%~ | ${COLUMNS}x${LINES} | %y\a%}'
    ;;
  screen)
    PR_TITLEBAR=$'%{\e_screen \005 (\005t) | %(!.-=[ROOT]=- | .)%n@%m:%~ | ${COLUMNS}x${LINES} | %y\e\\%}'
    ;;
  *)
    PR_TITLEBAR=""
    ;;
esac

# Decide whether to set a screen title
if [[ "$TERM" = "screen" ]]; then
  PR_STITLE=$'%{\ekzsh\e\\%}'
else
  PR_STITLE=""
fi

# ${PR_CYAN}%(!.%SROOT%s.%n)${PR_GREY}@${PR_GREEN}%m:%l8\ - does something when UUID=0 (i think)
# %(#.💀.㉿) - %(x.true-text.false-text) with # the UUID
# what does ${debian_chroot:+($debian_chroot)──} = if $var is defined and not null; then use 'value'; else do nothing -> To distinguish whether you are in the chroot or not

# Finally, the prompt.
PROMPT='${PR_SET_CHARSET}${PR_STITLE}${(e)PR_TITLEBAR}\
${PR_CYAN}${PR_ULCORNER}${PR_HBAR}${PR_LIGHT_GREEN}\
(%(#.${PR_RED}.${PR_BLUE})%n${PR_LIGHT_GREEN})\
${PR_CYAN}${PR_HBAR}\
${PR_LIGHT_GREEN}{${PR_WHITE}%${PR_PWDLEN}<...<%~%<<${PR_LIGHT_GREEN}}\
$(ruby_prompt_info)${PR_CYAN}${(e)PR_FILLBAR}\
${PR_LIGHT_GREEN}[${PR_YELLOW}$PROMPTIP${PR_LIGHT_GREEN}]${PR_CYAN}${PR_HBAR}\
${PR_CYAN}${PR_URCORNER}\

${PR_CYAN}${PR_LLCORNER}${PR_HBAR}${PR_LIGHT_GREEN}(\
%(#.💀.⚡)%{$reset_color%}$(git_prompt_info)$(git_prompt_status)\
${PR_LIGHT_GREEN})${PR_CYAN}${PR_HBAR}🢒${PR_NO_COLOUR} '

# display exitcode on the right when > 0
return_code="%(?..%{$fg[red]%}%? ↵ %{$reset_color%})"
RPROMPT='$return_code${PR_LIGHT_GREEN}[\
${PR_WHITE}%D{%d-%m}${PR_LIGHT_GREEN} @ ${PR_WHITE}%D{%K:%M}\
${PR_LIGHT_GREEN}]${PR_CYAN}${PR_HBAR}${PR_LRCORNER}${PR_NO_COLOUR}'

PS2='${PR_CYAN}${PR_HBAR}\
${PR_BLUE}${PR_HBAR}(\
${PR_LIGHT_GREEN}%_${PR_BLUE})${PR_HBAR}\
${PR_CYAN}${PR_HBAR}${PR_NO_COLOUR} '

#this resets the prompt every 1 min to keep time up to date
TMOUT=60
TRAPALRM() {
  zle reset-prompt
}
