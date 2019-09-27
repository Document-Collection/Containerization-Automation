
# [译]在Docker中管理数据

原文地址：[Manage data in Docker](https://docs.docker.com/storage/)

默认情况下，在容器中创建的所有文件都存储在可写容器层（`writable container layer`）上。这意味着：

* 当容器不再存在时，数据不会持久，如果另一个进程需要，也很难从容器中获取数据
* 容器的可写层与运行容器的主机紧密耦合，不能轻易地把数据移到别的地方
* 写入容器的可写层需要一个存储驱动程序（[storage driver](https://docs.docker.com/storage/storagedriver/)）来管理文件系统。存储驱动程序使用`Linux`内核提供联合文件系统。与使用直接写入主机文件系统的数据卷（`data volumes`）相比，这种额外的抽象降低了性能

`Docker`有两个选项让容器将文件存储在主机中，这样即使容器停止，文件也会被持久化：卷（`volumes`）和绑定挂载（`bind mounts`）。如果你在`Linux`上运行`Docker`，你也可以使用`tmpfs`挂载。如果在`Windows`上运行`Docker`，也可以使用命名管道（`a named pipe`）

继续阅读有关这两种数据持久化方法的更多信息

## 选择正确的挂载类型

无论选择使用哪种类型的挂载，容器中的数据看起来都是相同的。它在容器的文件系统中以目录或单个文件的形式公开

可视化卷、绑定挂载和`tmpfs`挂载之间差异的一个简单方法是考虑数据在`Docker`主机上的位置

![](./imgs/types-of-mounts.png)

* 卷（`Volume`）存储在由`Docker`管理的主机文件系统的一部分中（`Linux`上的`/var/lib/docker/volumes/`）
* 绑定挂载（`Bind mounts`）可以存储在主机系统上的任何位置。它们甚至可能是重要的系统文件或目录。`Docker`主机或`Docker`容器上的非`Docker`进程可以随时修改它们
* `tmpfs`挂载只存储在主机系统的内存中，从不写入主机系统的文件系统

## 有关挂载类型的详细信息

* [Volumes](https://docs.docker.com/storage/volumes/): 由`Docker`创建和管理。可以使用`docker volume create`命令显式地创建卷，或者`docker`可以在容器或服务创建期间创建卷

    创建卷时，它存储在`Docker`主机上的目录中。将卷挂载到容器中时，此目录就是挂载到容器中的内容。这与绑定挂载的工作方式类似，只是卷由`Docker`管理，并与主机的核心功能隔离
    给定的卷可以同时装入多个容器中。当没有正在运行的容器正在使用卷时，`Docker`仍然可以使用该卷，并且不会自动删除该卷。可以使用`docker volume prune`删除未使用的卷
    当挂载卷时，它可能是命名的（`named`）或匿名的（`anonymous`）。匿名卷在第一次装入容器时没有给它们一个显式的名称，因此`Docker`给它们一个随机的名称，该名称保证在给定的`Docker`主机中是唯一的。除了名称，命名卷和匿名卷的行为方式相同
    卷还支持卷驱动程序（`volume drivers`）的使用，它允许将数据存储在远程主机或云提供商上，以及其他可能
* [绑定挂载](https://docs.docker.com/storage/bind-mounts/): 从`Docker`的早期就有。与卷相比，绑定挂载的功能有限。使用绑定挂载时，主机上的文件或目录将挂载到容器中。文件或目录由其在主机上的完整路径引用。文件或目录不需要已经存在于`Docker`主机上。如果它还不存在，它是按需创建的。绑定挂载的性能非常好，但它们依赖于具有特定目录结构的主机文件系统。如果正在开发新的`Docker`应用程序，请考虑改用命名卷（`named volumes`），因为不能使用`docker cli`命令直接管理绑定挂载
    * *绑定挂载允许访问敏感文件*：无论好坏，使用绑定挂载的一个副作用是可以通过在容器中运行的进程来更改主机文件系统，包括创建、修改或删除重要的系统文件或目录。这是一个强大的能力，可以有安全影响，包括影响主机系统上的非`Docker`进程
* [tmpfs mounts](https://docs.docker.com/storage/tmpfs/): `tmpfs`挂载不会在磁盘上持久化，无论是在`Docker`主机上还是在容器中。容器可以在其生存期内使用它来存储非持久状态（`non-persistent state`）或敏感信息（`sensitive information`）。例如，在内部，`swarm`服务使用`tmpfs`挂载将[secrets](https://docs.docker.com/engine/swarm/secrets/)挂载到服务的容器中
* [named pipes](https://docs.microsoft.com/en-us/windows/desktop/ipc/named-pipes): `npipe`挂载可用于`docker`主机和容器之间的通信。常见的用例是在容器内部运行第三方工具，并使用命名管道（`named pipe`）连接到`Docker`引擎`API`

## 卷的使用示例

卷是将数据持久化在`Docker`容器和服务中的首选方式。卷的一些用例包括：

* 在多个正在运行的容器之间共享数据。如果未显式创建卷，则在第一次将卷装入容器时创建该卷。当该容器停止或被移除时，该卷仍然存在。多个容器可以同时挂载同一个卷，可以是读写的，也可以是只读的。只有在显式删除卷时才会删除它们
* 当`Docker`主机不能保证具有给定的目录或文件结构时。卷帮助将`Docker`主机的配置与容器运行时分离
* 当希望将容器的数据存储在远程主机或云提供商上而不是本地时
* 当需要从一个`Docker`主机备份、还原或迁移数据到另一个`Docker`主机时，卷是更好的选择。可以停止容器使用卷，然后备份卷的目录（例如`/var/lib/docker/volumes/<volume name>`）

## 绑定挂载的使用示例

一般来说，应该尽可能使用卷。绑定挂载适用于以下类型的用例：

* 将配置文件从主机共享到容器。这就是`Docker`在默认情况下通过将`/etc/resolv.conf`从主机挂载到每个容器中来为容器提供`DNS`解析的方式
* 在`Docker`主机上的开发环境和容器之间共享源代码或构建组件。例如可以将`Maven target/`目录挂载到容器中，并且每次在`docker`主机上构建`maven`项目后，容器都可以访问重建的组件
     如果使用`docker`进行开发，那么生产`Dockerfile`将直接将生产就绪的组件复制到镜像中，而不是依赖绑定挂载
* 当`Docker`主机的文件或目录结构保证与容器所需的绑定挂载一致时

## tmpfs挂载的使用示例

`tmpfs`挂载最适合于不希望数据在主机或容器中持久化的情况。这可能是出于安全原因，或者是为了在应用程序需要写入大量非持久状态数据时保护容器的性能

## 使用绑定挂载或卷的提示

如果使用绑定挂载或卷，请记住以下几点：

* 如果将空卷（`empty volume`）装入存在文件或目录的容器中的目录，则这些文件或目录将传播（复制）到卷中。类似地，如果启动容器并指定一个不存在的卷，则会创建一个空卷。这是预填充（`pre-populate`）另一个容器所需数据的好方法
* 如果将绑定挂载或非空卷（`bind mount or non-empty volume`）挂载到容器中存在某些文件或目录的目录中，这些文件或目录将被挂载遮挡（`obscured`），就像将文件保存到`Linux`主机上的`/mnt`中，然后将`USB`驱动器挂载到`/mnt`中一样。在卸载`USB`驱动器之前，`/mnt`的内容将被`USB`驱动器的内容遮挡。隐藏的文件不会被删除或更改，但在绑定挂载或卷被使用时无法访问

## 下一步

* 更多[volumes](https://docs.docker.com/storage/volumes/)的内容
* 更多[bind mounts](https://docs.docker.com/storage/bind-mounts/)的内容
* 更多[tmpfs mounts](https://docs.docker.com/storage/tmpfs/)的内容
* 更多[storage drivers](https://docs.docker.com/storage/storagedriver/)的内容。它们与绑定挂载或卷无关，但允许将数据存储在容器的可写层中 