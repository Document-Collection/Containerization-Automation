#!/bin/bash

APP="WeChat"
CONTAINER="wechat"

IMAGE="zjzstu/${CONTAINER}:latest"
HOST_STORAGE="${HOME}/deepin-wine/${APP} Files"
CONTAINER_STORAGE="/home/user/${APP} Files"

HOST_CONFIGURE="${HOME}/.deepinwine/Deepin-${APP}"
CONTAINER_CONFIGURE="/home/user/.deepinwine/Deepin-${APP}"

APP_COMMAND="/opt/deepinwine/apps/Deepin-${APP}/run.sh"

function startup()
{
    docker run \
        --device=/dev/snd:/dev/snd \
        -v /tmp/.X11-unix:/tmp/.X11-unix \
        -e DISPLAY=unix${DISPLAY} \
        -e AUDIO_GID=`getent group audio | cut -d: -f3` \
        -e VIDEO_GID=`getent group video | cut -d: -f3` \
        -e GID=`id -g` \
        -e UID=`id -u` \
        -e XMODIFIERS="@im=fcitx" \
        -e QT_IM_MODULE="fcitx" \
        -e GTK_IM_MODULE="fcitx" \
        -v "${HOST_STORAGE}":"${CONTAINER_STORAGE}" \
        -v "${HOST_CONFIGURE}":"${CONTAINER_CONFIGURE}" \
        --name ${CONTAINER} \
        -d ${IMAGE} > /dev/null 2>&1
}

function run()
{
    xhost + > /dev/null 2>&1

    START=$(docker ps -q --filter="name=${CONTAINER}")
    STOP=$(docker ps -aq --filter="name=${CONTAINER}")

    if [ -n "${START}" ]
    then
        docker exec -d -u user $START ${APP_COMMAND} > /dev/null 2>&1
    elif [ -n "${STOP}" ]
    then
        docker restart ${STOP} > /dev/null 2>&1
    else
        startup
    fi
}

function main()
{
	run
    exit "$?"
}

main
