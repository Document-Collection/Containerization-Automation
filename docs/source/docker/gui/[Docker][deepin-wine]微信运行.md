
# [Docker][deepin-wine]微信运行

通过`deepin-wine`在`Ubuntu 18.04`上运行微信

微信安装包地址：[deepin.com.wechat](https://mirrors.aliyun.com/deepin/pool/non-free/d/deepin.com.wechat/)

完整脚本地址：[wechat](https://github.com/zjZSTU/Containerization-Automation/tree/master/dockerfiles/wechat)

## 安装

编写`Dockerfile`如下：

```
FROM zjzstu/deepin-wine:latest
LABEL maintainer "zhujian <zjzstu@github.com>"

WORKDIR /app
RUN set -eux && \
    apt-get update && \
    apt-get install -y wget ttf-wqy-microhei gosu dbus && \
    gosu nobody true && \
    wget https://mirrors.aliyun.com/deepin/pool/non-free/d/deepin.com.wechat/deepin.com.wechat_2.6.8.65deepin0_i386.deb && \
    useradd -s /bin/bash -m user && \
    chown -R user:user /app && \
    dpkg -i *.deb && \
    rm -f *.deb && \
    apt-get autoclean -y && apt-get clean -y && \
	find /var/lib/apt/lists -type f -delete && \
	find /var/cache -type f -delete && \
	find /var/log -type f -delete && \
	find /usr/share/doc -type f -delete && \
	find /usr/share/man -type f -delete

COPY docker-entrypoint.sh ./
RUN chmod a+x docker-entrypoint.sh && \
	chown user:user docker-entrypoint.sh && \
    ls -al
ENTRYPOINT ["/app/docker-entrypoint.sh"]
```

首先安装中文字体和`gosu`工具；然后设置用户并安装微信，完成后清理多余资源；最后设置入口点程序

入口点程序`docker-entrypoint.sh`实现如下：

```
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
```

* 将用户组`root/音频/视频`加入用户`user`
* 启动`dbus`

微信启动后会断开再自动启动，未防止容器停止结束，参考[bestwu/docker-wechat](https://github.com/bestwu/docker-wechat/blob/master/entrypoint.sh)，通过`sleep`功能保持容器运行

## 构建

```
$ docker build -t zjzstu/wechat:latest .
$ docker image ls
REPOSITORY           TAG                 IMAGE ID            CREATED             SIZE
zjzstu/wechat        latest              9d4352ba37fd        56 seconds ago      954MB
```

## 运行

参考[Ubuntu下使用Tim/Wechat](https://www.gubeiqing.cn/2018/10/27/docker13/?utm_source=tuicool&utm_medium=referral#安装Docker)，将主机音频和视频组`ID`传给容器

微信启动后会在`${HOME}/"WeChat Files"`目录下放置配置信息，将本地`${HOME}/deepin-wine/"WeChat Files"`目录挂载到该位置

```
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
    -v ${HOME}/deepin-wine/"WeChat Files":/home/user/"WeChat Files" \
    --name wechat \
    -d zjzstu/wechat:latest
```

## 可执行脚本

在主机新建脚本`wechat.sh`，统一操作`wechat`的启动

```
#!/bin/bash

COMMAND="/opt/deepinwine/apps/Deepin-WeChat/run.sh"
CONTAINER_NAME="wechat"
IMAGE_NAME="zjzstu/wechat:latest"

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
        -v ${HOME}/deepin-wine/"WeChat Files":/home/user/"WeChat Files" \
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
```

根据`wechat`容器的状态进行不同操作

* 没有wechat容器，新建容器操作
* 正在运行，使用`docker exec`命令启动
* 停止运行，重新启动容器

将其放置在`/usr/local/bin`目录下，即可在任何地方启动

## 菜单启动器

以`docker exec`方式进入容器

获取`/opt/deepinwine/apps/Deepin-WeChat`目录下的`deepin.com.wechat.desktop`文件，修改参数`Exec`，放置到主机`/usr/share/applications/`

```
Exec=/usr/local/bin/wechat
```

获取`/usr/share/icons/hicolor/`目录下的`wechat`图标，放置到主机对应位置

```
# locate deepin.com.wechat | grep icon
/usr/share/icons/hicolor/16x16/apps/deepin.com.wechat.svg
/usr/share/icons/hicolor/24x24/apps/deepin.com.wechat.svg
/usr/share/icons/hicolor/32x32/apps/deepin.com.wechat.svg
/usr/share/icons/hicolor/48x48/apps/deepin.com.wechat.svg
/usr/share/icons/hicolor/64x64/apps/deepin.com.wechat.svg
```

```
# 复制容器图标到主机图标
$ pwd
/usr/share/icons/hicolor
$ sudo cp -r ~/deepin-wine/hicolor/* ./
```

![](./imgs/wechat-starter.png)