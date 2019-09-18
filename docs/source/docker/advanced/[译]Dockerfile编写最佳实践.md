
# [译]Dockerfile编写最佳实践

原文地址：[Best practices for writing Dockerfiles](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)

本文档介绍构建高效镜像的最佳实践和方法

`Docker`通过读取`Dockerfile`中的指令自动生成镜像，`Dockerfile`是一个文本文件，它包含生成给定镜像所需的所有命令。`Dockerfile`遵循特定的格式和指令集，您可以在[Dockerfile参考](https://docs.docker.com/engine/reference/builder/)中找到这些格式和指令集

`Docker`镜像由只读层（`read-only layer`）组成，每个层表示一条`Dockerfile`指令。这些层是堆叠的，每一层都是前一层变化的增量。如下所示：

```
FROM ubuntu:18.04
COPY . /app
RUN make /app
CMD python /app/app.py
```

每条指令创建一个层：

* `FROM`指令利用`Docker`映像`ubuntu:18.04`创建一个层
* `ADD`指令从`Docker`客户端的当前目录添加文件
* `RUN`指令使用`make`命令构建应用程序
* `CMD`指令指定要在容器中运行的命令

运行镜像并生成容器时，将在基础层的顶部添加新的可写层（`writable layer`，称为`容器层`）。对正在运行的容器所做的所有更改（如写入新文件、修改现有文件和删除文件）都将写入此精简的可写容器层

有关镜像层（以及`Docker`如何构建和存储镜像）的详细信息，请参阅[关于存储驱动程序](https://docs.docker.com/storage/storagedriver/)

## General guidelines and recommendations

### 创建临时容器

`Dockerfile`定义的镜像应该尽可能的生成临时容器（`ephemeral containers`）。所谓`临时`指的是容器可以停止和销毁，然后重建和替换为一个绝对最小的设置和配置

参考*十二因素应用程序方法*中的[Process](https://12factor.net/processes)，了解以这种无状态方式运行容器的动机

### 理解生成上下文

使用`docker build`命令时，当前工作目录称为生成上下文（`build context`)。默认情况下，`Dockerfile`假定位于此处，但可以使用文件标志（`-f`）指定到其他位置。不管`Dockerfile`实际位于何处，当前目录中文件和目录的所有递归内容都将作为生成上下文发送到`Docker`守护进程

无意中包含镜像不需要的文件会导致更大的生成上下文和更大的镜像大小。这会增加构建镜像的时间、拉取和推送镜像的时间以及容器运行时大小。要查看生成上下文有多大，请在生成`Dockerfile`时查找以下消息：

```
Sending build context to Docker daemon  187.8MB
```

#### 示例1

创建文件夹`myproject`作为生成上下文并进入该文件夹。编写文本文件`hello`，内容为`Hello`，创建`Dockerfile`并运行`cat`命令

```
$ mkdir myproject && cd myproject
$ echo "Hello" > hello
$ echo -e "FROM alpine\nCOPY ./hello /\nCMD cat /hello" > Dockerfile
$ docker build --tag=helloapp:v1 .
Sending build context to Docker daemon  3.072kB
Step 1/3 : FROM alpine
latest: Pulling from library/alpine
9d48c3bd43c5: Pull complete 
Digest: sha256:72c42ed48c3a2db31b7dafe17d275b634664a708d901ec9fd57b1529280f01fb
Status: Downloaded newer image for alpine:latest
 ---> 961769676411
Step 2/3 : COPY ./hello /
 ---> df92747a940b
Step 3/3 : CMD cat /hello
 ---> Running in ef7898646bfb
Removing intermediate container ef7898646bfb
 ---> 499c1b68a6f1
Successfully built 499c1b68a6f1
Successfully tagged helloapp:v1
```

#### 示例2

将`Dockerfile`和`hello`文件分离到不同的路径下，操作如下：

```
# 在当前路径下创建两个文件夹dockerfiles和context
$ mkdir -p dockerfiles context
# 移动Dockerfile文件到dockerfiles，移动hello到context
$ mv Dockerfile dockerfiles && mv hello context
# 生成上下文是context，构建镜像
$ docker build --no-cache -t helloapp:v2 -f dockerfiles/Dockerfile context
```

### 通过stdin输送Dockerfile

`Docker`可以在本地或远程生成上下文中通过`stdin`输送`Dockerfile`来生成镜像。通过`stdin`输送`Dockerfile`适用于不将`Dockerfile`写入磁盘仅执行一次性构建（`one-off build`）的情况，或者在生成`Dockerfile`但以后不应继续维持的情况

以下两个命令是等价的

```
# 命令一
$ echo -e 'FROM busybox\nRUN echo "hello world"' | docker build --tag=std:v1 -
# 命令二
$ docker build --tag=std:v1 -<<EOF
FROM busybox
RUN echo "hello world"
EOF
```

其作用是构建镜像`std:v1`，使用`busybox`镜像，输出`hello world`

#### 使用stdin中的Dockerfile生成镜像，不发送生成上下文

使用`stdin`中的`Dockerfile`生成镜像，不将其他文件作为生成上下文发送

```
$ docker build [OPTIONS] -
```

连字符（`hyphen`, `-`）占据了参数`PATH`的位置，指示`Docker`从`stdin`而不是目录读取生成上下文（仅包含`Dockerfile`）

#### 利用本地生成上下文构建镜像，使用来自`stdin`的`Dockerfile`

使用以下语法实现本地生成上下文构建镜像，但使用来自stdin的Dockerfile

```
docker build [OPTIONS] -f- PATH
```

使用参数-f（或--file）指定`Dockerfile`文件地址，使用连字符`-`指定`Dockerfile`从`stdin`中获取

#### 利用远程生成上下文构建镜像，使用来自stdin的Dockerfile

实现语法和本地生成上下文一致，但是路径是远程地址，比如远程`git`仓库

```
docker build [OPTIONS] -f- PATH
```

不管远程仓库是否包含`Dockerfile`，使用自定义`Dockerfile`进行构建

*注意：需要先安装git*

#### 示例一

以下示例使用通过`stdin`传递的`Dockerfile`构建镜像，没有文件作为生成上下文发送到守护进程

```
docker build -t myimage:latest -<<EOF
FROM busybox
RUN echo "hello world"
EOF
```

在`Dockerfile`不需要将文件复制到镜像中的情况下，省略生成上下文可能会很有用，并提高构建速度，因为没有文件发送到守护进程

如果要通过从生成上下文中排除某些文件来提高生成速度，请参考[exclude with .dockerignore](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#exclude-with-dockerignore)

**注意：此时Dockerfile中不应该使用COPY或ADD指令**

#### 示例二

使用本地生成上下文+`stdin`管道输送的`Dockerfile`，打印文件`somefile.txt`

```
# create a directory to work in
mkdir example
cd example

# create an example file
touch somefile.txt

# build an image using the current directory as context, and a Dockerfile passed through stdin
docker build -t myimage:latest -f- . <<EOF
FROM busybox
COPY somefile.txt .
RUN cat /somefile.txt
EOF
```

实现结果：

```
$ docker build -t myimage:latest -f- . <<EOF
> FROM busybox
> COPY somefile.txt .
> RUN cat /somefile.txt
> EOF
Sending build context to Docker daemon  2.095kB
Step 1/3 : FROM busybox
 ---> 19485c79a9bb
Step 2/3 : COPY somefile.txt .
 ---> cccdca4d6fa7
Step 3/3 : RUN cat /somefile.txt
 ---> Running in 9076ab4d7c93
Removing intermediate container 9076ab4d7c93
 ---> c34e49a4fb73
Successfully built c34e49a4fb73
Successfully tagged myimage:latest
```

#### 示例三

使用远程生成上下文+`stdin`管道输送的`Dockerfile`，加入远程文件`hello.c`到镜像`busybox`

```
docker build -t myimage:latest -f- https://github.com/docker-library/hello-world.git <<EOF
FROM busybox
COPY hello.c .
EOF
```

实现结果：

```
$ docker build -t myimage:latest -f- https://github.com/docker-library/hello-world.git <<EOF
> FROM busybox
> COPY hello.c .
> EOF
Sending build context to Docker daemon  55.32kB
Step 1/2 : FROM busybox
 ---> 19485c79a9bb
Step 2/2 : COPY hello.c .
 ---> 059136dee888
Successfully built 059136dee888
Successfully tagged myimage:latest
```

### .dockerignore使用

若要排除与生成无关的文件（不重新构造源存储库），请使用`.dockerignore`文件。此文件支持类似于`.gitignore`文件的排除模式。有关创建文件的信息，请参考[.dockerignore文件](https://docs.docker.com/engine/reference/builder/#dockerignore-file)

### 多阶段构建

[多阶段构建](https://docs.docker.com/develop/develop-images/multistage-build/)允许大幅减少最终镜像的大小，而不必费力地减少中间层和文件的数量

因为镜像是在生成过程的最后阶段生成的，所以可以通过[利用生成缓存](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#leverage-build-cache)来最小化镜像层

例如，如果构建包含多个层，则可以将它们从更改频率较低的层（以确保生成缓存可重用）排序到更改频率较高的层：

* 需要构建应用的安装工具
* 安装或更新库依赖
* 生成应用

### 不要安装不需要的包

为了减少复杂性、依赖性、文件大小和构建时间，请避免仅仅因为安装额外的或不必要的包可能是`很好的`而安装这些包。例如，不需要在数据库镜像中包含文本编辑器

### 分离应用程序

每个容器应该只有一个问题。将应用程序分离到多个容器可以更容易地横向扩展和重用容器。例如，一个`web`应用程序栈可能由三个独立的容器组成，每个容器都有自己独特的镜像，以分离的方式管理`web`应用程序、数据库和内存缓存

将每个容器限制为一个进程是一个很好的经验法则，但这不是一个硬性规定。例如，不仅可以使用[init进程生成](https://docs.docker.com/engine/reference/run/#specify-an-init-process)容器，一些程序还可以自动生成其他进程。例如，[Celery](http://www.celeryproject.org/)可以生成多个工作进程，而[Apache](https://httpd.apache.org/)可以为每个请求创建一个进程

用你最好的判断来保持容器尽可能的干净和模块化。如果容器相互依赖，可以使用[Docker容器网络](https://docs.docker.com/engine/userguide/networking/)来确保这些容器可以通信

### 最小化层数量

在旧版本的`Docker`中，最小化图像的层数以确保其性能是非常重要的。最后的版本中添加了以下功能以减少此限制： 

* 只有指令`RUN，COPY，ADD`创建层。其他指令会创建临时中间镜像，并且不会增加生成的大小
* 尽可能的使用[多阶段构建](https://docs.docker.com/develop/develop-images/multistage-build/)，只将需要的内容复制到最终镜像中。这允许您在中间构建阶段包含工具和调试信息，而不增加最终镜像的大小

### 排序多行参数

尽可能的通过按字母数字顺序排列多行参数来简化以后的更改。这有助于避免包的重复，并使列表更易于更新。这也使得`PRs`更易于阅读和审查。在反斜杠（`\`）前添加空格也有帮助。示例如下：

```
RUN apt-get update && apt-get install -y \
  bzr \
  cvs \
  git \
  mercurial \
  subversion
```

### 利用构建缓存

当构建一个镜像时，`Docker`会逐步执行`DockerFile`中的指令，并按照指定的顺序执行每个指令。在检查每条指令时，`Docker`会在其缓存中查找一个可以重用的现有镜像，而不是创建一个新的（重复的）镜像

如果根本不想使用缓存，可以在`docker build`命令中使用`--no-cache=true`选项。但是，如果你让`Docker`使用缓存，那么很重要的一点是了解它什么时候可以，什么时候不能找到匹配的图像。`Docker`遵循的基本规则概述如下：

* 从已在缓存中的父镜像开始，将下一条指令与从该基镜像派生的所有子镜像进行比较，以查看是否使用完全相同的指令生成了其中一个镜像。否则，缓存将失效
* 在大多数情况下，只需将`Dockerfile`中的指令与其中一个子镜像进行比较就足够了。然而，某些指示需要更多的检查和解释
* 对于`COPY`和`ADD`指令，将检查镜像中文件的内容，并为每个文件计算校验和。这些校验和不考虑文件的最后修改和最后访问时间。在缓存查找期间，将校验和与现有镜像中的校验和进行比较。如果文件中有任何更改（如内容和元数据），则缓存将失效
* 除了`ADD`和`COPY`命令之外，缓存检查不会查看容器中的文件来确定缓存匹配。例如，在处理`RUN apt-get -y update`命令时，不会检查容器中更新的文件以确定是否存在缓存命中。在这种情况下，只使用命令字符串本身来查找匹配项

一旦缓存失效，所有后续的`Dockerfile`命令都会生成新镜像，并且缓存不会被使用

## Dockerfile instructions

以下建议旨在帮助创建一个高效且可维护的`Dockerfile`

### FROM

参考：[Dockerfile reference for the FROM instruction](https://docs.docker.com/engine/reference/builder/#from)

尽可能使用当前的官方图像作为基础镜像。我们建议使用[Alpine镜像](https://hub.docker.com/_/alpine/)，因为它是严格控制的，而且大小很小（当前小于5MB），同时仍然是一个完整的`linux`发行版

### LABEL

参考：[Understanding object labels](https://docs.docker.com/config/labels-custom-metadata/)

可以将标签添加到镜像中，以帮助按项目组织镜像、记录许可信息、帮助自动化或出于其他原因。对于每个标签，添加以`LABEL`开头以及一个或多个键值对的行。以下示例显示了不同的可接受格式。注释包含在里面

一个镜像可以有多个标签。在`Docker1.10`之前，建议将所有标签合并为一个标签指令，以防止创建额外的层。这已不再必要，但仍支持组合标签

有关可接受标签键和值的准则，参考[了解对象标签](https://docs.docker.com/config/labels-custom-metadata/)。有关查询标签的信息，请参阅[管理对象上的标签](https://docs.docker.com/config/labels-custom-metadata/#managing-labels-on-objects)中与筛选相关的项目。另参考`DockerFile`参考中的[LABEL](https://docs.docker.com/engine/reference/builder/#label)

**注意：带空格的字符串必须引用或使用转义空格。内部引号字符（`"`）也必须转义**

```
# Set one or more individual labels
LABEL com.example.version="0.0.1-beta"
LABEL vendor1="ACME Incorporated"
LABEL vendor2=ZENITH\ Incorporated
LABEL com.example.release-date="2015-02-12"
LABEL com.example.version.is-production=""

# Set multiple labels on one line
LABEL com.example.version="0.0.1-beta" com.example.release-date="2015-02-12"

# Set multiple labels at once, using line-continuation characters to break long lines
LABEL vendor=ACME\ Incorporated \
      com.example.is-beta= \
      com.example.is-production="" \
      com.example.version="0.0.1-beta" \
      com.example.release-date="2015-02-12"
```

### RUN

参考：[Dockerfile reference for the RUN instruction](https://docs.docker.com/engine/reference/builder/#run)

用反斜杠拆分长的或复杂的`RUN`语句，使`Dockerfile`更具可读性、可理解性和可维护性

#### APT-GET

`RUN`命令最常见的用例是`apt-get`。`RUN apt-get`命令有几个陷阱需要注意：

避免`RUN apt-get upgrade`和`dist-upgrade`，因为来自父镜像的许多`基本`包无法在[非特权容器](https://docs.docker.com/engine/reference/run/#security-configuration)中升级。如果父镜像中包含的包已过期，请与其维护人员联系。如果知道有一个特定的包`foo`需要更新，请使用`apt-get install -y foo`自动更新

始终将`RUN apt-get update`与`apt-get install`合并在同一`RUN`语句中。例如：

```
RUN apt-get update && apt-get install -y \
    package-bar \
    package-baz \
    package-foo
```

在`RUN`语句中单独使用`apt-get update`会导致缓存问题和后续`apt-get`安装指令失败。例如

```
FROM ubuntu:18.04
RUN apt-get update
RUN apt-get install -y curl
```

生成镜像后，所有层都在`Docker`缓存中。假设稍后通过添加额外的包来修改`apt-get-install`：

```
FROM ubuntu:18.04
RUN apt-get update
RUN apt-get install -y curl nginx
```

`Docker`将初始指令和修改后的指令视为相同的，并重用前面步骤中的缓存。因此`apt-get update`不会执行，因为构建使用了缓存版本。因为`apt-get update`没有运行，所以构建可能会得到`curl`和`nginx`包的过时版本

使用`RUN apt-get update && apt-get install -y`确保`Dockerfile`安装最新的包版本，而无需进一步编码或手动干预。这种技术被称为`缓存破坏`。还可以通过指定包版本来实现缓存破坏。这称为版本固定（`version pinning`），例如：

```
RUN apt-get update && apt-get install -y \
    package-bar \
    package-baz \
    package-foo=1.3.*
```

版本固定会强制生成检索特定版本，而不管缓存中有什么。此技术还可以减少由于所需包中的意外更改而导致的故障

下面是一个格式良好的`RUN`指令，它演示了所有`apt-get`建议

```
RUN apt-get update && apt-get install -y \
    aufs-tools \
    automake \
    build-essential \
    curl \
    dpkg-sig \
    libcap-dev \
    libsqlite3-dev \
    mercurial \
    reprepro \
    ruby1.9.1 \
    ruby1.9.1-dev \
    s3cmd=1.1.* \
 && rm -rf /var/lib/apt/lists/*
```

`s3cmd`参数指定版本`1.1.*`。如果镜像以前使用旧版本，则指定新版本会导致`apt-get update`的缓存崩溃，并确保安装新版本。在每行列出包还可以防止包复制中的错误

此外，当通过删除`/var/lib/apt/lists`来清理`apt`缓存时，它会减小镜像大小，因为`apt`缓存不存储在层中。由于`RUN`语句以`apt-get update`开头，因此包缓存总是在`apt-get install`之前刷新

*官方Debian和Ubuntu镜像会[自动运行apt-get clean](https://github.com/moby/moby/blob/03e2923e42446dbb830c654d0eec323a0b4ef02a/contrib/mkimage/debootstrap#L82-L105)，因此不需要显式调用*

#### USING PIPES

某些`RUN`命令依赖于使用管道字符（`|`）将一个命令的输出管道化到另一个命令的能力，如下例所示：

```
RUN wget -O - https://some.site | wc -l > /number
```

`Docker`使用`/bin/sh -c`解释器执行这些命令，解释器只计算管道中最后一个操作的退出代码，以确定是否成功。在上面的示例中，只要`wc -l`命令成功，即使`wget`命令失败，此构建步骤也会成功并生成新镜像

如果希望命令因管道中任何阶段的错误而失败，请加上前缀`set -o pipefail &&`，以防止生成意外成功。例如：

```
RUN set -o pipefail && wget -O - https://some.site | wc -l > /number
```

**注意：不是所有`shell`支持`-o pipefail`选项**

对于基于`Debian`的镜像上的`dash shell`等情况，考虑使用`RUN`的`exec`形式显式地选择一个支持`pipefail`选项的`shell`。例如：

```
RUN ["/bin/bash", "-c", "set -o pipefail && wget -O - https://some.site | wc -l > /number"]
```

### CMD

参考：[Dockerfile reference for the CMD instruction](https://docs.docker.com/engine/reference/builder/#cmd)

`CMD`指令应该用于运行镜像包含的软件以及任何参数。`CMD`几乎总是以`CMD ["可执行文件"，"参数1"，"参数2"…]`的形式使用。因此，如果镜像是用于服务的，比如`Apache`和`Rails`，那么将运行类似于`CMD ["apache2"，"-DFOREGROUND"]`。实际上，对于任何基于服务的镜像，均建议使用这种形式的指令

在大多数情况下，应该为`CMD`提供一个交互式`shell`，比如`CMD ["perl", "-de0"], CMD ["python"], or CMD ["php", "-a"]`。使用这种格式意味着，当执行`docker run -it python`之类的操作时，将被放入一个可用的`shell`中。除非已经非常熟悉`ENTRYPOINT`的工作原理，否则很少使用`CMD ["param"，"param"]`与[ENTRYPOINT](https://docs.docker.com/engine/reference/builder/#entrypoint)一起使用

### EXPOSE

参考：[Dockerfile reference for the EXPOSE instruction](https://docs.docker.com/engine/reference/builder/#expose)

`EXPOSE`指令指示容器侦听连接的端口。因此您应该为应用程序使用通用的传统端口。例如，包含`Apache web`服务器的镜像将使用`EXPOSE 80`，而包含`MongoDB`的镜像将使用`EXPOSE 27017`等等

对于外部访问，用户可以使用指示如何将指定端口映射到所选端口的标志来执行`docker run`。对于容器链接，`Docker`为从收件人容器返回到源的路径提供环境变量（比如`MYSQL_PORT_3306_TCP`）

### ENV

参考：[Dockerfile reference for the ENV instruction](https://docs.docker.com/engine/reference/builder/#env)

为了使新软件更易于运行，可以使用`ENV`为容器安装的软件更新`PATH`环境变量。例如，`ENV PATH /usr/local/nginx/bin:$PATH`确保`CMD ["nginx"]`正常工作

`ENV`指令对于提供特定于要包含的服务（如`Postgres`的`PGDATA`）所需的环境变量也很有用

最后，`ENV`还可以用于设置常用的版本号，以便更容易维护版本冲突，如下例所示：

```
ENV PG_MAJOR 9.3
ENV PG_VERSION 9.3.4
RUN curl -SL http://example.com/postgres-$PG_VERSION.tar.xz | tar -xJC /usr/src/postgress && …
ENV PATH /usr/local/postgres-$PG_MAJOR/bin:$PATH
```

与在程序中使用常量变量（与硬编码值相反）类似，此方法允许更改单个`ENV`指令，就能自动地在容器中修改软件版本

每个`ENV`行创建一个新的中间层，就像`RUN`命令一样。这意味着，即使您在未来的层中取消设置环境变量，它仍然存在于该层中，并且其值可以被转储。您可以通过创建一个`Dockerfile`（如下所示，镜像名为`test`），然后构建它来测试这一点

```
FROM alpine
ENV ADMIN_USER="mark"
RUN echo $ADMIN_USER > ./mark
RUN unset ADMIN_USER
```

```
$ docker run --rm test sh -c 'echo $ADMIN_USER'
mark
```

要防止这种情况，并真正取消设置环境变量，请将`RUN`命令与`shell`命令一起使用，以便在单个层中设置、使用和取消设置变量。可以使用`;`或者`&&`分离。如果使用第二种方法，其中一个命令失败，`docker build`也会失败。使用`\`作为`Linux Dockerfiles`的行继续字符可以提高可读性。还可以将所有命令放入`shell`脚本，并让`RUN`命令只运行该`shell`脚本

```
FROM alpine
RUN export ADMIN_USER="mark" \
    && echo $ADMIN_USER > ./mark \
    && unset ADMIN_USER
CMD sh
```

```
$ docker run --rm test sh -c 'echo $ADMIN_USER'

```

### ADD or COPY

参考：

[Dockerfile reference for the ADD instruction](https://docs.docker.com/engine/reference/builder/#add)

[Dockerfile reference for the COPY instruction](https://docs.docker.com/engine/reference/builder/#copy)

虽然`ADD`和`COPY`在功能上是相似的，但是一般来说，`COPY`是首选的。`COPY`只支持将本地文件复制到容器中，而`ADD`具有一些不明显的功能（例如本地`tar`提取和远程`URL`支持）。因此，`ADD`的最佳用途是将本地`tar`文件自动提取到镜像中，如`ADD rootfs.tar.xz /`中所示

如果有多个`Dockerfile`步骤使用上下文中的不同文件，请分别复制它们，而不是一次全部复制。这将确保只有在特定需要的文件更改时，每个步骤的生成缓存才会失效（强制重新运行该步骤）。比如

```
COPY requirements.txt /tmp/
RUN pip install --requirement /tmp/requirements.txt
COPY . /tmp/
```

与放置`COPY . /tmp/`语句在`RUN`之前相比，`RUN`步骤的缓存失效次数更少

因为镜像大小很重要，所以强烈建议不要使用`ADD`从远程`url`获取包；应该使用`curl`或者`wget`。这样你就可以删除那些在提取后不再需要的文件，而不必在镜像中添加另一层。例如应该避免做如下事情：

```
ADD http://example.com/big.tar.xz /usr/src/things/
RUN tar -xJf /usr/src/things/big.tar.xz -C /usr/src/things
RUN make -C /usr/src/things all
```

相反，你可以这样做：

```
RUN mkdir -p /usr/src/things \
    && curl -SL http://example.com/big.tar.xz \
    | tar -xJC /usr/src/things \
    && make -C /usr/src/things all
```

对于不需要`ADD`的`tar`自动提取功能的其他项（文件、目录），应始终使用`COPY`

### ENTRYPOINT

参考：[Dockerfile reference for the ENTRYPOINT instruction](https://docs.docker.com/engine/reference/builder/#entrypoint)

`ENTRYPOINT`（入口点）的最佳用途是设置镜像的`main`命令，允许镜像如同该命令一样运行（然后使用`CMD`作为默认标志）

从命令行工具`ls`的镜像示例开始：

```
ENTRYPOINT ["ls"]
CMD ["-al"]
```

现在可以这样运行镜像以显示命令的帮助：

```
$ docker run ls:v1
total 72
drwxr-xr-x   1 root root 4096 Sep 18 12:35 .
drwxr-xr-x   1 root root 4096 Sep 18 12:35 ..
-rwxr-xr-x   1 root root    0 Sep 18 12:35 .dockerenv
drwxr-xr-x   2 root root 4096 Aug  7 13:03 bin
...
...
```

这很有用，因为镜像名称可以作为对二进制文件的引用，如上面的命令所示

`ENTRYPOINT`指令也可以与`helper`脚本结合使用，允许它以与上面的命令类似的方式工作，即使启动该工具可能需要多个步骤

例如，[Postgres官方镜像](https://hub.docker.com/_/postgres/)使用以下脚本作为ENTRYPOINT：

```
#!/bin/bash
set -e

if [ "$1" = 'postgres' ]; then
    chown -R postgres "$PGDATA"

    if [ -z "$(ls -A "$PGDATA")" ]; then
        gosu postgres initdb
    fi

    exec gosu postgres "$@"
fi

exec "$@"
```

此脚本使用`exec bash`命令，以便最终运行的应用程序成为容器的`PID 1`。这允许应用程序接收发送到容器的任何`UNIX`信号。有关更多信息参考[ENTRYPOINT reference](https://docs.docker.com/engine/reference/builder/#entrypoint)

`helper`脚本被复制到容器中，并在容器开始时通过`ENTRYPOINT`运行：

```
COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["postgres"]
```

此脚本允许用户以多种方式与`Postgres`交互

它可以简单地启动`Postgres`：

```
$ docker run postgres
```

或者它可以用于运行`Postgres`并将参数传递给服务器：

```
$ docker run postgres postgres --help
```

最后它还可以用于启动完全不同的工具，例如`bash`：

```
$ docker run --rm -it postgres bash
```

### VOLUME

参考：[Dockerfile reference for the VOLUME instruction](https://docs.docker.com/engine/reference/builder/#volume)

`VOLUME`指令应该用于公开由`Docker`容器创建的任何数据库存储区域、配置存储或文件/文件夹。强烈建议将`VOLUME`用于镜像的任何可变和/或用户可维护的部分

### USER

参考：[Dockerfile reference for the USER instruction](https://docs.docker.com/engine/reference/builder/#user)

如果服务可以在没有权限的情况下运行，请使用`USER`更改为非`root`用户。首先在`Dockerfile`中创建用户和组，比如`RUN groupadd -r postgres && useradd --no-log-init -r -g postgres postgres`

避免安装或使用`sudo`，因为它具有不可预测的`tty`和信号转发行为，可能导致问题。如果绝对需要类似于`sudo`的功能，例如将守护进程初始化为`root`，但将其作为非`root`运行，请考虑使用[gosu](https://github.com/tianon/gosu)

最后，为了减少层次和复杂性，避免频繁地来回切换用户

#### 考虑一个显式的UID/GID

镜像中的用户和组被分配一个不确定的`UID/GID`，因为无论镜像重建如何，都会分配另一个`UID/GID`。所以，如果它是关键的，应该指定一个显式的`UID/GID`

由于`go archive/tar`包对稀疏文件的处理中有一个[未解决的错误](https://github.com/golang/go/issues/13548)，试图在`Docker`容器中创建一个`UID`非常大的用户可能会导致磁盘耗尽，因为容器层中的`/var/log/faillog`包含空（`\0`）字符。解决方法是将`--no-log-init`标志传递给`useradd`。`Debian/Ubuntu adduser`不支持此标志

### WORKDIR

参考：[Dockerfile reference for the WORKDIR instruction](https://docs.docker.com/engine/reference/builder/#workdir)

为了清晰和可靠，对于`WORKDIR`应该始终使用绝对路径。此外应该使用`WORKDIR`而不是像`RUN cd … && do-something`这样的复杂指令，这些指令很难阅读、排除故障和维护

### ONBUILD

参考：[Dockerfile reference for the ONBUILD instruction](https://docs.docker.com/engine/reference/builder/#onbuild)

`ONBUILD`命令在当前`Dockerfile`构建完成后执行。`ONBUILD`在从当前镜像派生的任何子镜像中执行。把`ONBUILD`命令看作父`Dockerfile`给子`Dockerfile`的指令

`Docker`构建在子`Dockerfile`中的任何命令之前执行`ONBUILD`命令

`ONBUILD`对于将从给定镜像生成的镜像非常有用。例如使用`ONBUILD`来生成语言栈镜像，该镜像在`Dockerfile`中生成用该语言编写的任意用户软件，如您在`Ruby`的`ONBUILD`[变量](https://github.com/docker-library/ruby/blob/c43fef8a60cea31eb9e7d960a076d633cb62ba8d/2.4/jessie/onbuild/Dockerfile)中所看到的

使用`ONBUILD`构建的镜像应该有一个单独的标记，例如：`ruby:1.9-onbuild`或`ruby:2.0-onbuild`

在`ONBUILD`中放入`ADD`或`COPY`时要小心。如果新构建的上下文缺少要添加的资源，`onbuild`镜像将灾难性地失败。如前所述，添加一个单独的标记，允许`Dockerfile`作者做出选择，有助于减轻这种情况

## Examples for Official Images

这些官方镜像有示范性的`Dockerfile`文件：

* [GO](https://hub.docker.com/_/golang/)
* [Perl](https://hub.docker.com/_/perl/)
* [Hy](https://hub.docker.com/_/hylang/)
* [Ruby](https://hub.docker.com/_/ruby/)

## Additional resources:

* [Dockerfile Reference](https://docs.docker.com/engine/reference/builder/)
* [More about Base Images](https://docs.docker.com/develop/develop-images/baseimages/)
* [More about Automated Builds](https://docs.docker.com/docker-hub/builds/)
* [Guidelines for Creating Official Images](https://docs.docker.com/docker-hub/official_images/)