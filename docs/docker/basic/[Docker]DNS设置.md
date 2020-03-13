
# [Docker]DNS设置

参考：

[daemon](https://docs.docker.com/engine/reference/commandline/dockerd/)

[Container networking](https://docs.docker.com/config/containers/container-networking/)

## 全局设置

在`docker`配置文件`/etc/docker/daemon.json`中设置

```
$ cat /etc/docker/daemon.json 
{
  "dns": ["119.29.29.29", "223.5.5.5", "223.6.6.6"]
}
```

重新启动`docker`服务

```
$ sudo /etc/init.d/docker restart
```

## 容器设置

使用属性`--dns`指定要载入容器的`DNS`

```
$ docker run -it --dns 233.5.5.5 --dns 233.6.6.6 ubuntu bash
```