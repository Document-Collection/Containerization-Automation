
# [Ubuntu 16.04]docker启动设置

参考：[Control Docker with systemd](https://docs.docker.com/config/daemon/systemd/)

使用命令`systemctl`或`service`实现`docker`守护进程的启动和关闭

## systemctl使用

查看`docker`状态

```
$ systemctl status docker
● docker.service - Docker Application Container Engine
   Loaded: loaded (/lib/systemd/system/docker.service; disabled; vendor preset: enabled)
   Active: inactive (dead) since 四 2019-09-19 19:13:51 CST; 3s ago
     Docs: https://docs.docker.com
...
...
```

启动`docker`

```
$ systemctl start docker
```

关闭`docker`

```
$ systemctl stop docker
```

## service使用

查看`docker`状态

```
$ service docker status
● docker.service - Docker Application Container Engine
   Loaded: loaded (/lib/systemd/system/docker.service; disabled; vendor preset: enabled)
   Active: inactive (dead) since 四 2019-09-19 19:13:51 CST; 2min 51s ago
     Docs: https://docs.docker.com
 Main PID: 8263 (code=exited, status=0/SUCCESS)
...
...
```

启动`docker`

```
$ service docker start
```

关闭`docker`

```
$ service docker stop
```
