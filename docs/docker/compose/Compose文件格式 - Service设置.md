# Compose文件格式 - Service设置

参考：[Compose file version 3 reference](https://docs.docker.com/compose/compose-file/)

`Service`可以指定一个或多个容器的配置

## 指定镜像

使用键`image`指定启动容器的镜像

```
image: compose:latest
image: compose:0.2.0
```

如果镜像不存在本地，那么`compose`会从远程进行拉取，除非额外设置了`build`键进行构建

**注意：即使设置了多个，仅会使用最后一个`image`键值对**

## 构建镜像

使用键`build`指定要构建的镜像：

1. `context`：包含`Dockerfile`的目录
2. `dockerfile`：指定要使用的`Dockerfile`文件路径
3. `args`：指定构建阶段的参数
4. `labels`：添加镜像元数据，其作用类似于`LABEL`标签

示例如下：

```
build:
    context: ./dir/
    dockerfile: /path/to/Dockerfile-alternate
    args:
        buildno: 1
        gitcommithash: cdc3b19
    labels:
        - "com.example.description=Accounting webapp"
        - "com.example.department=Finance"
        - "com.example.label-with-empty-value"
```

**注意一：当不需要额外设置，仅指定`context`选项时，可以使用以下方式**

```
build: ./dir/
```

**注意二：设置构建参数时，需要现在`Dockerfile`文件中指定参数名**

```
# Dockerfile
ARG buildno
ARG gitcommithash

RUN echo "Build number: $buildno"
RUN echo "Based on commit: $gitcommithash"

# docker-compose
  args:
    - buildno=1
    - gitcommithash=cdc3b19
# 或者
  args:
    buildno: 1
    gitcommithash: cdc3b19
```

## 容器名设置

```
container_name: my-web-container
```

## 容器启动设置

涉及两个键：`command`和`entrypoint`

### 启动命令command

重写默认的`COMMAND`命令

```
command: bundle exec thin -p 3000
# 或者
command: ["bundle", "exec", "thin", "-p", "3000"]
```

### 入口点程序entrypoint

重写`ENTRYPOINT`命令指定的文件

```
entrypoint: /code/entrypoint.sh
```

## 环境变量设置

涉及两个键: `env_file`和`environment`

### 直接添加环境变量

使用`environment`可以直接设置环境变量

```
environment:
  RACK_ENV: development
  SHOW: 'true'
  SESSION_SECRET:
# 或者
environment:
  - RACK_ENV=development
  - SHOW=true
  - SESSION_SECRET
```

### 使用配置文件

使用`env_file`键指定环境变量配置文件（可以指定多个配置文件）

```
services:
  some-service:
    env_file:
      - a.env
      - b.env
```

配置文件的格式为

```
# a.env
VAR=1
# b.env
VAR=hello
```

**注意：重复设置的环境变量会被覆盖**

## 硬件设备映射

使用键`devices`指定容器和主机之间映射的设备

```
devices:
    - "/dev/ttyUSB0:/dev/ttyUSB0"
```

或者设置`privileged: true`允许容器操作所有主机硬件

## 端口设置

### 指定内部端口

使用键`expose`指定服务内部容器之间开放的端口

```
expose:
    - "3000"
    - "8000"
```

### 指定外部端口

使用键`ports`指定主机映射的端口

* 短格式语法：指定主机和容器端口（`HOST:CONTAINER`）或者仅指定容器端口（主机端口临时设置）

```
ports:
 - "3000"
 - "3000-3005"
 - "8000:8000"
 - "9090-9091:8080-8081"
 - "49100:22"
 - "127.0.0.1:8001:8001"
 - "127.0.0.1:5000-5010:5000-5010"
 - "6060:6060/udp"
```

* 长格式语法：...
 
## 添加元数据

除了使用`build`进行镜像构建时设置元数据，还可以通过`labels`键设置容器的元数据

```
labels:
  com.example.description: "Accounting webapp"
  com.example.department: "Finance"
  com.example.label-with-empty-value: ""
# 或者
labels:
  - "com.example.description=Accounting webapp"
  - "com.example.department=Finance"
  - "com.example.label-with-empty-value"
```

## 重启设置

使用键`restart`指定重启设置

```
restart: "no" 　　　　　　# 默认设置，任何情况下不重启容器
restart: always                       # 无论哪种情况都要重启 
restart: on-failure                 # 仅在容器启动失败时重启
restart: unless-stopped
```

## 主机名设置

```
hostname: foo
```

## 终端设置

```
tty: true
```