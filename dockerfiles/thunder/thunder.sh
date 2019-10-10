#!/bin/bash

APP="ThunderSpeed"
COMMAND="/opt/deepinwine/apps/Deepin-${APP}/run.sh"
CONTAINER_NAME="thunder"
IMAGE_NAME="zjzstu/thunder:latest"

HOST_FILE_DIR="${HOME}/deepin-wine/${APP} Files"
CONTAINER_FILE_DIR="/home/user/${APP} Files"

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
        -v "${HOST_FILE_DIR}":"${CONTAINER_FILE_DIR}" \
        --name ${CONTAINER_NAME} \
        -d ${IMAGE_NAME} > /dev/null 2>&1
}

function run()
{
    xhost + > /dev/null 2>&1

    START=$(docker ps -q --filter="name=${CONTAINER_NAME}")
    STOP=$(docker ps -aq --filter="name=${CONTAINER_NAME}")

    echo $START
    echo $STOP
    if [ -n "${START}" ]
    then
        docker exec -d -u user $START ${COMMAND} > /dev/null 2>&1
    elif [ -n "${STOP}" ]
    then
        docker restart ${STOP} > /dev/null 2>&1
    else
        echo "startup"
        startup
    fi
}

function main()
{
	run
    exit "$?"
}

main
