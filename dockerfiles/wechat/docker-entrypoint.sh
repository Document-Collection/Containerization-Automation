#!/bin/bash

if [ "$(id -u)" -eq '0' ]
then
    UID=${UID:-9001}
    GID=${GID:-9001}
    AUDIO_GID=${AUDIO_GID:-9002}
    VIDEO_GID=${VIDEO_GID:-9003}
    id
    usermod -u ${UID} -g ${GID} -a -G root,${AUDIO_GID},${VIDEO_GID} user  > /dev/null 2>&1
    
    source dbus start > /dev/null 2>&1
    export HOME=/home/user
    chown -R ${UID}:${GID} ${HOME} > /dev/null 2>&1
    exec gosu user "$0" "$@"
fi

/opt/deepinwine/apps/Deepin-WeChat/run.sh > /dev/null 2>&1
sleep 30s

while test -n "`pidof WeChat.exe`"
do
    sleep 1s
done
exit "$?"