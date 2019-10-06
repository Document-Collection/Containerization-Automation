
# [gosu]绑定挂载最佳实践

## 提出问题

`docker`容器默认使用`root`用户运行，当使用绑定挂载方式将主机文件/目录挂载到容器，容器在挂载点创建的文件的权限/属主/属组均属于`root`

启动容器`zjzstu/ubuntu:18.04`，将主机`$HOME/slides`目录挂载到容器`/app/slides`

```
$ docker run -it --rm -v $HOME/slides:/app/slides zjzstu/ubuntu:18.04 bash
```

在容器中创建文件`hi.txt`到挂载点

```
# pwd
/app/slides
# ls -al hi.txt
-rw-r--r-- 1 root root   12 Oct  2 05:26 hi.txt
```

在主机中查看文件`hi.txt`的属性

```
$ pwd
/home/zj/slides
$ ls -al hi.txt 
-rw-r--r-- 1 root root 12 10月  2 13:26 hi.txt
```

**文件`hi.txt`属于`root`用户创建的，所以对于当前普通用户而言，无法修改和执行**

## 使用--user

使用`-u, --user`参数能够指定容器运行期间的用户

```
$ docker run --user <name|uid>[:<group|gid>]
```

将当前普通用户的用户`ID`和组`ID`输入，保证容器和主机在相同用户下运行

```
$ docker run -it --rm -v $HOME/slides:/app/slides --user $UID:$(id -g $USER) zjzstu/ubuntu:18.04 bash
groups: cannot find name for group ID 1000
I have no name!@a3a4ce4cc3f4:/$ 
```

这种情况下容器用户拥有和主机用户相同的用户`ID`和组`ID`

```
# 主机用户信息
$ id
uid=1000(zj) gid=1000(zj) groups=1000(zj),...
# 容器用户信息
$ id
uid=1000 gid=1000 groups=1000
```

所以主机当前用户可以直接操作容器放置在挂载点的文件

### 缺陷

使用`--user`参数虽然在容器中使用了和主机用户一样的`UID:GID`，但是并没有实际创建

```
groups: cannot find name for group ID 1000
I have no name!@a3a4ce4cc3f4:/$ 
```

在`/etc/passwd`中也无法找到，容器命令无法操作超出用户权限的命令和文件

## 使用gosu

参考：

[docker与gosu](https://blog.csdn.net/boling_cavalry/article/details/93380447)

[解决 Docker 数据卷挂载的文件权限问题](https://padeoe.com/docker-volume-file-permission-problem/)

[gosu](https://github.com/tianon/gosu)是一个基于`Go`语言实现的类`sudo`工具，其相较于`sudo`的优势在于它避免了`sudo`或`su`不可预知的`TTY`和信号转发行为

### 安装

参考：[gosu/INSTALL.md](https://github.com/tianon/gosu/blob/master/INSTALL.md)

在`Dockerfile`文件中

```
RUN set -eux; \
	apt-get update; \
	apt-get install -y gosu; \
	rm -rf /var/lib/apt/lists/*; \
    # verify that the binary works
	gosu nobody true
```

### 使用

`Dockerfile`脚本如下

```
FROM zjzstu/ubuntu:18.04
LABEL maintainer "zhujian <zjzstu@github.com>"

WORKDIR /app
RUN set -eux && \
	apt-get update && \
	apt-get install -y gosu && \
	rm -rf /var/lib/apt/lists/* && \
    # verify that the binary works
	gosu nobody true && \
	useradd -s /bin/bash -m user

COPY docker-entrypoint.sh .
RUN chmod a+x docker-entrypoint.sh

ENTRYPOINT ["/app/docker-entrypoint.sh"]
```

安装`gosu`，创建用户`user`，最后设置启动脚本`docker-entrypoint.sh`

`docker-entrypoint`脚本如下：

```
#!/bin/bash

if [ "$(id -u)" -eq '0' ]
then
    USER_ID=${LOCAL_USER_ID:-9001}
 
    usermod -u ${USER_ID} -g ${USER_ID} user > /dev/null 2>&1
    chown -R `id -u user`:`id -u user` /app > /dev/null 2>&1
 
    export HOME=/home/user
    exec gosu user "$0" "$@"
fi

exec "$@"
```

利用本地用户`ID`替换容器用户`user`，使用`gosu`切换到`user`后再执行程序

```
# 注意传入本地用户ID到容器用户user
$ docker run -it --rm -e LOCAL_USER_ID=`id -u ${USER}` -v ${HOME}/storage:/home/user/storage gosu_test bash
user@141e64f7222a:/app$ id
uid=1000(user) gid=1000(user) groups=1000(user)
user@141e64f7222a:/app$ ls -al
total 16
drwxr-xr-x 1 user user 4096 10月  6 20:38 .
drwxr-xr-x 1 root root 4096 10月  6 20:42 ..
-rwxrwxr-x 1 user user  275 10月  6 20:38 docker-entrypoint.sh
```

这样保证本地用户`ID`和容器用户`ID`一致，能够解决文件权限问题