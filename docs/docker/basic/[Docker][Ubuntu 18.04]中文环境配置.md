
# [Docker][Ubuntu 18.04]中文环境配置

当前使用`Docker Ubuntu 18.04`镜像，对官方镜像进行进一步配置以适应中文开发环境。有以下几个方面：

1. 镜像源
2. 中文字体
3. 中文字符集
4. 时区
5. 中文输入法

## 镜像源

参考[[Ali mirror]更换国内源](https://zj-linux-guide.readthedocs.io/zh_CN/latest/tool-install-configure/[Ali%20mirror]]%E6%9B%B4%E6%8D%A2%E5%9B%BD%E5%86%85%E6%BA%90/)

## 中文字体

参考：[[Ubuntu]中文乱码](https://zj-linux-guide.readthedocs.io/zh_CN/latest/tool-install-configure/[Ubuntu]%E4%B8%AD%E6%96%87%E4%B9%B1%E7%A0%81/)

## zh_CN.UTF_8字符集设置

参考[[Linux][locale]字符集设置](https://zj-linux-guide.readthedocs.io/zh_CN/latest/tool-install-configure/[LOCALE]%E5%AD%97%E7%AC%A6%E9%9B%86%E8%AE%BE%E7%BD%AE/)

## 时区设置

参考：

[Synchronize timezone from host to container](https://forums.docker.com/t/synchronize-timezone-from-host-to-container/39116)

[apt-get install tzdata noninteractive](https://stackoverflow.com/questions/44331836/apt-get-install-tzdata-noninteractive)

`Docker Ubuntu 18.04`默认的时区和亚洲 - 上海时区相差`8`个小时（东八区）

在`Dockerfile`中增加以下命令

```
ENV DEBIAN_FRONTEND=noninteractive
RUN	ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN	apt-get install -y tzdata && dpkg-reconfigure --frontend noninteractive tzdata
```

还有一种方式是在使用`docker run`命令时同步主机时区

```
$ docker run -v /etc/localtime:/etc/localtime:ro ...
```

## 中文输入法

在主机安装了`fcitx`中文输入法 - `google-pinyin`，在启动容器时配置

```
docker run \
        -e XMODIFIERS="@im=fcitx" \
        -e QT_IM_MODULE="fcitx" \
        -e GTK_IM_MODULE="fcitx" \
		...
		...
```

## 编辑

`Dockerfile`脚本如下：

```
FROM ubuntu:18.04
LABEL maintainer "zhujian <zjzstu@github.com>"

COPY sources.list .
ENV DEBIAN_FRONTEND=noninteractive
RUN set -eux && \
	rm /etc/apt/sources.list && \
	mv sources.list /etc/apt/sources.list && \
	apt-get update && \
	apt-get install -y locales tzdata xfonts-wqy && \
	locale-gen zh_CN.UTF-8 && \
	update-locale LANG=zh_CN.UTF-8 LANGUAGE=zh_CN.UTF-8 LC_ALL=zh_CN.UTF-8 && \
	ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
	dpkg-reconfigure --frontend noninteractive tzdata && \
    find /var/lib/apt/lists -type f -delete && \
    find /var/cache -type f -delete

ENV LANG=zh_CN.UTF-8 LANGUAGE=zh_CN.UTF-8 LC_ALL=zh_CN.UTF-8
```

* 加载`docker`官方镜像`ubuntu:18.04`
* 复制源配置文件`sources.list`到镜像
* 替换源配置文件并更新安装列表，设置中文字体、设置`zh_CN.UTF-8`并删除额外文件
* 设置字符集环境变量

## 构建

```
$ docker build -t zjzstu/ubuntu:18.04 -t zjzstu/ubuntu:latest .
```

## 使用

```
$ docker run \
	-e XMODIFIERS="@im=fcitx" \
	-e QT_IM_MODULE="fcitx"  \
	-e GTK_IM_MODULE="fcitx" \
	-it --rm  \
	--name ubuntu \
	zjzstu/ubuntu:18.04-zh \
	bash
```