# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
        color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    #alias grep='grep --color=auto'
    #alias fgrep='fgrep --color=auto'
    #alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
#alias ll='ls -l'
#alias la='ls -A'
#alias l='ls -CF'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

if [ -f $HOME/envs/flask-env/bin/activate ]; then
  . $HOME/envs/flask-env/bin/activate
fi

export FLASK_APP=awsmgr.app

# @TODO: This needs to be moved to a mount/share on cyverse user to preserve things!
export PULUMI_HOME=$HOME/.pulumi
export PULUMI_BACKEND_URL="file:///usr/local/var/pulumi"
export PULUMI_CONFIG_PASSPHRASE=''

pulumi login --local

AWS_ACCOUNT_ID=
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_SESSION_TOKEN=
AWS_DEFAULT_REGION=
AWS_CREDENTIAL_EXPIRATION=
AWS_KMS_KEY=

ECHO_OUTPUT=false

function get_cache_key() {
    ## only works if pymemcache is available / install systemwide
    python -c "from pymemcache.client.base import Client; print(str(Client(('localhost', 11212)).get('$1', b'').decode('utf-8')));"
}

function set_cache_key() {
    ## only works if pymemcache is available / install systemwide
    python -c "from pymemcache.client.base import Client; client = Client(('localhost', 11212)); client.set('$1', '$2'.encode('utf-8'), expire=$3 if len('$3') > 0 else None)"
}

