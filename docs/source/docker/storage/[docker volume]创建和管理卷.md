
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