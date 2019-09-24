
# ADD和COPY

指令`ADD`和`COPY`都可以实现复制外部文件到镜像的功能

## ADD

参考：[ADD](https://docs.docker.com/engine/reference/builder/#add)

`ADD`指令复制新文件、目录或远程文件`URL`，并将它们添加到位于镜像的文件系统中

### 语法

有两种实现格式

1. `ADD [--chown=<user>:<group>] <src>... <dest>`
2. `ADD [--chown=<user>:<group>] ["<src>",... "<dest>"]`（包含空格的路径适用于这种方式）

*`chown`仅适用于`Linux`容器构建*

* `<dest>`是目录，需要以斜杠（`/`）结尾
* `<dest>`不存在，它将与路径中所有缺少的目录一起创建

### 作用

* 单次`ADD`操作复制一个或多个文件到镜像，其路径相对于生成上下文
* `<src>`可以包含通配符，符合[GO文件匹配](http://golang.org/pkg/path/filepath#Match)
* `<dest>`是一个绝对路径，或者相对于`WORKDIR`指令的路径
* `<src>`路径必须在生成上下文中，不能操作超出生成上下文的路径（比如`ADD ../something /something`），因为`docker build`的第一步操作就是发送上下文目录（或子目录）到`docker`守护进程
* 如果`<src>`是一个目录，则复制该目录的全部内容，包括文件系统元数据

复制包含特殊字符（比如`[`和`]`）的源路径时，需要按照`Golang`规则转义这些路径，以防止它们被视为匹配的模式，比如

```
ADD arr[[]0].txt /mydir/    # copy a file named "arr[0].txt" to /mydir/
```

### 解压

`ADD`指令的一个特别之处在于它能够解压源文件

* 如果<src>是一个可识别压缩格式（`identity、gzip、bzip2或xz`）的本地`tar`归档文件，则将其解压为一个目录
* 不会解压来自远程`URL`的资源

文件是否被识别为可识别的压缩格式仅基于文件的内容而不是文件的名称。例如，如果一个空文件恰好以`.tar.gz`结尾，则不会将其识别为压缩文件，也不会生成任何类型的解压缩错误消息，而只会将该文件复制到目标位置

### 示例

```
ADD hom* /mydir/        # adds all files starting with "hom"
ADD hom?.txt /mydir/    # ? is replaced with any single character, e.g., "home.txt"

ADD test relativeDir/          # adds "test" to `WORKDIR`/relativeDir/
ADD test /absoluteDir/         # adds "test" to /absoluteDir/
```

## COPY

参考：[COPY](https://docs.docker.com/engine/reference/builder/#copy)

`COPY`指令从`<src>`复制新文件或目录，并将它们添加到位于路径`<dest>`的容器文件系统中

### 语法

有`2`种语法格式

1. `COPY [--chown=<user>:<group>] <src>... <dest>`
2. `COPY [--chown=<user>:<group>] ["<src>",... "<dest>"]`（包含空格的路径适用于这种方式）

*`chown`仅适用于`Linux`容器构建*

* `<dest>`是目录，需要以斜杠（`/`）结尾
* `<dest>`不存在，它将与路径中所有缺少的目录一起创建

### 作用

* 单次`COPY`操作复制一个或多个文件到镜像，其路径相对于生成上下文
* `<src>`可以包含通配符，符合[GO文件匹配](http://golang.org/pkg/path/filepath#Match)
* `<dest>`是一个绝对路径，或者相对于`WORKDIR`指令的路径
* `<src>`路径必须在生成上下文中，不能操作超出生成上下文的路径（比如`COPY ../something /something`），因为`docker build`的第一步操作就是发送上下文目录（或子目录）到`docker`守护进程
* 如果`<src>`是一个目录，则复制该目录的全部内容，包括文件系统元数据

复制包含特殊字符（比如`[`和`]`）的源路径时，需要按照`Golang`规则转义这些路径，以防止它们被视为匹配的模式，比如

```
COPY arr[[]0].txt /mydir/    # copy a file named "arr[0].txt" to /mydir/
```

### 多阶段构建

`COPY`指令可以设置标识符`--from=<name|index>`，可用于将源位置设置为上一个生成阶段（使用`FROM .. AS <name>`创建），而不是用户发送的生成上下文。该标识符还接受为以`FROM`指令开始的所有先前生成阶段分配的数字索引。如果找不到具有指定名称的生成阶段，则尝试使用具有相同名称的镜像

## ADD vs. COPY

`ADD`指令和`COPY`指令均执行复制操作，但各有侧重点

* `ADD`指令相对于`COPY`指令，能够复制远程`URL`的资源，并且能够解压缩本地归档文件
* `COPY`指令相对于`ADD`指令，能够复制`Dockerfile`中先前生成阶段的文件

如果仅用于复制本地文件和文件夹，推荐使用`COPY`指令，这样不容易发生误解压操作