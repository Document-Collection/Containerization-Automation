
# [volume][bind mount]标识符-v和--mount解析

`docker run`命令的标识符`-v`和`--mount`均可用于卷操作和绑定挂载操作

最开始`-v`仅作用于独立容器（`standalone container`），而`--mount`作用于`swarm`服务。从`Docker 17.06`开始，`--mount`也可作用于独立容器

## 语法

两者语法最大的不同在于`-v`将所有选项组合成一个字段，而`--mount`通过不同字段来配置不同选项

### 卷操作

* `-v --volumes`：由3个字段组成，用冒号（`:`）隔开，字段的顺序必须正确
    * 对于命名卷而言，第一个字段是卷名，必须是在给定主机上是唯一的；对于匿名卷而言，第一个字段为空
    * 第二个字段是文件或目录在容器中挂载的路径
    * 第三个字段是可选的，是以逗号分隔的选项列表
* `--mount`：由多个键值对组成，用逗号分隔，每个键值对`<key>=<value>`由一个元组组成。顺序可以不唯一
    * `type`：指定了挂载类型，当前使用卷，所以是`type=volume`，还可以是`bind`和`tmpfs`
    * `source`：还可以指定为`src`。对于命名卷，这是卷的名称；对于匿名卷，将忽略此字段
    * `desination`：还可以指定为`dst`或`target`。指定容器中挂载的文件或目录路径
    * `readonly`：是否以[只读方式挂载](https://docs.docker.com/storage/volumes/#use-a-read-only-volume)到容器
    * `volume-opt`：可以多次指定，由选项名及其值组成键值对

### 绑定挂载操作

* `-v --volumes`：由3个字段组成，用冒号（`:`）隔开，字段的顺序必须正确
    * 对于绑定挂载而言，第一个字段指定主机上的文件或目录的路径
    * 第二个字段是文件或目录在容器中挂载的路径
    * 第三个字段是可选的，是以逗号分隔的选项列表，比如`ro/consistent/delegated/cached/z/Z`
* `--mount`：由多个键值对组成，用逗号分隔。顺序可以不唯一
    * `type`：指定了挂载类型，对于绑定挂载而言是`type=bind`，还可以是`volume`和`tmpfs`
    * `source`：还可以指定为`src`。指定了主机文件或目录的路径
    * `desination`：还可以指定为`dst`或`target`。指定容器中挂载的文件或目录路径
    * `readonly`：是否以[只读方式挂载](https://docs.docker.com/storage/volumes/#use-a-read-only-volume)到容器
    * `bind-propagation`：指定绑定传播方式，可选值为`rprivate/private/rshared/shared/rslave/slave`，参考[bind propagation](https://docs.docker.com/storage/bind-mounts/#configure-bind-propagation)
    * `--mount`标识符不支持用于修改`selinux`标志的`z`或`Z`选项

## 异同

虽然`-v`和`--mount`均可用于存储操作，但两者之间存在些许差异

### 卷操作

* 所有的卷操作选项均适用于`-v`和`--mount`标识符
* 当使用卷作用于服务时，仅有`--mount`支持

### 绑定挂载操作

当作用于主机上不存在的文件或目录时

* `-v`会创建一个端点（`endpoint`）。它总是作为目录创建的
* `--mount`不会自动创建，而是生成一个错误