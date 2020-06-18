
# Compose安装

参考：[Install Docker Compose](https://docs.docker.com/compose/install/)

## 必要条件

需要先安装`Docker`，参考[Docker安装](../basic/安装.md)

## 安装

下载`Compose`二进制文件到`/usr/local/bin`

```
$ sudo curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
```

**从官网上找到上面这一步，获取最新的版本**

授予可执行权限

```
$ sudo chmod +x /usr/local/bin/docker-compose
```

测试是否安装成功

```
$ docker-compose version
docker-compose version 1.24.1, build 4667896b
docker-py version: 3.7.3
CPython version: 3.6.8
OpenSSL version: OpenSSL 1.1.0j  20 Nov 2018
```

## 升级

如果正在从`Compose 1.2`或更早升级，删除或迁移升级后的现有容器。这是因为，在第`1.3`版中，`Compose`使用`Docker`标签来跟踪容器，并且需要重新创建容器来添加标签

如果`Compose`检测到没有标签创建的容器会拒绝运行。如果想继续使用现有的容器（例如，因为它们拥有要保存的数据卷），可以使用`Compose 1.5.x`以以下命令迁移它们：

```
docker-compose migrate-to-labels
```

或者，如果你不担心保存它们，你可以移除它们。`Compose`只是创造新的

```
docker container rm -f -v myapp_web_1 myapp_db_1 ...
```

## 卸载

如果使用`curl`安装，卸载方式如下：

```
sudo rm /usr/local/bin/docker-compose
```

如果使用`pip`安装，卸载方式如下：

```
pip uninstall docker-compose
```

### Got a “Permission denied” error?

如果使用上述任一方法时出现`Permission denied`错误，则可能没有删除`docker-compose`的适当权限。若要强制删除，将`sudo`置于上述任一命令的前面，然后再次运行