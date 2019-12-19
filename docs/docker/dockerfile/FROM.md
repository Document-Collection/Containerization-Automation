
# FROM

参考：[FROM](https://docs.docker.com/engine/reference/builder/#from)

## 语法

```
FROM <image> [AS <name>]
FROM <image>[:<tag>] [AS <name>]
FROM <image>[@<digest>] [AS <name>]
```

`FROM`指令通常作为`Dockerfile`指令的开始语句，其初始化一个新的构建阶段，并为后续指令设置基础镜像

* `ARG`指令是唯一一个可能在`Dockerfile`中领先于`FROM`的指令
* 在一个`Dockerfile`文件中可以出现多次`FROM`指令。可用于构建多个镜像或者为后面的构建创建依赖镜像
    * 对于独立构建的镜像，只需注意每个`FROM`指令前最后一次提交的镜像`ID`
    * 每次`FROM`指令都会清理之前指令的状态
* 赋值镜像别名`name`，可用于后续的`FROM`或`COPY --from=<name|index>`指令
* `tag`和`digest`可选，如果没有指定，默认使用`latest`作为标签

## ARG和FROM的交互

指令`ARG`用于声明键值对，其可声明在任何位置，如果声明在第一个`FROM`指令之前，即可作用于所有的`FROM`指令

```
$ cat Dockerfile 
ARG CODE_VERSION=18.04
FROM zjzstu/ubuntu:${CODE_VERSION}

RUN apt-get update && apt-get install -y tree

ENTRYPOINT ["/usr/bin/tree"]
CMD ["-L", "1"]
```

每个`FROM`指令都表示开始一次新的构建，会清除之前设置的指令，包括`ARG`。如果想要让`FROM`指令之后的指令能够使用第一个`FROM`指令之前设置的`ARG`值，可以在`FROM`指令后声明`ARG`

```
$ cat Dockerfile
ARG CODE_VERSION=18.04
FROM zjzstu/ubuntu:${CODE_VERSION}
ARG CODE_VERSION
RUN echo ${CODE_VERSION}
```

构建镜像过程中输出`CODE_VERSION`

```
$ docker build -t arg:v1 .
Sending build context to Docker daemon  81.82MB
Step 1/4 : ARG CODE_VERSION=18.04
Step 2/4 : FROM zjzstu/ubuntu:${CODE_VERSION}
 ---> 5493327e7708
Step 3/4 : ARG CODE_VERSION
 ---> Running in 52229319295c
Removing intermediate container 52229319295c
 ---> 047fcfd13f1b
Step 4/4 : RUN echo ${CODE_VERSION}
 ---> Running in 0f4ff5a42f32

18.04  // 这里
Removing intermediate container 0f4ff5a42f32
 ---> d729d58eb86f
Successfully built d729d58eb86f
Successfully tagged arg:v1
```