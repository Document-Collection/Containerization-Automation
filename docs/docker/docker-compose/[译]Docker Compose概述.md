
# [译]Docker Compose概述

原文地址：[Overview of Docker Compose](https://docs.docker.com/compose/)

`Compose`是一个定义和运行多容器`Docker`应用程序的工具。对于`Compose`而言，通过`YAML`文件配置应用程序，然后使用一个命令即可根据配置文件创建并启动所有服务。更多有关`Compose`的特性可查看[the list of features](https://docs.docker.com/compose/#features)

可以在所有环境中撰写`Compose`：生产（`producing`）、准备（`staging`）、开发（`testing`）、测试以及`CI`工作流。更多用例在[Common Use Case](https://docs.docker.com/compose/#common-use-cases)

`Compose`使用通常分为以下`3`个步骤：

1. 使用`Dockerfile`定义应用程序的环境，以便可以在任何地方复用
2. 在`docker-compose.yml`中定义组成应用程序的服务，以便它们可以在独立的环境中一起运行
3. 运行命令`docker-compose up`，启动`Compose`并运行整个应用程序

`docker-compose.yml`类似如下：

```
version: '3'
services:
  web:
    build: .
    ports:
    - "5000:5000"
    volumes:
    - .:/code
    - logvolume01:/var/log
    links:
    - redis
  redis:
    image: redis
volumes:
  logvolume01: {}
```

更多关于`Compose`文件的信息参考[Compose file reference](https://docs.docker.com/compose/compose-file/)

`Compose`有用于管理应用程序整个生命周期的命令：

* 开始，停止和重建服务
* 查看运行服务的状态
* 流式处理正在运行的服务的日志输出
* 对服务运行一次性命令

## Compose文档

* [Installing Compose](https://docs.docker.com/compose/install/)
* [Getting Started](https://docs.docker.com/compose/gettingstarted/)
* [Get started with Django](https://docs.docker.com/compose/django/)
* [Get started with Rails](https://docs.docker.com/compose/rails/)
* [Get started with WordPress](https://docs.docker.com/compose/wordpress/)
* [Frequently asked questions](https://docs.docker.com/compose/wordpress/)
* [Command line reference](https://docs.docker.com/compose/faq/)
* [Compose file reference](https://docs.docker.com/compose/reference/)
* [Features](https://docs.docker.com/compose/compose-file/)

## 特性

`Compose`特性有：

* [单个主机上的多个隔离环境](https://docs.docker.com/compose/overview/#Multiple-isolated-environments-on-a-single-host)
* [创建容器时保留卷数据](https://docs.docker.com/compose/overview/#preserve-volume-data-when-containers-are-created)
* [仅重新创建已更改的容器](https://docs.docker.com/compose/overview/#only-recreate-containers-that-have-changed)
* [变量和在环境之间移动组合](https://docs.docker.com/compose/overview/#variables-and-moving-a-composition-between-environments)

### 单个主机上的多个隔离环境

`Compose`使用工程名（`project name`）将环境彼此隔离。可以在几个不同的上下文中使用这个工程名：

* 在开发主机上创建单个环境的多个副本，例如当希望为项目的每个特征分支运行一个稳定的副本时
* 在`CI`服务器上，为了避免生成相互干扰，可以将项目名称设置为唯一的生成号
* 在共享主机或开发主机上，以防止可能使用相同服务名称的不同项目相互干扰

默认工程名是工程目录的基名。可以使用[-p命令行选项](https://docs.docker.com/compose/reference/overview/)或[COMPOSE_PROJECT_NAME环境变量](https://docs.docker.com/compose/reference/envvars/#compose-project-name)设置自定义工程名

### 创建容器时保留卷数据

`Compose`保留服务使用的所有卷。运行`docker-compose up`时，如果发现以前运行的任何容器，它会将卷从旧容器复制到新容器。此过程确保在卷中创建的任何数据不会丢失

如果在`Windows`机器上使用`docker compose`，参考[环境变量](https://docs.docker.com/compose/reference/envvars/)，并根据特定需要调整必要的环境变量

### 仅重新创建已更改的容器

`Compose`缓存用于创建容器的配置。当重新启动未更改的服务时，`Compose`重用现有的容器。重用容器意味着可以很快地对环境进行更改

### 变量和在环境之间移动组合

`Compose`支持`Compose`文件中的变量。可以使用这些变量为不同的环境或不同的用户自定义组合。参考[Variable substitution](https://docs.docker.com/compose/compose-file/#variable-substitution)

## 常用示例

`Compose`可以有很多不同的方法。下面概述一些常见的用例

### 开发环境

在开发软件时，在独立环境中运行应用程序并与其交互的能力至关重要。`Compose`命令行工具可用于创建环境并与其交互

[Compose文件](https://docs.docker.com/compose/compose-file/)提供了一种方法来记录和配置所有应用程序的服务依赖关系（数据库、队列、缓存、`Web`服务`API`等）。使用`Compose`命令行工具，可以使用一个命令（`docker-compose up`）为每个依赖项创建和启动一个或多个容器

这些特性共同为开发人员启动项目提供了一种便捷的方式。`Compose`可以减少多页`开发者入门指南`到一个机器可读的`Compose`文件和一些命令

### 自动化测试环境

任何持续部署或持续集成过程的一个重要部分是自动化测试套件。自动化的端到端测试需要一个运行测试的环境。`Compose`为测试套件创建和销毁隔离测试环境提供了一种便捷的方法。通过在[Compose文件](https://docs.docker.com/compose/compose-file/)中定义完整的环境，可以使用几个命令创建和销毁这些环境：

```
$ docker-compose up -d
$ ./run_tests
$ docker-compose down
```

### 单主机部署

`Compose`传统上一直专注于开发和测试工作流程，但随着每个版本，我们正在取得更多的生产为导向的特点。可以使用`Compose`部署到远程`docker`引擎。`Docker`引擎可以是由[Docker Machine](https://docs.docker.com/machine/overview/)提供的单个实例，也可以是整个[Docker Swarm](https://docs.docker.com/engine/swarm/)集群

有关使用面向生产的功能的详细信息，参考本文档中的[compose in production](https://docs.docker.com/compose/production/)

## 版本说明

要查看`Docker Compose`的过去和当前版本的详细更改列表，参考[CHANGELOG](https://github.com/docker/compose/blob/master/CHANGELOG.md) 

## 求助

`Docker Compose`正在积极开发中。如果需要帮助，想投稿，或者只想和志趣相投的人谈谈项目，我们就有一些开放的渠道进行沟通

* 报告错误或文件功能请求，请使用[issue tracker on Github](https://github.com/docker/compose/issues)
* 与人实时地讨论项目：加入`freenode IRC`上的`#docker-compose`频道
* 提交代码或文档更改：在`GITHUB`上提交一个[pull request](https://github.com/docker/compose/pulls)

有关更多信息和资源，访问[Getting Help project page](https://docs.docker.com/opensource/get-help/) 