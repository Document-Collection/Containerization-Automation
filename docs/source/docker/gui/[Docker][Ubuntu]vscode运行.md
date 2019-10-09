
# [Docker][Ubuntu]vscode运行

参考：

[sshcode](https://github.com/cdr/sshcode)

[code-server](https://github.com/cdr/code-server)

[WSL下使用VcXsrv启动chromium browser及常见错误解析 (ubuntu18.04， 图形界面)](https://www.cnblogs.com/freestylesoccor/articles/9630758.html)

[解决 canberra-gtk-module 加载失败的问题](https://blog.csdn.net/Longyu_wlz/article/details/85254588)

[VSCode: There is no Pip installer available in the selected environment](https://stackoverflow.com/questions/50993566/vscode-there-is-no-pip-installer-available-in-the-selected-environment)

[Visual Studio Code on Linux](https://code.visualstudio.com/docs/setup/linux)

尝试将`vscode`安装在`Docker`容器上

## 安装

`Dockerfile`文件如下：

```
FROM zjzstu/ubuntu:18.04
LABEL maintainer "zhujian <zjzstu@github.com>"

WORKDIR /app

RUN set -eux && \
	apt-get update && \
	apt-get install -y libnotify4 libnss3 libxkbfile1 libsecret-1-0 libgtk-3-0 libxss1 libx11-xcb1 libasound2 ttf-wqy-microhei python3-pip curl wget gosu && \
	# verify that the binary works
	gosu nobody true && \
	# 下载安装包
	wget https://vscode.cdn.azure.cn/stable/b37e54c98e1a74ba89e03073e5a3761284e3ffb0/code_1.38.1-1568209190_amd64.deb && \
	# 新建用户user，并修改安装包属主/属组
	useradd -s /bin/bash -m user && \
	chown -R user:user /app && \
	chmod a+x *.deb && \
	dpkg -i code_1.38.1-1568209190_amd64.deb && \
	apt-get install -f -y && \
	# 删除
	rm code*.deb && \ 
	apt-get autoclean -y && apt-get clean -y && \
	find /var/lib/apt/lists -type f -delete && \
	find /var/cache -type f -delete && \
	find /var/log -type f -delete && \
	find /usr/share/doc -type f -delete && \
	find /usr/share/man -type f -delete

COPY docker-entrypoint.sh ./
RUN chmod a+x docker-entrypoint.sh && \
	chown user:user docker-entrypoint.sh
ENTRYPOINT ["/app/docker-entrypoint.sh"]
```

`docker-entrypoint.sh`文件如下：

```
#!/bin/bash

if [ "$(id -u)" -eq '0' ]
then
    USER_ID=${LOCAL_USER_ID:-9001}
    usermod -u ${USER_ID} -g ${USER_ID} -a -G root user  > /dev/null 2>&1
    
    export HOME=/home/user
    exec gosu user "$0" "$@" # > /dev/null 2>&1
fi

exec $@ > /dev/null 2>&1
```

## 构建

```
$ docker build -t zjzstu/code:latest .
$ docker image ls
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
zjzstu/code         latest              98713ff00a35        15 minutes ago      772MB
```

## 运行

```
$ docker run \
    --device=/dev/snd:/dev/snd \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -e DISPLAY=unix${DISPLAY} \
    -e LOCAL_USER_ID=`id -u ${USER}` \
    -e XMODIFIERS="@im=fcitx" \
    -e QT_IM_MODULE="fcitx" \
    -e GTK_IM_MODULE="fcitx" \
    -v ${HOME}/docs:/home/user/docs \
    --name code \
    -d zjzstu/code:latest \
    /usr/share/code/code > /dev/null 2>&1
```

## 问题

通过`docker exec`进入容器，可以在命令行输入和显示中文

在`vscode`中可以显示中文，但无法使用中文输入法