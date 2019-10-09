#!/bin/bash

if [ "$(id -u)" -eq '0' ]
then
    USER_ID=${LOCAL_USER_ID:-9001}
    usermod -u ${USER_ID} -g ${USER_ID} -a -G root user  > /dev/null 2>&1
    
    export HOME=/home/user
    exec gosu user "$0" "$@" # > /dev/null 2>&1
fi

exec $@ > /dev/null 2>&1
