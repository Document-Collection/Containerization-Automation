
# 使用docker-compose还是docker run

学习了`Docker`和`Docker Compose`，通过`Dockerfile`文件进行镜像的构建，通过`docker-compose.yml`文件进行容器的编排

在实际操作过程中，`docker-compose`操作的优点很明显

1. 通过`docker-compose.yml`文件配置容器启动选项，结构清晰
2. 能够实现多容器的管理

不过`docker-compose`还在不断更新中，存在不少问题：

1. 在`docker-compose.yml`中仅能使用环境变量，无法操作`shell`命令

比如获取当前用户信息

```
$ id -u
$ id -g
```

2. 在语法版本`3.7`中无法设置`NVIDIA`

参考：

[Support for NVIDIA GPUs under Docker Compose #6691](https://github.com/docker/compose/issues/6691)

[docker-compose support #1073](https://github.com/NVIDIA/nvidia-docker/issues/1073)

[NVIDIA Container Toolkit](https://github.com/NVIDIA/nvidia-docker)

>Please note that this native GPU support has not landed in docker-compose yet. Refer to this issue for discussion.