#!/bin/bash

COMMAND="/opt/deepinwine/apps/Deepin-QQ/run.sh"
CONTAINER_NAME="qq"
IMAGE_NAME="zjzstu/qq:latest"

# 启动wechat镜像
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
        -v ${HOME}/deepin-wine/"Tencent Files":/home/user/"Tencent Files" \
        --name ${CONTAINER_NAME} \
        -d ${IMAGE_NAME} > /dev/null 2>&1
}

function run()
{
    xhost + > /dev/null 2>&1

    START=$(docker ps -q --filter="name=${CONTAINER_NAME}")
    STOP=$(docker ps -aq --filter="name=${CONTAINER_NAME}")

    if [ -n "${START}" ]
    then
        docker exec -d -u user $START ${COMMAND} > /dev/null 2>&1
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
