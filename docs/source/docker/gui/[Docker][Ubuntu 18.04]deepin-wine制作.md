
# [Docker][Ubuntu 18.04]deepin-wine制作

测试过[wszqkzqk/deepin-wine-ubuntu](https://github.com/wszqkzqk/deepin-wine-ubuntu)提供的`deepin-wine for ubuntu`，但是这里好久没有更新了，安装不了最新的微信。在网上找到文章[ubuntu18.04安装新版deepin-wine环境](https://forum.ubuntu.org.cn/viewtopic.php?f=73&p=3217021&sid=6194a64cefc1f4c5ac43dcd8729ca3c8)，参考其进行`deepin-wine`镜像的制作

## 下载

在主机中新建脚本`deepin.sh`，统一下载`deb`包

```
$ cat deepin.sh 
#!/bin/bash

wget http://mirrors.aliyun.com/deepin/pool/non-free/d/deepin-wine/deepin-wine_2.18-19_all.deb
wget http://mirrors.aliyun.com/deepin/pool/non-free/d/deepin-wine/deepin-wine32_2.18-19_i386.deb
wget http://mirrors.aliyun.com/deepin/pool/non-free/d/deepin-wine/deepin-wine32-preloader_2.18-19_i386.deb
wget http://mirrors.aliyun.com/deepin/pool/non-free/d/deepin-wine-helper/deepin-wine-helper_1.2deepin8_i386.deb
wget http://mirrors.aliyun.com/deepin/pool/non-free/d/deepin-wine-plugin/deepin-wine-plugin_1.0deepin2_amd64.deb
wget http://mirrors.aliyun.com/deepin/pool/non-free/d/deepin-wine-plugin-virtual/deepin-wine-plugin-virtual_1.0deepin3_all.deb
wget http://mirrors.aliyun.com/deepin/pool/non-free/d/deepin-wine-uninstaller/deepin-wine-uninstaller_0.1deepin2_i386.deb
wget http://mirrors.aliyun.com/deepin/pool/non-free/u/udis86/udis86_1.72-2_i386.deb
wget http://mirrors.aliyun.com/deepin/pool/non-free/d/deepin-wine/deepin-fonts-wine_2.18-19_all.deb
wget http://mirrors.aliyun.com/deepin/pool/non-free/d/deepin-wine/deepin-libwine_2.18-19_i386.deb
wget https://mirrors.aliyun.com/deepin/pool/main/libj/libjpeg-turbo/libjpeg62-turbo_1.5.1-2_amd64.deb
wget https://mirrors.aliyun.com/deepin/pool/main/libj/libjpeg-turbo/libjpeg62-turbo_1.5.1-2_i386.deb
```

## 安装

```
# 将保存deepin.sh的目录挂载到容器
$ docker run -it -v /path/to/deep-wine/:/app zjzstu/ubuntu:18.04 bash
```

进入容器后，安装`deep-wine`

```
$ cd app
$ apt-get update && apt-get install wget
$ bash deepin.sh
$ dpkg --add-architecture i386
$ apt update
$ dpkg -i *.deb
$ apt-get install -f -y
```

安装完成后删除多余资源

```
$ apt-get autoclean -y && apt-get clean -y && \
	find /var/lib/apt/lists -type f -delete && \
	find /var/cache -type f -delete && \
	find /var/log -type f -delete && \
	find /usr/share/doc -type f -delete && \
	find /usr/share/man -type f -delete
```

## 制作镜像

将安装好的容器制作成镜像，以备后续软件的安装

```
$ docker commit --author zjzstu --message "deep-wine" ae799 zjzstu/deep-wine:latest
```