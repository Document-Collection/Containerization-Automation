
# 安装git出错

最新发现：是因为`Ubuntu`镜像源出错，我在`18.04`上误用了`16.04`的`ali mirror`

## 问题

使用`docker`镜像`zjzstu/ubuntu:18.04`，发现无法安装`git`

```
...
...
The following packages have unmet dependencies:
 git : Depends: liberror-perl but it is not going to be installed
E: Unable to correct problems, you have held broken packages.
```

缺少一系列的`git`依赖，测试多次之后成功安装`git`

## Dockerfile

```
FROM zjzstu/ubuntu:18.04
RUN apt-get update \
	&& apt-get install -y --allow-downgrades openssh-client perl-base=5.22.1-9ubuntu0.6 perl-modules-5.22 libperl5.22 netbase rename perl liberror-perl git
CMD git version 
```

## 镜像

构建镜像

```
$ docker build --no-cache -t zjzstu/ubuntu:18.04-git .
```

运行容器，输出`git`版本号

```
$ docker run zjzstu/ubuntu:18.04-git 
git version 2.7.4
```

上传到[Docker Hub](https://hub.docker.com/r/zjzstu/ubuntu)
