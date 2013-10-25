export PATH="/usr/local/bin:/usr/local/opt/coreutils/libexec/gnubin:$PATH"
export PATH="/usr/local/sbin:$PATH"
export PATH="/Library/Ruby/Gems/1.8/gems:$PATH"
export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"

if [ -f ~/.nvm/nvm.sh ]; then
    . ~/.nvm/nvm.sh
fi

if [ -f /opt/homebrew-cask/Caskroom/google-chrome/stable-channel/Google\ Chrome.app ]; then
    export CHROME_BIN="/opt/homebrew-cask/Caskroom/google-chrome/stable-channel/Google Chrome.app/Contents/MacOS/Google Chrome"
elif [ -f ~/Applications/Google\ Chrome.app ]; then
    export CHROME_BIN="~/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
fi

export LS_COLORS="di=36;40:ln=35;40:so=32;40:pi=33;40:ex=31;40:bd=34;46:cd=34;43:su=0;41:sg=0;46:tw=:ow=:"

source ~/.osx-dev/.aliases
source ~/.osx-dev/.phpswitch
