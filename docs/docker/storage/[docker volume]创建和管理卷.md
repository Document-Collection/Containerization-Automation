
# [docker volume]创建和管理卷

可以使用命令`docker volume`创建和管理卷

## 创建

语法如下：

```
docker volume create [OPTIONS] [VOLUME]
```

* 参数`-d, --driver`指定了卷驱动器名称，默认为`local`

## 查询

使用`docker volume ls`查询当前已有的卷

```
$ docker volume create test
test
$ docker volume create oth
oth
$ docker volume ls
DRIVER              VOLUME NAME
local               oth
local               test
```

使用`docker volume inspect`查询指定卷的相关信息

```
$ docker volume inspect oth
[
    {
        "CreatedAt": "2019-10-01T15:11:37+08:00",
        "Driver": "local",
        "Labels": {},
        "Mountpoint": "/var/lib/docker/volumes/oth/_data",
        "Name": "oth",
        "Options": {},
        "Scope": "local"
    }
]
```

## 移除

使用命令`docker volume rm`移除一个或多个卷。**注意：不能删除容器正在使用的卷**

```
$ docker volume rm hello
```

使用命令`docker volume prune`移除所有未被容器使用的卷

```
$ docker volume prune
WARNING! This will remove all local volumes not used by at least one container.
Are you sure you want to continue? [y/N] y
Deleted Volumes:
test

Total reclaimed space: 0B
```

## 备份

基本原理：将卷挂载到容器中，通过`tar`命令打包

创建新的容器`dbstore`，挂载卷到路径`/dbdata`

```
$ docker run --rm -it -v VOLUME_NAME:/dbdata --name dbstore ubuntu /bin/bash
```

新建一个窗口

* 启动新容器并挂载容器`dbstore`
* 挂载本地文件夹到容器目录`/backup`
* 执行`tar`命令，打包`/dbdata`目录到`/backup/backup.tar`

```
$ docker run --rm --volumes-from dbstore -v $(pwd):/backup ubuntu tar cvf /backup/backup.tar /dbdata
```

## 还原

基本原理：将卷挂载到容器中，通过`tar`命令解压

创建新容器`dbstore2`，将卷挂载到路径`/dbdata`

```
$ docker run --rm -it -v jenkins_home:/dbdata --name dbstore2 ubuntu /bin/bash
```

新建一个窗口，解压压缩包`backup.tar`内容到`dbstore2`的`dbdata`目录

```
$ docker run --rm --volumes-from dbstore2 -v $(pwd):/backup ubuntu bash -c "cd /dbdata && tar xvf /backup/backup.tar --strip 1"
```