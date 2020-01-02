
# Compose文件格式 - 存储设置

存储设置分两部分，一是在单个容器上设置，二是设置多容器共用的卷

## 单容器存储设置

参考：[volumes](https://docs.docker.com/compose/compose-file/#volumes)

可以为每个容器单独指定和主机的存储设置（*绑定挂载设置或卷设置*），示例如下

```
version: "3.7"
services:
  web:
    image: nginx:alpine
    volumes:
      - type: volume
        source: mydata
        target: /data
        volume:
          nocopy: true
      - type: bind
        source: ./static
        target: /opt/app/static

  db:
    image: postgres:latest
    volumes:
      - "/var/run/postgres/postgres.sock:/var/run/postgres/postgres.sock"
      - "dbdata:/var/lib/postgresql/data"

volumes:
  mydata:
  dbdata:
```

**注意：命名卷必须列在顶级键`volumes`下**

有两种语法：

1. 短格式语法
2. 长格式语法

#### 短格式语法

同时指定主机和容器的路径（`HOST:CONTAINER`），还可以添加访问模式（`HOST:CONTAINER:ro`）

```
volumes:
  # Just specify a path and let the Engine create a volume
  - /var/lib/mysql                                                                           # 仅指定单个路径，会生成一个mysql卷

  # Specify an absolute path mapping
  - /opt/data:/var/lib/mysql                                                      # 使用绝对路径进行绑定挂载

  # Path on the host, relative to the Compose file
  - ./cache:/tmp/cache                                                                # 使用相对路径进行绑定挂载

  # User-relative path
  - ~/configs:/etc/configs/:ro                                                     # 指定访问模式为只读

  # Named volume
  - datavolume:/var/lib/mysql                                                  # 卷设置
```

#### 长格式语法

．．．

## 多容器存储设置

参考：[Volume configuration reference](https://docs.docker.com/compose/compose-file/#volume-configuration-reference)

在顶级键`volumes`可以命名多个卷，在多个容器之间使用

```
version: "3.7"

services:
  db:
    image: db
    volumes:
      - data-volume:/var/lib/db
  backup:
    image: backup-service
    volumes:
      - data-volume:/var/lib/backup/data

volumes:
  data-volume:
```

### external

参考：[docker使用小记6 - docker-compose挂载数据卷出现的问题](https://www.cnblogs.com/qvennnnn/p/11732324.html)

顶级键`volumes`包含多个属性，`external`属性默认设置为`false`，启动容器时会创建一个命名为`[projectname]_[volumename]`的卷；如果已存在待使用的卷，可以设置`external`属性为`true`，那么启动容器时会直接使用命名为`volumename`的卷。示例如下：

```
version: "3.7"

services:
  db:
    image: postgres
    volumes:
      - data:/var/lib/postgresql/data

volumes:
  data:
    external: true
```