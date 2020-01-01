
# Compose文件格式概述

参考：[Compose file version 3 reference](https://docs.docker.com/compose/compose-file/)

之前配置完`Dockerfile`文件后，通过命令进行构建（`build`）和运行（`run`）。除此之外，`docker`提供了工具`docker-compose`来辅助容器编排，通过`docker-compose.yml`文件进行配置

*`docker-compose`文件格式涉及诸多参数和设置，当前仅学习使用到的功能，之后再逐步更新*

## 文件概述

示例`docker-compose.yml`文件如下：

```
version: "3.7"
services:

  redis:
    image: redis:alpine
    ports:
      - "6379"
    networks:
      - frontend
    deploy:
      replicas: 2
      update_config:
        parallelism: 2
        delay: 10s
      restart_policy:
        condition: on-failure

  db:
    image: postgres:9.4
    volumes:
      - db-data:/var/lib/postgresql/data
    networks:
      - backend
    deploy:
      placement:
        constraints: [node.role == manager]

networks:
  frontend:
  backend:

volumes:
  db-data:
```

`compose`文件包含了`4`个顶级键：

1. `version`：指定文件规范版本
2. [services](https://docs.docker.com/compose/compose-file/#service-configuration-reference)：指定要操作的容器
3. [networks](https://docs.docker.com/compose/compose-file/#network-configuration-reference)：指定共用的网络配置
4. [volumes](https://docs.docker.com/compose/compose-file/#volume-configuration-reference)：指定共用的存储配置

在顶级键下面指定了要配置的章节，在章节下面按`<key>: <option>: <value>`的形式进行参数配置

## 查询文件

可以使用`docker-compose config`验证和查看待操作的`Compose`文件

```
$ docker-compose config
services:
  test:
    build:
      args:
        TE: sadfadf
      context: /home/zj/dockerfiles/compose-build
    container_name: my-web-container
    image: compose:0.2.0
version: '3.7'
```