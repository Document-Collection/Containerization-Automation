# [Docker]GUI最佳实践

通过`Docker`运行`GUI`，能够实现`compile once, run everywhere`的效果，也有助于理清不同软件之间的依赖问题

运行`GUI`软件的困难在于如何利用主机的各种硬件，以及如何显示图形界面。主要包含以下几个方面

1. 图形界面
2. 存储
3. 音频/视频
4. 网络
5. 中文支持

## 图形界面

参考：

[【微信分享】林帆：Docker运行GUI软件的方法](https://www.csdn.net/article/2015-07-30/2825340)

[Docker容器图形界面显示（运行GUI软件）的配置方法](https://blog.csdn.net/ericcchen/article/details/79253416)

`Docker`官方提供的`Ubuntu`镜像都是没有图形界面服务的。需要在容器中安装[X11(X Window System)](https://baike.baidu.com/item/X11/10166334?fr=aladdin)，然后将主机`DISPLAY`环境变量传入容器，即可实现容器`GUI`软件的显示

分为两种情况支持，

* 一是将本地容器中运行
* 二是在远程服务器容器中运行

### 本地运行

其实现方式如下：

> [应用程序]->[X11客户端]->[X11服务端]->[显示屏幕]

其中容器是客户端，主机是服务端。通过主机和容器共享套接字`unix:0`，实现容器`GUI`软件显示在本地

实现如下：

```
$ docker run \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -e DISPLAY=unix$DISPLAY \
    ...
```

`X11`服务默认只允许来自`本地用户`启动的图形程序将图形显示在当前屏幕上，所以在启动之前还需安装`xhost`命令，允许所有用户访问

```
$ sudo apt-get install x11-xserver-utils
$ xhost +
access control disabled, clients can connect from any host
```

### 远程运行

。。。

## 存储

通常`GUI`软件会应用到本地文件，所以还需要实现主机和容器共享文件。可以通过`绑定挂载`方式，将主机目录挂载到容器中，主机和容器均可对文件进行操作

需要注意的地方是`文件权限`，默认容器按`root`用户登录，在容器中创建的文件均是`root`属性，不易于主机普通用户操作

可以创建一个普通用户`user`，在容器启动时切换到用户`user`执行，同时传入主机当前用户的`UID`和`GID`，修改容器`user`的属性，保证挂载后不改变
挂载点的文件属性（**很重要**）

在`Dockerfile`文件中

```
# 创建用户user
RUN useradd -s /bin/bash -m user
# 指定启动项docker-entrypoint.sh
COPY docker-entrypoint.sh ./
RUN chmod a+x docker-entrypoint.sh && \
	chown user:user docker-entrypoint.sh
ENTRYPOINT ["/app/docker-entrypoint.sh"]
```

启动容器时指定运行`docker-entrypoing.sh`

```
#!/bin/bash

# 判断当前用户是否是`root`
if [ "$(id -u)" -eq '0' ]
then
    # 获取用户传入的UID/GID
    UID=${UID:-9001}
    GID=${GID:-9001}
    # 修改user属性音频
    usermod -u ${UID} -g ${GID} -a -G root user  > /dev/null 2>&1
    
    export HOME=/home/user
    chown -R ${UID}:${GID} ${HOME} > /dev/null 2>&1
    # 使用工具gosu切换当前用户为user，并重新执行docker-entrypoint.sh
    exec gosu user "$0" "$@"
fi

# 以user身份执行
exec "$@"
```

通过用户的创建和属性的修改，能够保证挂载点的文件属性不发生改变

## 音频/视频

容器默认无法使用主机硬件，所以对于某些软件需要使用音频/视频等设备需要额外添加参数

可以在启动时指定容器要访问的设备，传入相应硬件组`ID`，比如

```
# 查询主机组ID
$ cat /etc/group | grep audio
audio:x:29:pulse
$ cat /etc/group | grep video
video:x:44:

# 访问音频
$ docker run --device /dev/snd:/dev/snd -e AUDIO_ID=`getent group audio | cut -d: -f3` ...
# 访问视频
$ docker run --device /dev/video0:/dev/video0 -e VIDEO_GID=`getent group video | cut -d: -f3` ...
```

如果出现以下错误信息，很有可能容器还是无法正确使用硬件

```
libGL error: MESA-LOADER: failed to retrieve device information
libGL error: Version 4 or later of flush extension not found
libGL error: failed to load driver: i915
libGL error: failed to open drm device: No such file or directory
libGL error: failed to load driver: i965
```

参数`--privileged`表示容器可以使用主机所有硬件设备

```
$ docker run --privileged ...
```

所以加入`--privileged`就可以了

## 网络

。。。

## 中文支持

中文支持包括`4`个方面，

* 中文字符集
* 中文字体
* 时区
* 中文输入法

参考[[locale]字符集设置](https://zj-linux-guide.readthedocs.io/zh_CN/latest/tool-install-configure/[LOCALE]%E5%AD%97%E7%AC%A6%E9%9B%86%E8%AE%BE%E7%BD%AE/)设置`zh_CN.UTF-8`

出现中文乱码时，参考[[Ubuntu]中文乱码](https://zj-linux-guide.readthedocs.io/zh_CN/latest/tool-install-configure/[Ubuntu]%E4%B8%AD%E6%96%87%E4%B9%B1%E7%A0%81/)安装中文字体;

```
sudo apt-get install ttf-wqy-microhei   #文泉驿-微米黑
```

中国处于东八区，和默认时区相差`8`个小时，参考[[localtime]设置时区](https://zj-linux-guide.readthedocs.io/zh_CN/latest/tool-install-configure/[localtime]%E8%AE%BE%E7%BD%AE%E6%97%B6%E5%8C%BA/)进行设置

关于中文输入法使用，在容器启动时设置环境变量即可

```
docker run \
        -e XMODIFIERS="@im=fcitx" \
        -e QT_IM_MODULE="fcitx" \
        -e GTK_IM_MODULE="fcitx" \
```

## 小结

参考[wszqkzqk/deepin-wine-ubuntu](https://github.com/wszqkzqk/deepin-wine-ubuntu)和[Peter Wu](https://github.com/bestwu)实现了`Docker Deepin-Wine`的`Windows`软件运行

[jessfraz/dockerfiles](https://github.com/jessfraz/dockerfiles)也提供了许多软件实现的参考

`Docker Hub`地址：[zjzstu](https://hub.docker.com/u/zjzstu)

当前实现：

* [code](https://github.com/zjZSTU/Containerization-Automation/tree/master/dockerfiles/code)
* [wps](https://github.com/zjZSTU/Containerization-Automation/tree/master/dockerfiles/wps)
* [wechat](https://github.com/zjZSTU/Containerization-Automation/tree/master/dockerfiles/wechat)
* [qq](https://github.com/zjZSTU/Containerization-Automation/tree/master/dockerfiles/qq)
* [thunder](https://github.com/zjZSTU/Containerization-Automation/tree/master/dockerfiles/thunder)