# diralias check on cd

function checkdiralias() {
if [[  -f "$PWD/.diralias" ]];then
        source "$PWD/.diralias"
fi
}
PROMPT_COMMAND="checkdiralias"


