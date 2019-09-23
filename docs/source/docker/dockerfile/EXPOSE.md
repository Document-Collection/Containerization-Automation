
# EXPOSE

参考：[EXPOSE](https://docs.docker.com/engine/reference/builder/#expose)

`EXPOSE`指令通知`docker`容器在运行时侦听指定的网络端口

## 语法

```
EXPOSE <port> [<port>/<protocol>...]
```

* 端口号可以任意指定
* 协议指定端口是侦听`TCP`还是`UDP`，默认为`TCP`

```
# 指定TCP协议端口为80
EXPOSE 80
# 指定UDP协议端口为80
EXPOSE 80/udp
```

## 作用

`EXPOSE`指令实际上并不发布端口，它用于提示要发布的端口。使用`docker run`启动容器时，有`2`种方式指定容器监听的端口号

1. 使用标识符`-P, --publish-all`来发布`EXPOSE`指定的端口，`docker`会随机映射主机端口到容器的侦听端口
2. 使用标识符`-p, --publish`指定容器和主机的映射端口

    ```
    -p host-port:container-port/<protocol>
    # 比如映射主机端口号80到容器8080端口，侦听TCP协议
    -p 80:8080/tcp
    ```

## 示例

可以同时设定`TCP`和`UDP`监听端口为同一个，因为容器会将其映射到不同的主机端口

```
EXPOSE 80/tcp
EXPOSE 80/udp
```

使用`-p`标识符指定映射端口如下：

```
$ docker run -it -p 10001:80/tcp -p 10002:80/udp ...
```