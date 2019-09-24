
# ARG

参考：[ARG](https://docs.docker.com/engine/reference/builder/#arg)

`ARG`指令用于定义构建时参数

## 语法

```
ARG <name>[=<default value>]
```

`Dockerfile`中可以包含一个或多个`ARG`指令

可以在构建时使用标识符`--build-tag <varname>=<value>`指定构建时参数，如果`<varname>`未在`Dockerfile`中定义，输出一个`warning`

```
[Warning] One or more build-args [foo] were not consumed.
```

## 默认值

`ARG`指令可以设置默认值，如果在构建时没有设定值，构建器使用该默认值

## 作用域

`ARG`指令仅作用于其声明后的构建阶段，对于多阶段构建，需要在每个阶段包含`ARG`指令（如果需要使用的话），在`ARG`指令定义变量之前的任何变量使用都会导致空字符串

## 使用ARG变量

当`ARG`变量和`ENV`变量同名时，`ENV`变量会重写`ARG`变量

```
$ cat Dockerfile
FROM zjzstu/ubuntu:18.04
ENV CONT_IMG_VER v1.0.0
ARG CONT_IMG_VER
RUN echo $CONT_IMG_VER
```

执行构建，输入`ARG`变量值

```
$ docker build --no-cache --build-arg CONT_IMG_VER=v2.0.1 . 
...
...
Step 4/4 : RUN echo $CONT_IMG_VER
 ---> Running in 622b76340e84
v1.0.0
...
...
```

结果输出`ENV`变量值

### ENV和ARG的交互

可以在`ENV`设定时使用`ARG`变量

```
$ cat Dockerfile
FROM zjzstu/ubuntu:18.04
ARG CONT_IMG_VER
ENV CONT_IMG_VER ${CONT_IMG_VER:-v1.0.0}
RUN echo $CONT_IMG_VER
```

如果不在构建时输入`ARG`变量值，则`ENV`变量值使用默认`v1.0.0`

```
$ docker build .
...
...
Step 4/4 : RUN echo $CONT_IMG_VER
 ---> Running in 03d7ec223f3d
v1.0.0
...
...
```

如果构建时设定`ARG`变量值

```
$ docker build --no-cache --build-arg CONT_IMG_VER=v2.0.1 .
...
...
Step 4/4 : RUN echo $CONT_IMG_VER
 ---> Running in 904ff8dacdb9
v2.0.1
...
...
```

## 预定义

`Docker`预定义了一组`ARG`变量，可以直接在构建时使用

```
HTTP_PROXY
http_proxy
HTTPS_PROXY
https_proxy
FTP_PROXY
ftp_proxy
NO_PROXY
no_proxy
```

**注意大小写区分**

*默认情况下这些变量值会在`docker history`输出中排除，这有助于避免敏感信息泄漏*

```
$ cat Dockerfile
FROM zjzstu/ubuntu:18.04

RUN echo $HTTP_PROXY
RUN echo $HTTPS_PROXY
RUN echo $ftp_proxy

$ docker build --no-cache --build-arg HTTP_PROXY=11.11.11.1 --build-arg HTTPS_PROXY=234 .
Sending build context to Docker daemon  81.83MB
Step 1/4 : FROM zjzstu/ubuntu:18.04
 ---> 5493327e7708
Step 2/4 : RUN echo $HTTP_PROXY
 ---> Running in 2588daac2563
11.11.11.1
Removing intermediate container 2588daac2563
 ---> ae3a5b5e9c12
Step 3/4 : RUN echo $HTTPS_PROXY
 ---> Running in a519b357a339
234
Removing intermediate container a519b357a339
 ---> a5aece91234c
Step 4/4 : RUN echo $ftp_proxy
 ---> Running in 285417b50a65

Removing intermediate container 285417b50a65
 ---> 4f8974edb71c
Successfully built 4f8974edb71c
```

## 全局范围的自动平台ARGs

此特征仅适用于[BuildKit](https://docs.docker.com/engine/reference/builder/#buildkit)后端

## 构建缓存影响

在构建过程中设定了`ARG`变量值，则在`Dockerfile`中使用该变量的中间镜像会重新构建。同时，所有`RUN`指令隐式使用了`ARG`变量，所以都会重新构建

```
# Dockerfile 1
FROM ubuntu
ARG CONT_IMG_VER
RUN echo $CONT_IMG_VER

# Dockerfile 2
FROM ubuntu
ARG CONT_IMG_VER
RUN echo hello
```

利用上述两个`Dockerfile`分别构建，如果设定了`--build-arg CONT_IMG_VER=<value>`，则两种情况下的`RUN`指令均会重新构建

```
$ cat Dockerfile
FROM zjzstu/ubuntu:18.04
ARG CONT_IMG_VER
ENV CONT_IMG_VER $CONT_IMG_VER
RUN echo $CONT_IMG_VER
CMD echo $CONT_IMG_VER
```

上述`Dockerfile`中使用`ARG`变量作为`ENV`变量值，那么构建时`ENV`指令会重新构建，与此同时，后续`RUN`和`CMD`指令也会重新构建