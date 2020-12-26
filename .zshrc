export LANG='ja_JP.UTF-8'

autoload -Uz compinit && compinit
autoload -Uz vcs_info
setopt prompt_subst

source ~/.git-flow-completion.zsh

zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr " %F{green}uncommitted%f"
zstyle ':vcs_info:git:*' unstagedstr " %F{red}unstaged%f"
zstyle ':vcs_info:*' formats ' %F{yellow}[%b]%c%u%f'
zstyle ':vcs_info:*' actionformats ' [%b|%a]'

has_unpushed_file () {
    [[ $(ls -a | grep -E ^'.git'$ 2> /dev/null) = '' ]] && return;

    local rmt=$(git remote)
    if [ $rmt 2> /dev/null != '' ]; then
        local head=$(git rev-parse HEAD)
        local remote
        for remote in $(git rev-parse --remotes); do
            if [ $head = $remote ]; then return 0; fi
        done

        echo ' %F{005}unpushed%f'
    fi
}

has_stash_file () {
    [[ $(ls -a | grep -E ^'.git'$ 2> /dev/null) = '' ]] && return;

    local stash=$(git stash list)
    if [ $stash 2> /dev/null != '' ]; then
        echo ' %F{011}stash%f'
    fi
}

title () { export TITLE_OVERRIDDEN=1; echo -en '\e]0;$*\a' }
autotitle () { export TITLE_OVERRIDDEN=0 }; autotitle
overridden () { [[ $TITLE_OVERRIDDEN == 1 ]]; }

gitDirty () {
    [[ $(git status 2> /dev/null | grep -o '\w\+' | tail -n1) != ('clean'|'') ]] && echo '*'
}

precmd () {
    vcs_info

    if overridden; then return; fi
    cwd=${$(pwd)##*/}
    print -Pn "\e]0;$cwd\a"
}

preexec () {
    if overridden; then return; fi
    printf "\033]0;%s\a" "${1%% *} | $cwd$(gitDirty)"
}

unsetopt PROMPT_SP

PROMPT='%F{080}%C%f${vcs_info_msg_0_}$(has_unpushed_file)$(has_stash_file) $
'
