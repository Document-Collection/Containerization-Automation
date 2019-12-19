
# docker build运行apt-get update失败

进入`ubuntu:18.04`容器，运行`apt-get update`失败

```
$ docker run -it ubuntu:18.04
root@06f6c91954e1:/# apt-get update
Err:1 http://security.ubuntu.com/ubuntu bionic-security InRelease        
  Temporary failure resolving 'security.ubuntu.com'
Err:2 http://archive.ubuntu.com/ubuntu bionic InRelease                  
  Temporary failure resolving 'archive.ubuntu.com'
Err:3 http://archive.ubuntu.com/ubuntu bionic-updates InRelease
  Temporary failure resolving 'archive.ubuntu.com'
Err:4 http://archive.ubuntu.com/ubuntu bionic-backports InRelease
  Temporary failure resolving 'archive.ubuntu.com'
Reading package lists... Done        
W: Failed to fetch http://archive.ubuntu.com/ubuntu/dists/bionic/InRelease  Temporary failure resolving 'archive.ubuntu.com'
W: Failed to fetch http://archive.ubuntu.com/ubuntu/dists/bionic-updates/InRelease  Temporary failure resolving 'archive.ubuntu.com'
W: Failed to fetch http://archive.ubuntu.com/ubuntu/dists/bionic-backports/InRelease  Temporary failure resolving 'archive.ubuntu.com'
W: Failed to fetch http://security.ubuntu.com/ubuntu/dists/bionic-security/InRelease  Temporary failure resolving 'security.ubuntu.com'
W: Some index files failed to download. They have been ignored, or old ones used instead.
root@06f6c91954e1:/# 
```

### 发现问题

测试是否是`DNS`解析出错，测试命令如下：

``` 
$ docker run busybox nslookup baidu.com
nslookup: write to '127.0.1.1': Connection refused
;; connection timed out; no servers could be reached
```

启动镜像`busybox`，使用`nslookup`搜索`baidu.com`对应`IP`，发现没有找到`DNS`服务器

### 解决

参考[SOLVED: Docker build “Could not resolve ‘archive.ubuntu.com’” apt-get fails to install anything](https://medium.com/@faithfulanere/solved-docker-build-could-not-resolve-archive-ubuntu-com-apt-get-fails-to-install-anything-9ea4dfdcdcf2)，默认`Docker`使用`8.8.8.8`作为`DNS`服务器地址，而不是主机的`DNS`服务器地址

搜索主机的`DNS`服务器：

```
$ nmcli dev show | grep 'IP4.DNS'
IP4.DNS[1]:                             192.168.0.1
```

**临时解决方式：参数配置**

```
$ docker run --dns 192.168.0.1 busybox nslookup www.baidu.com
Server:		192.168.0.1
Address:	192.168.0.1:53

Non-authoritative answer:
www.baidu.com	canonical name = www.a.shifen.com
Name:	www.a.shifen.com
Address: 112.80.248.76
Name:	www.a.shifen.com
Address: 112.80.248.75

*** Can't find www.baidu.com: No answer
```

**永久解决方式：配置Docker守护进程**

修改配置文件`/etc/docker/daemon.json`，添加主机`DNS`服务器后重启`Docker`守护进程

```
{
    "dns": ["192.168.0.1", "8.8.8.8", "8.8.4.4"]
}
```

*后面两个地址是google提供的DNS服务器地址*

```
$ systemctl restart docker

$ docker run busybox nslookup baidu.com
Server:		192.168.0.1
Address:	192.168.0.1:53

Non-authoritative answer:
Name:	baidu.com
Address: 220.181.38.148
Name:	baidu.com
Address: 39.156.69.79

*** Can't find baidu.com: No answer
```