
# Docker Hub使用

参考：[Get Started, Part 2: Containers](https://docs.docker.com/get-started/part2/#recap-and-cheat-sheet-optional)

注册表（`registry`）是存储库（`repository`）的集合，存储库是镜像（`image`）的集合，类似于`github`存储库，但代码已经构建

注册表上的帐户可以创建多个存储库。[Docker Hub](https://hub.docker.com)是`Docker`官方的注册表，可用于`Docker`镜像的远程存储和分发

## 登录

首先在`Docker Hub`官网上注册账户，然后在本地登录

```
$ docker login
Login with your Docker ID to push and pull images from Docker Hub. If you don't have a Docker ID, head over to https://hub.docker.com to create one.
Username: zjzstu
Password: 
WARNING! Your password will be stored unencrypted in /home/zj/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded$ docker run zjzstu/hello-world:0.1.0
Unable to find image 'zjzstu/hello-world:0.1.0' locally
0.1.0: Pulling from zjzstu/hello-world
35c102085707: Already exists 
251f5509d51d: Already exists 
8e829fe70a46: Already exists 
6001e1789921: Already exists 
a0083f503c5a: Pull complete 
Digest: sha256:6ad989ee32e1f170c8e8e6c4e7dc9ee650f33d67c4deb21837b07cb272f076ee
Status: Downloaded newer image for zjzstu/hello-world:0.1.0
Hello World
```

## 标记

需要重新标记本地镜像，使其符合远程注册表的命名方式

```
$ docker tag IMAGE username/repository:tag
```

* 参数`IMAGE`表示本地镜像名
* `username`表示账户名
* `repository`表示仓库名
* `tag`是可选的，但可以给定一个意义的标记

比如

```
$ docker tag zj:0.1.0 zjzstu/hello-world:0.1.0
```

重新标记完成后会生成一个新的镜像名和标记，指向同一个镜像（`ID`相同）

```
$ docker image ls
REPOSITORY           TAG                 IMAGE ID            CREATED             SIZE
zjzstu/hello-world   0.1.0               7515c3706b27        23 minutes ago      64.2MB
zj                   0.1.0               7515c3706b27        23 minutes ago      64.2MB
ubuntu               18.04               a2a15febcdf3        4 weeks ago         64.2MB
```

## 发布

上传已标记的镜像到仓库

```
$ docker push zjzstu/hello-world:0.1.0
The push refers to repository [docker.io/zjzstu/hello-world]
e8d6f0abd7b0: Pushed 
122be11ab4a2: Mounted from library/ubuntu 
7beb13bce073: Mounted from library/ubuntu 
f7eae43028b3: Mounted from library/ubuntu 
6cebf3abed5f: Mounted from library/ubuntu 
0.1.0: digest: sha256:6ad989ee32e1f170c8e8e6c4e7dc9ee650f33d67c4deb21837b07cb272f076ee size: 1359
```

完成之后即可在仓库中查看：[zjzstu/hello-world](https://hub.docker.com/r/zjzstu/hello-world/tags)

## 拉取

运行镜像`zjzstu/hello-world:0.1.0`，如果本地不存在，则会从远程拉取

```
$ docker run zjzstu/hello-world:0.1.0
Unable to find image 'zjzstu/hello-world:0.1.0' locally
0.1.0: Pulling from zjzstu/hello-world
35c102085707: Already exists 
251f5509d51d: Already exists 
8e829fe70a46: Already exists 
6001e1789921: Already exists 
a0083f503c5a: Pull complete 
Digest: sha256:6ad989ee32e1f170c8e8e6c4e7dc9ee650f33d67c4deb21837b07cb272f076ee
Status: Downloaded newer image for zjzstu/hello-world:0.1.0
Hello World
```