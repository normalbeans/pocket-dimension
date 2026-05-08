# diralias check on cd

function checkdiralias() {
if [[  -f "$PWD/.diralias" ]];then
        source "$PWD/.diralias"
fi
}
PROMPT_COMMAND="checkdiralias"


function show_git_branch() {
    if  git status > /dev/null 2>&1;then
        printf " \u251c\u2500 $(git branch --show-current)"
    fi
}

PS1='${debian_chroot:+($debian_chroot)}[\[\033[38;2;63;109;78m\]\u\[\033[0m\]@\[\033[38;2;139;212;80m\]\h\[\033[0m\]]\[\033[38;2;150;95;212m\][\W]\[\033[0m\]>\[\033[38;2;236;119;68m\]$(show_git_branch)\[\033[0m\] '
