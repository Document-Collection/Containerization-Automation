
# Hello World

参考：

[Get Started, Part 2: Containers](https://docs.docker.com/get-started/part2/#recap-and-cheat-sheet-optional)

[Best practices for writing Dockerfiles](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)

`Docker`镜像由只读层组成，每个层代表一条`Dockerfile`指令。这些层是堆叠的，每一层都是前一层变化的增量

下面制作最简单的`Hello World`镜像

## Dockerfile

新建文件夹`docker`，进入该文件后新建文件`Dockerfile`，输入以下指令

```
$ mkdir docker
$ cd docker
$ vim docker
FROM ubuntu:18.04
COPY . /app
CMD sh /app/app.sh
```

每一条指令都会创建一个层，解释如下：

* `FROM`指令创建一个层，来自于`ubuntu:18.04`镜像
* `COPY`指令创建一个层，将当前`docker`文件夹内容复制到镜像的`/app`文件夹内
* `CMD`指令创建一个层，运行脚本

创建脚本`app.sh`，内容如下：

```
echo 'Hello World'
```

## 创建镜像

输入以下指令构建镜像，指定镜像名和版本号

```
$ docker build --tag=zj:0.1.0 .
Sending build context to Docker daemon  3.072kB
Step 1/3 : FROM ubuntu:18.04
18.04: Pulling from library/ubuntu
35c102085707: Pull complete 
251f5509d51d: Pull complete 
8e829fe70a46: Pull complete 
6001e1789921: Pull complete 
Digest: sha256:d1d454df0f579c6be4d8161d227462d69e163a8ff9d20a847533989cf0c94d90
Status: Downloaded newer image for ubuntu:18.04
 ---> a2a15febcdf3
Step 2/3 : COPY . /app
 ---> 8d579b652ea1
Step 3/3 : CMD sh /app/app.sh
 ---> Running in 0e0f6faa5749
Removing intermediate container 0e0f6faa5749
 ---> 7515c3706b27
Successfully built 7515c3706b27
Successfully tagged zj:0.1.0
```

有上面输出日志可知，共创建了`3`个镜像，其`ID`如下：

```
a2a15febcdf3
8d579b652ea1
7515c3706b27
```

可通过`docker image ls`查询

```
$ docker image ls -a
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
zj                  0.1.0               7515c3706b27        12 seconds ago      64.2MB
<none>              <none>              8d579b652ea1        14 seconds ago      64.2MB
ubuntu              18.04               a2a15febcdf3        4 weeks ago         64.2MB
```

## 运行容器

使用指令`docker run`启动容器，将`Hello World`输入到当前命令行窗口

```
$ docker run zj:0.1.0
Hello World
```