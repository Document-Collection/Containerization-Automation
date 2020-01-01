
# 使用docker-compose还是docker run

学习了`Docker`和`Docker Compose`，通过`Dockerfile`文件进行镜像的构建，通过`docker-compose.yml`文件进行容器的运行

在实际操作过程中，`docker-compose`操作的优点很明显

优点：

1. 通过`docker-compose.yml`文件配置容器启动选项，结构清晰
2. 能够实现多容器的管理

不过这种方式存在一个缺陷，那就是**在`docker-compose.yml`中仅能使用环境变量，无法操作`shell`命令**

比如获取当前用户信息

```
$ id -u
$ id -g
```