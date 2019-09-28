
# [Docker][SSH]远程登录Ubuntu

参考：

[ssh远程连接docker中的container](https://blog.csdn.net/vincent2610/article/details/52490397)

[Dockerize an SSH service](https://docs.docker.com/engine/examples/running_ssh_service/)

通过`docker`启动`Ubuntu`镜像，通过`ssh`进行远程登录

## Dockerfile

参考：[sshd命令](https://man.linuxde.net/sshd)

编写`Dockerfile`文件实现`ssh`应用安装，密码设置以及`sshd`命令后台运行

```
FROM zjzstu/ubuntu:18.04

RUN apt-get update && apt-get install -y openssh-server
RUN mkdir /var/run/sshd
RUN echo 'root:THEPASSWORDYOUCREATED' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
```

* `FROM`指令使用`zjzstu/ubuntu:18.04`作为父镜像
* `RUN`指令更新已安装应用，同时安装`openssh-server`
* `RUN`指令创建文件夹`/var/run/sshd`
* `RUN`指令指定登录密码，修改`THEPASSWORDYOUCREATED`为自定义密码
* `RUN`指令允许`ssh`登录`root`账户，修改文件`/etc/ssh/sshd_config`中的`#PermitRootLogin prohibit-password`为`PermitRootLogin yes`
    * 对于`Ubuntu 14.04`而言，默认设置为`PermitRootLogin without-password`
    * **注意**：对于`Ubuntu 16.04`而言，`ssh`默认打开了`PermitRootLogin`功能；对于`Ubuntu 18.04`而言，`ssh`默认关闭了`PermitRootLogin`功能。所以如果使用`Ubuntu 16.04`，需要将`#`号去除
* `RUN`指令设置`/etc/pam.d/sshd`，防止用户在登录后将被踢出
* `EXPOSE`指令设置容器监听端口`22`
* `CMD`指令设置容器启动`sshd`，并在后台运行（`-D`表示以后台守护进程方式运行服务器）

## 执行

首先生成镜像`zjzstu/ubuntu:18.04-ssh`，实现如下：

```
$ docker build -t zjzstu/ubuntu:18.04-ssh .
```

启动镜像生成容器`test_sshd`，实现如下：

```
$ docker run -d -P --name test_sshd zjzstu/ubuntu:18.04-ssh
1b44046832b4fd13b1c60921567a431e5aff3bd4fe753ebb6c1e29b2df277828
```

* 参数`-d`表示后台运行
* 参数`-P`表示将容器的端口（`22`）发布到主机
* 参数`--name`表示设置容器名

使用命令`docker port`查询容器映射的主机端口

```
$ docker ps
CONTAINER ID        IMAGE                     COMMAND               CREATED              STATUS              PORTS                   NAMES
1b44046832b4        zjzstu/ubuntu:18.04-ssh   "/usr/sbin/sshd -D"   About a minute ago   Up About a minute   0.0.0.0:32769->22/tcp   test_sshd

$ docker port 1b44
22/tcp -> 0.0.0.0:32769
```

即可在主机使用`ssh`连接容器`test_sshd`

```
$ ssh root@127.0.0.1 -p 32769
The authenticity of host '[127.0.0.1]:32769 ([127.0.0.1]:32769)' can't be established.
ECDSA key fingerprint is SHA256:LYUoJeWTbnRgJDxjvtAbukkhVRRXPiDHliUPg/c8wyI.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '[127.0.0.1]:32769' (ECDSA) to the list of known hosts.
root@127.0.0.1's password: 
...
...
root@1b44046832b4:~# 
```

## 自定义

1. 主机`IP 127.0.0.1`可以替换为`localhost`
    
    ```
    $ ssh root@localhost -p 32769
    ```
2. 可以在启动容器时指定主机端口号

    ```
    $ docker run -d -p 32212:22 --name test_sshd zjzstu/ubuntu:18.04-ssh
    ```
    参数`-p`将容器端口`22`映射到主机端口`32212`

## 环境变量

`sshd`会在启动`shell`之前对会对环境进行清理，通过`Dockerfile`中`ENV`指令输入的环境变量将会失效

有两种解决方法：

1. 在`Dockerfile`中输入环境变量到`shell`初始文件，比如`/etc/profile`

    ```
    ...
    # 无效
    ENV NOTVISIBLE "in users profile"
    # 有效
    RUN echo "export VISIBLE=now" >> /etc/profile

    EXPOSE 22
    CMD ["/usr/sbin/sshd", "-D"]
    ```

2. 启动容器时手动设置

    ```
    $ docker run -e ENV=value ...
    ```