#!/bin/bash

xhost + > /dev/null

START=$(docker ps -q --filter="name=et")
STOP=$(docker ps -aq --filter="name=et")

if [ -n "${START}" ]
then
    docker exec -u user $START et > /dev/null
elif [ -n "${STOP}" ]
then
    docker restart ${STOP} > /dev/null
else
    docker run -d \
        -v /tmp/.X11-unix:/tmp/.X11-unix \
        -e DISPLAY=unix$DISPLAY \
        -e LOCAL_USER_ID=`id -u $USER` \
        -e XMODIFIERS="@im=fcitx" \
	    -e QT_IM_MODULE="fcitx" \
    	-e GTK_IM_MODULE="fcitx" \
        -v $HOME/docs:/home/user/Documents \
        --name et \
        zjzstu/wps:latest \
        et > /dev/null
fi
