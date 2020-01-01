
# Compose版本依赖

参考：[Compose and Docker compatibility matrix](https://docs.docker.com/compose/compose-file/#compose-and-docker-compatibility-matrix)

`Docker Compose`分为两个部分：文件格式与应用版本

## 文件格式

`Docker Compose`经历了多次的文件格式调整，不断增加新的内容。其文件格式与`Docker`引擎版本对应如下：

![](./imgs/compose-docker.png)

当前使用的`Compose`文件格式为版本`3.7`，当前`Docker`引擎版本为

```
$ docker info | grep -i server | grep -i version
 Server Version: 19.03.5
```

## 应用版本

直接使用最新版本的程序即可，参考[compose releases](https://github.com/docker/compose/releases/)