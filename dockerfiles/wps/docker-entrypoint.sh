#!/bin/bash

if [ "$(id -u)" -eq '0' ]
then
    USER_ID=${LOCAL_USER_ID:-9001}
 
    chown -R ${USER_ID} /app
    usermod -u ${USER_ID} user
    usermod -a -G root user
 
    export HOME=/home/user
    exec gosu user "$0" "$@"
fi

exec "$@"