## Load our credentials
function update_aws_temp_token() {
    #@todo: rewrite this!
    had_issue=false
    # _AWS_ACCOUNT_ID=$(echo "get AWS_ACCOUNT_ID" | nc -w 1 localhost 11212 | awk '/^VALUE/{flag=1;next}/^END/{flag=0}flag')
    _AWS_ACCOUNT_ID=$(get_cache_key 'AWS_ACCOUNT_ID')
    if [[ -z ${_AWS_ACCOUNT_ID} ]]; then
      :
    elif [[ ( ! -z ${_AWS_ACCOUNT_ID} ) && ( ( -z $AWS_ACCOUNT_ID ) || ( ${AWS_ACCOUNT_ID} != ${_AWS_ACCOUNT_ID} ) ) ]]; then
        export AWS_ACCOUNT_ID=${_AWS_ACCOUNT_ID}
    fi

    # _AWS_ACCESS_KEY_ID=$(echo "get AWS_ACCESS_KEY_ID" | nc -w 1 localhost 11212 | awk '/^VALUE/{flag=1;next}/^END/{flag=0}flag')
    _AWS_ACCESS_KEY_ID=$(get_cache_key 'AWS_ACCESS_KEY_ID')
    if [[ -z ${_AWS_ACCESS_KEY_ID} ]]; then
      had_issue=true
    elif [[ ( ! -z ${_AWS_ACCESS_KEY_ID} ) && ( ( -z $AWS_ACCESS_KEY_ID ) || ( ${AWS_ACCESS_KEY_ID} != ${_AWS_ACCESS_KEY_ID} ) ) ]]; then
        export AWS_ACCESS_KEY_ID=${_AWS_ACCESS_KEY_ID}
    fi

    # _AWS_SECRET_ACCESS_KEY=$(echo "get AWS_SECRET_ACCESS_KEY" | nc -w 1 localhost 11212 | awk '/^VALUE/{flag=1;next}/^END/{flag=0}flag')
    _AWS_SECRET_ACCESS_KEY=$(get_cache_key 'AWS_SECRET_ACCESS_KEY')
    if [[ -z ${_AWS_SECRET_ACCESS_KEY} ]]; then
      had_issue=true
    elif [[ ( ! -z ${_AWS_SECRET_ACCESS_KEY} ) && ( ( -z $AWS_SECRET_ACCESS_KEY ) || ( ${AWS_SECRET_ACCESS_KEY} != ${_AWS_SECRET_ACCESS_KEY} ) ) ]]; then
        export AWS_SECRET_ACCESS_KEY=${_AWS_SECRET_ACCESS_KEY}
    fi

    # _AWS_SESSION_TOKEN=$(echo "get AWS_SESSION_TOKEN" | nc -w 1 localhost 11212 | awk '/^VALUE/{flag=1;next}/^END/{flag=0}flag')
    _AWS_SESSION_TOKEN=$(get_cache_key 'AWS_SESSION_TOKEN')
    if [[ -z ${_AWS_SESSION_TOKEN} ]]; then
      had_issue=true
    elif [[ ( ! -z ${_AWS_SESSION_TOKEN} ) && ( ( -z $AWS_SESSION_TOKEN ) || ( ${AWS_SESSION_TOKEN} != ${_AWS_SESSION_TOKEN} ) ) ]]; then
        export AWS_SESSION_TOKEN=${_AWS_SESSION_TOKEN}
    fi

    # _AWS_DEFAULT_REGION=$(echo "get AWS_DEFAULT_REGION" | nc -w 1 localhost 11212 | awk '/^VALUE/{flag=1;next}/^END/{flag=0}flag')
    _AWS_DEFAULT_REGION=$(get_cache_key 'AWS_DEFAULT_REGION')
    if [[ -z ${_AWS_DEFAULT_REGION} ]]; then
      :
    elif [[ ( ! -z ${_AWS_DEFAULT_REGION} ) && ( ( -z $AWS_DEFAULT_REGION ) || ( ${AWS_DEFAULT_REGION} != ${_AWS_DEFAULT_REGION} ) ) ]]; then
        export AWS_DEFAULT_REGION=${_AWS_DEFAULT_REGION}
    fi

    # _AWS_CREDENTIAL_EXPIRATION=$(echo "get AWS_CREDENTIAL_EXPIRATION" | nc -w 1 localhost 11212 | awk '/^VALUE/{flag=1;next}/^END/{flag=0}flag')
    _AWS_CREDENTIAL_EXPIRATION=$(get_cache_key 'AWS_CREDENTIAL_EXPIRATION')
    if [[ -z ${_AWS_CREDENTIAL_EXPIRATION} ]]; then
      :
    elif [[ ( ! -z ${_AWS_CREDENTIAL_EXPIRATION} ) && ( ( -z $AWS_CREDENTIAL_EXPIRATION ) || ( ${AWS_CREDENTIAL_EXPIRATION} != ${_AWS_CREDENTIAL_EXPIRATION} ) ) ]]; then
        export AWS_CREDENTIAL_EXPIRATION=${_AWS_CREDENTIAL_EXPIRATION}
    fi

    # _AWS_KMS_KEY=$(echo "get AWS_KMS_KEY" | nc -w 1 localhost 11212 | awk '/^VALUE/{flag=1;next}/^END/{flag=0}flag')
    _AWS_KMS_KEY=$(get_cache_key 'AWS_KMS_KEY')
    _AWS_KMS_KEY=$(get_cache_key 'AWS_KMS_KEY')
    if [[ -z ${_AWS_KMS_KEY} ]]; then
      :
    elif [[ ( ! -z ${_AWS_KMS_KEY} ) && ( ( -z $AWS_KMS_KEY ) || ( ${AWS_KMS_KEY} != ${_AWS_KMS_KEY} ) ) ]]; then
        export AWS_KMS_KEY=${_AWS_KMS_KEY}
    fi

    ### API GATEWAY STUFF

    _APIGATEWAY_NAME=$(get_cache_key 'APIGATEWAY_NAME')
    if [ ! -z ${APIGATEWAY_NAME} ]; then
      $ECHO_OUTPUT && echo "Using memcached APIGATEWAY_NAME = '${_APIGATEWAY_NAME}'"
      export APIGATEWAY_NAME=${_APIGATEWAY_NAME}
    else
      $ECHO_OUTPUT && >&2 echo "WARNING 'APIGATEWAY_NAME' not a key found in memcached!"
    fi

    ## using aws cli pull down the api key?
    # If APIGATEWAY_ID is set, use that
    _APIGATEWAY_ID=$(get_cache_key 'APIGATEWAY_ID')
    if [ ! -z ${_APIGATEWAY_ID} ]; then
      $ECHO_OUTPUT && echo "Using memcached APIGATEWAY_ID = '${_APIGATEWAY_ID}'"
      export APIGATEWAY_ID=${_APIGATEWAY_ID}
    else
      if [ ! -z ${APIGATEWAY_NAME} ]; then
        export APIGATEWAY_ID=$(aws apigateway get-rest-apis | jq -r -c ".items[] | if .name == \"${APIGATEWAY_NAME}\" then .id else empty end")
        if [[ $? -eq 0 ]] && [[ ! -z ${APIGATEWAY_ID} ]]; then
          set_cache_key 'APIGATEWAY_ID' ${APIGATEWAY_ID} 0
          $ECHO_OUTPUT && echo "Captured APIGATEWAY_ID = '$APIGATEWAY_ID'"
        else
          $ECHO_OUTPUT && echo "WARNING: couldn't determin APIGATEWAY_ID for gateway '${APIGATEWAY_NAME}'"
        fi
      fi
    fi

    _APIKEY_ID=$(get_cache_key 'APIKEY_ID')
    if [ ! -z ${_APIKEY_ID} ]; then
      $ECHO_OUTPUT && echo "Using memcached APIKEY_ID = ${_APIKEY_ID}"
      export APIKEY_ID=${_APIKEY_ID}
    else
      if [ ! -z ${APIGATEWAY_API_KEY_NAME} ]; then
        export APIKEY_ID=$(aws apigateway get-api-keys --name-query "${APIGATEWAY_API_KEY_NAME}" $@ | jq -r -c '.items[0].id')
        if [[ $? -eq 0 ]]  && [[ ! -z ${APIKEY_ID} ]]; then
          set_cache_key 'APIKEY_ID' ${APIKEY_ID} 0
          $ECHO_OUTPUT && echo "Captured APIKEY_ID = '${APIKEY_ID}'"
        else
          $ECHO_OUTPUT && echo "WARNING: couldn't determin APIKEY_ID for gateway '${APIGATEWAY_API_KEY_NAME}'"
        fi
      fi
    fi

    _APIKEY_VALUE=$(get_cache_key 'APIKEY_VALUE')
    if [ ! -z ${_APIKEY_VALUE} ]; then
      $ECHO_OUTPUT && echo "Using memcached APIKEY_ID = ${_APIKEY_VALUE}"
      export APIKEY_VALUE=${_APIKEY_VALUE}
    else
      if [ ! -z ${APIKEY_ID} ]; then
        export APIKEY_VALUE=$(aws apigateway get-api-key --api-key $APIKEY_ID --include-value | jq -r -c '.value')
        if [[ $? -eq 0 ]]  && [[ ! -z ${APIKEY_VALUE} ]]; then
          set_cache_key 'APIKEY_VALUE' ${APIKEY_VALUE} 0
          $ECHO_OUTPUT && echo "Captured APIKEY_VALUE = '${APIKEY_VALUE}'"
        else
          $ECHO_OUTPUT && echo "WARNING: couldn't determin APIKEY_VALUE for gateway '${APIKEY_ID}'"
        fi
      fi
    fi

    # _AWS_DEFAULT_PROFILE=$(echo "get AWS_DEFAULT_PROFILE" | nc -w 1 localhost 11212 | awk '/^VALUE/{flag=1;next}/^END/{flag=0}flag')
    # _AWS_DEFAULT_PROFILE=$(get_cache_key 'AWS_DEFAULT_PROFILE')
    # if [[ -z ${_AWS_DEFAULT_PROFILE} ]]; then
    #   had_issue=true
    # elif [[ ( ! -z ${_AWS_DEFAULT_PROFILE} ) && ( ( -z $AWS_DEFAULT_PROFILE ) || ( ${AWS_DEFAULT_PROFILE} != ${_AWS_DEFAULT_PROFILE} ) ) ]]; then
    #     export AWS_DEFAULT_PROFILE=${_AWS_DEFAULT_PROFILE}
    # fi

    if [[ $had_issue == true ]]; then
      $ECHO_OUTPUT && echo "AWS_ACCESS_KEY_ID = $AWS_ACCESS_KEY_ID"
      $ECHO_OUTPUT && echo "AWS_CREDENTIAL_EXPIRATION = $AWS_CREDENTIAL_EXPIRATION"
      $ECHO_OUTPUT && >&2 echo "ERROR: Issues while reading memcached!"
    else
      $ECHO_OUTPUT && echo "AWS_ACCOUNT_ID = $AWS_ACCOUNT_ID"
      $ECHO_OUTPUT && echo "AWS_ACCESS_KEY_ID = $AWS_ACCESS_KEY_ID"
      $ECHO_OUTPUT && echo "AWS_DEFAULT_REGION = $AWS_DEFAULT_REGION"
      $ECHO_OUTPUT && echo "AWS_CREDENTIAL_EXPIRATION = $AWS_CREDENTIAL_EXPIRATION"
      $ECHO_OUTPUT && echo ""
      $ECHO_OUTPUT && echo "APIGATEWAY_NAME = $APIGATEWAY_NAME"
      $ECHO_OUTPUT && echo "APIGATEWAY_ID = $APIGATEWAY_ID"
      $ECHO_OUTPUT && echo "APIKEY_ID = $APIKEY_ID"
    fi
}

ECHO_OUTPUT=true && update_aws_temp_token