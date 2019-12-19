
# RUN

参考：[RUN](https://docs.docker.com/engine/reference/builder/#run)

`RUN`指令在当前镜像上执行操作，然后将提交结果为新的镜像，作用于`Dockerfile`的下一步

## 语法

`RUN`指令有`2`种格式：

* `RUN <command>`（`shell`形式，命令运行在一个`shell`上。对`Linux`而言，默认是`/bin/sh -c`；对`Windows`而言，默认是`cmd /S /C`）
* `RUN ["executable", "param1", "param2"]`（`exec`形式）

注意一：使用`shell`形式，可以使用反斜线（`\, backslash`）将单行`RUN`指令扩展成多行，有助于配置和理解

```
RUN apt-get update && \
    apt-get install -f \
    apt-get install -y net-tools
```

注意二：`exec`形式必须使用双引号而不是单引号

注意三：`exec`形式的`RUN`指令不会调用命令`shell`，必须显式调用`shell`

```
RUN ["sh", "-c", "echo hello"]
```

对于`Windows`系统而言，需要转义反斜杠，比如`RUN ["c:\\windows\\system32\\tasklist.exe"]`

## 缓存

`RUN`指令的缓存不会在下一个生成期间自动失效，所以`RUN apt-get dist-upgrade -y`的缓存将在下次构建时使用

设置缓存内容失效，需要在构建时设置标识符`--no-cache`，比如`docker build --no-cache .`

## 不同shell

如果要使用不同`shell`，操作如下：

* 使用绝对路径指定新的`shell`
* 使用`SHELL`指令更新

```
RUN ["/bin/bash", "-c", "echo hello"]
```