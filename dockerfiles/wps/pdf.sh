#!/bin/bash

FINALNAME=
BASENAME="/home/user/Documents"

COMMAND="wpspdf"
COMMAND_NAME="pdf"
IMAGE_NAME="zjzstu/wps:latest"

# 替换主机文件路径为容器路径
function parse_arg()
{
    FILE_DIR=$1

    if [[ ${FILE_DIR} == ./* ]]
    then
        FINALNAME=${PWD}${FILE_DIR#.}
    elif [[ ${FILE_DIR} == ../* ]]
    then
        FINALNAME=`dirname ${PWD}`${FILE_DIR#..}
    elif [[ ${FILE_DIR} == ${HOME}* ]]
    then
        FINALNAME=${FILE_DIR}    
    else
        FINALNAME=${PWD}/${FILE_DIR}
    fi

    FINALNAME=${BASENAME}${FINALNAME#${HOME}}
}

# 启动wps镜像
function startup()
{
    docker run -d \
        -v /tmp/.X11-unix:/tmp/.X11-unix \
        -e DISPLAY=unix${DISPLAY} \
        -e LOCAL_USER_ID=`id -u ${USER}` \
        -e XMODIFIERS="@im=fcitx" \
        -e QT_IM_MODULE="fcitx" \
        -e GTK_IM_MODULE="fcitx" \
        -v ${HOME}:${BASENAME} \
        --name ${COMMAND_NAME} \
        ${IMAGE_NAME} \
        ${COMMAND} ${FINALNAME} > /dev/null 2>&1
}

function run()
{
    xhost + > /dev/null 2>&1

    START=$(docker ps -q --filter="name=${COMMAND_NAME}")
    STOP=$(docker ps -aq --filter="name=${COMMAND_NAME}")

    if [ -n "${START}" ]
    then
        docker exec -u user $START ${COMMAND} $FINALNAME > /dev/null 2>&1
    elif [ -n "${STOP}" ]
    then
        if [ -z ${FINALNAME} ]
        then
            docker restart ${STOP} > /dev/null 2>&1
        else
            docker container rm ${STOP} > /dev/null 2>&1
            startup
        fi
    else
        startup
    fi
}

function main()
{
    NUM=$#
    if [ $NUM -eq 1 ]
    then
    	parse_arg "$@"
    fi

	run "$@"
	exit 0
}

main "$@"