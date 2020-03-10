
# [alpine]源配置

## 问题

默认`alpine`源地址可通过`/etc/apk/repositories`文件查看

```
$ docker run -it alpine
/ # cd /etc/apk/
/etc/apk # pwd
/etc/apk
/etc/apk # ls
arch               keys               protected_paths.d  repositories       world
/etc/apk # 
/etc/apk # cat repositories 
http://dl-cdn.alpinelinux.org/alpine/v3.11/main
http://dl-cdn.alpinelinux.org/alpine/v3.11/community
```

使用默认源无法下载应用，以`NodeJS`为例

```
/etc/apk # apk add nodejs
fetch http://dl-cdn.alpinelinux.org/alpine/v3.11/main/x86_64/APKINDEX.tar.gz
ERROR: http://dl-cdn.alpinelinux.org/alpine/v3.11/main: temporary error (try again later)
WARNING: Ignoring APKINDEX.70f61090.tar.gz: No such file or directory
fetch http://dl-cdn.alpinelinux.org/alpine/v3.11/community/x86_64/APKINDEX.tar.gz
ERROR: http://dl-cdn.alpinelinux.org/alpine/v3.11/community: temporary error (try again later)
WARNING: Ignoring APKINDEX.ca2fea5b.tar.gz: No such file or directory
ERROR: unsatisfiable constraints:
  nodejs (missing):
    required by: world[nodejs]
```

## 解析

参考[Alpine Linux 源使用帮助](https://mirrors.ustc.edu.cn/help/alpine.html)，替换成国内镜像源

```
/etc/apk # sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories
/etc/apk # 
/etc/apk # cat repositories 
http://mirrors.ustc.edu.cn/alpine/v3.11/main
http://mirrors.ustc.edu.cn/alpine/v3.11/community
```

配置`NodeJS`环境如下

```
/etc/apk # apk add nodejs
fetch http://mirrors.ustc.edu.cn/alpine/v3.11/main/x86_64/APKINDEX.tar.gz
fetch http://mirrors.ustc.edu.cn/alpine/v3.11/community/x86_64/APKINDEX.tar.gz
(1/7) Installing ca-certificates (20191127-r1)
(2/7) Installing c-ares (1.15.0-r0)
(3/7) Installing libgcc (9.2.0-r3)
(4/7) Installing nghttp2-libs (1.40.0-r0)
(5/7) Installing libstdc++ (9.2.0-r3)
(6/7) Installing libuv (1.34.0-r0)
(7/7) Installing nodejs (12.15.0-r1)
Executing busybox-1.31.1-r9.trigger
Executing ca-certificates-20191127-r1.trigger
OK: 36 MiB in 21 packages
/etc/apk # 
/etc/apk # apk add npm
(1/1) Installing npm (12.15.0-r1)
Executing busybox-1.31.1-r9.trigger
OK: 64 MiB in 22 packages
```

## dockerfile

编写一个`Dockerfile`脚本，实现镜像源替换

```
FROM alpine:latest
LABEL maintainer "zhujian <zjzstu@github.com>"

RUN set -eux && sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories
```

### 构建

```
$ docker build -t zjzstu/alpine:latest .
Sending build context to Docker daemon  2.048kB
Step 1/3 : FROM alpine:latest
 ---> e7d92cdc71fe
Step 2/3 : LABEL maintainer "zhujian <zjzstu@github.com>"
 ---> Running in e887d20623cd
Removing intermediate container e887d20623cd
 ---> 260632029e45
Step 3/3 : RUN set -eux && sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories
 ---> Running in 0481eecdd0e9
+ sed -i s/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g /etc/apk/repositories
Removing intermediate container 0481eecdd0e9
 ---> 6c891a208c35
Successfully built 6c891a208c35
```

### 运行

```
$ docker run -it zjzstu/alpine
/ # node
/bin/sh: node: not found
/ # apk add nodejs
fetch http://mirrors.ustc.edu.cn/alpine/v3.11/main/x86_64/APKINDEX.tar.gz
fetch http://mirrors.ustc.edu.cn/alpine/v3.11/community/x86_64/APKINDEX.tar.gz
(1/7) Installing ca-certificates (20191127-r1)
(2/7) Installing c-ares (1.15.0-r0)
(3/7) Installing libgcc (9.2.0-r3)
(4/7) Installing nghttp2-libs (1.40.0-r0)
(5/7) Installing libstdc++ (9.2.0-r3)
(6/7) Installing libuv (1.34.0-r0)
(7/7) Installing nodejs (12.15.0-r1)
Executing busybox-1.31.1-r9.trigger
Executing ca-certificates-20191127-r1.trigger
OK: 36 MiB in 21 packages
/ # 
/ # node -v
v12.15.0
```