
# Dockerfile编写

参考：[Dockerfile reference](https://docs.docker.com/engine/reference/builder/#usage)

## 构建

命令`docker build`从一个`Dockerfile`文件和生成上下文（`build context`）中构建镜像，其中生成上下文可以指定为本地目录或者远程`Git`仓库

构建由`Docker`守护进程实现，第一步就是将递归复制整个目录到守护进程，所以最好只放置有效文件在生成上下文中

在`Docker`守护进程按照`Dockerfile`指令进行构建之前，会执行一个`Dockerfile`的语法检查，如果出错会抛出提示

```
Error response from daemon: Unknown instruction: xxx
```

### 文件位置

通常将`Dockerfile`文件放置在生成上下文的根路径，也可使用标识符`-f`指定

```
# 在根路径
$ docker build .
# 指定文件
$ docker build -f /path/to/Dockerfile .
```

### 镜像名

使用标识符`-t, --tag list`指定生成镜像名，可以同时指定多个，这些镜像名均指向同一个镜像`ID`

```
$ docker build -t zjzstu/myapp:1.0.2 -t zjzstu/myapp:latest .
$ docker image ls
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
zjzstu/myapp        1.0.2               5e1153cb35f3        2 minutes ago       109MB
zjzstu/myapp        latest              5e1153cb35f3        2 minutes ago       109MB
```

### 中间镜像

`Dockerfile`的每一条指令都是独立运行，并生成一个新的镜像，所以在上一条指令的路径操作（比如`RUN cd /tmp`）对下一条指令无效，必须在同一条指令执行（比如`RUN cd /tmp && pwd`）

中间镜像会缓存在本地，如果下次重新构建时发现相同指令，则会重用中间镜像

## Dockerfile格式

语法格式如下：

```
# Comment `#`开头的是注释
INSTRUCTION arguments
```

指令不是大小写敏感（`case-sensitive`）的，不过大写指令有助于阅读和理解

**`Dockerfile`文件必须从`FROM`指令开始，用于指定本次构建的基础镜像**

## 环境变量替换

使用`ENV`指令创建的环境变量可作用于`Dockerfile`的其他指令。语法如下：

* `$variable_name`
* `${variable_name}`

常用的`3`种实现如下：

1. `${variable}_name`：构建后替换`variable`值
2. `${variable:-word}`：如果`variable`被设置，则替换该值；如果变量没有设置，则使用`word`替代（相当于默认值）
3. `${variable:+word}`：其作用和上条相反，如果`variable`被设置，则使用`word`；否则，结果为空字符串

如果`${variable}`不是环境变量，需要使用转义字符`\`

```
FROM busybox
ENV foo /bar
WORKDIR ${foo}   # WORKDIR /bar
ADD . $foo       # ADD . /bar
COPY \$foo /quux # COPY $foo /quux
```

以下指令支持环境变量替换：

```
ADD
COPY
ENV
EXPOSE
FROM
LABEL
STOPSIGNAL
USER
VOLUME
WORKDIR
ONBUILD（需要与上面指令组合）
```