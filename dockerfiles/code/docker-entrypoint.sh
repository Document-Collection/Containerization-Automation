#!/bin/bash

if [ "$(id -u)" -eq '0' ]
then
    USER_ID=${LOCAL_USER_ID:-9001}
 
    usermod -u ${USER_ID} -g ${USER_ID} -a -G root user
    chown -R `id -u user`:`id -u user` /app
 
    export HOME=/home/user
    exec gosu user "$0"
fi

exec /usr/bin/code --verbose