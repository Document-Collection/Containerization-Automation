
# [Docker][Ubuntu 18.04]中文环境配置

当前主要使用`docker Ubuntu 18.04`镜像，需要对官方镜像进行进一步配置以适应中文开发环境

## 阿里源替换

参考[[Ali mirror]更换国内源](https://zj-linux-guide.readthedocs.io/zh_CN/latest/configure/[Ali%20mirror]]%E6%9B%B4%E6%8D%A2%E5%9B%BD%E5%86%85%E6%BA%90.html)

## zh_CN.UTF_8字符集设置

参考[[Linux][locale]字符集设置](https://zj-linux-guide.readthedocs.io/zh_CN/latest/configure/[Linux][locale]%E5%AD%97%E7%AC%A6%E9%9B%86%E8%AE%BE%E7%BD%AE.html)

## 编辑

`Dockerfile`脚本如下：

```
FROM ubuntu:18.04
LABEL maintainer "zhujian <zjzstu@github.com>"

COPY sources.list .
RUN mv sources.list /etc/apt/sources.list && \
	apt-get update && \
	apt-get install -y locales && \
	locale-gen zh_CN.UTF-8 && \
	update-locale LANG=zh_CN.UTF-8 LANGUAGE=zh_CN.UTF-8 LC_ALL=zh_CN.UTF-8 && \
    find /var/lib/apt/lists -type f -delete && \
    find /var/cache -type f -delete

ENV LANG=zh_CN.UTF-8 LANGUAGE=zh_CN.UTF-8 LC_ALL=zh_CN.UTF-8
```

* 加载`docker`官方镜像`ubuntu:18.04`
* 复制源配置文件`sources.list`到镜像
* 替换源配置文件并更新安装列表，设置`zh_CN.UTF-8`并删除额外文件
* 设置字符集环境变量

## 构建

```
$ docker build -t zjzstu/ubuntu:18.04 -t zjzstu/ubuntu:latest .
```

## 使用

```
$ docker run -it --rm zjzstu/ubuntu bash
```

能够实现中文输入，确保中文文件不乱码