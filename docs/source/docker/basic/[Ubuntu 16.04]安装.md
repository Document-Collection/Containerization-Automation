# [Ubuntu 16.04]安装

参考：[Get Docker CE for Ubuntu](https://docs.docker.com/install/linux/docker-ce/ubuntu)

## 先决条件

支持`64`位`Ubuntu`版本

* `Cosmic 18.10`
* `Bionic 18.04 (LTS)`
* `Xenial 16.04 (LTS)`

支持架构

* `x86_64`
* `amd64`
* `armhf`
* `s390x(IBM Z)`
* `ppc64le(IBM Power)`

## 安装

`docker`提供了`3`种方式

1. 设置`docker`仓库再安装
2. 下载`deb`包安装（适合不联网状态）
3. 脚本安装

下面介绍第一种方式

### 安装仓库

    $ sudo apt-get update
    $ sudo apt-get install \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg-agent \
        software-properties-common
    $ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

可以验证是否设置成功

    $ sudo apt-key fingerprint 0EBFCD88

    pub   4096R/0EBFCD88 2017-02-22
        Key fingerprint = 9DC8 5822 9FC7 DD38 854A  E2D8 8D81 803C 0EBF CD88
    uid                  Docker Release (CE deb) <docker@docker.com>
    sub   4096R/F273FCD8 2017-02-22

安装

    $ sudo add-apt-repository \
        "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) \
        stable"

### 安装docker ce

    $ sudo apt-get update
    $ sudo apt-get install docker-ce docker-ce-cli containerd.io

    $ sudo docker version
     
    Client:
    Version:           18.09.1
    API version:       1.39
    Go version:        go1.10.6
    Git commit:        4c52b90
    Built:             Wed Jan  9 19:35:23 2019
    OS/Arch:           linux/amd64
    Experimental:      false

    Server: Docker Engine - Community
    Engine:
    Version:          18.09.1
    API version:      1.39 (minimum version 1.12)
    Go version:       go1.10.6
    Git commit:       4c52b90
    Built:            Wed Jan  9 19:02:44 2019
    OS/Arch:          linux/amd64
    Experimental:     false

### 测试

    $ sudo docker run hello-world

    Hello from Docker!
    This message shows that your installation appears to be working correctly.

    To generate this message, Docker took the following steps:
    1. The Docker client contacted the Docker daemon.
    2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
        (amd64)
    3. The Docker daemon created a new container from that image which runs the
        executable that produces the output you are currently reading.
    4. The Docker daemon streamed that output to the Docker client, which sent it
        to your terminal.

    To try something more ambitious, you can run an Ubuntu container with:
    $ docker run -it ubuntu bash

    Share images, automate workflows, and more with a free Docker ID:
    https://hub.docker.com/

    For more examples and ideas, visit:
    https://docs.docker.com/get-started/

测试命令启动了一个名为`hello-world`的镜像，输出的消息介绍了`docker`实现流程

1. `docker`客户端联系`docker`守护进程
2. `docker`守护进程从`docker hub`中拉取`hello-world`镜像
3. `docker`守护进程使用该镜像创建一个容器，运行里面的可执行文件，生成当前输出的消息
4. `docker`守护进程将该输出流向`docker`客户端，即打印在终端

## 升级

重复上面的安装命令，默认搜索最新版本进行安装

    $ sudo apt-get update
    $ sudo apt-get install docker-ce docker-ce-cli containerd.io

## 卸载

    $ sudo apt-get purge docker-ce
    $ sudo rm -rf /var/lib/docker