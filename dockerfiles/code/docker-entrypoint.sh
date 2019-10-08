#!/bin/bash

if [ "$(id -u)" -eq '0' ]
then
    USER_ID=${LOCAL_USER_ID:-9001}
 
    usermod -u ${USER_ID} -g ${USER_ID} -a -G root user
    chown -R `id -u user`:`id -g user` /app
 
    service dbus start
    export HOME=/home/user
    exec gosu user "$0" "$@"
fi

exec $@
