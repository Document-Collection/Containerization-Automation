
# [Aliyun]镜像加速

参考：[Docker 镜像加速器](https://yq.aliyun.com/articles/29941)

配置`阿里云镜像加速器`来加快远程镜像下载

## 查询加速地址

登录[容器镜像服务](https://cr.console.aliyun.com/cn-hangzhou/mirrors)控制台，选择左侧的`镜像加速器`，获取`加速器地址`

## `Ubuntu`配置

修改配置文件

    # 没有就新建该文件
    /etc/docker/daemon.json

添加

    {
        "registry-mirrors": ["<your accelerate address>"]
    }

## 测试

重启`docker`服务

    $ sudo /etc/init.d/docker restart
    [ ok ] Restarting docker (via systemctl): docker.service.
    # 或者
    $ sudo systemctl daemon-reload
    $ sudo systemctl restart docker

查看是否已配置

    $ sudo docker info | grep "aliyun"
    https://ssws38gn.mirror.aliyuncs.com/

测试命令

    $ sudo docker run -it ubuntu bash