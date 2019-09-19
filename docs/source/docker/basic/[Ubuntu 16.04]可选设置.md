
# [Ubuntu 16.04]可选设置

参考：[Post-installation steps for Linux](https://docs.docker.com/install/linux/linux-postinstall/)

安装后可以配置以下步骤以进一步简化`docker`使用

## 以非root用户身份管理Docker

`Docker`守护进程绑定到`Unix`套接字而不是`TCP`端口。默认情况下`Unix`套接字归`root`所有，其他用户只能使用`sudo`访问它。`Docker`守护进程始终作为根用户运行

可以创建一个`unix`组，名为`docker`，然后添加`home`用户到里面。当`docker`守护进程启动后会创建`Unix socket`访问`docker`组的成员

1. 创建`docker`组

    ```
    $ sudo groupadd docker
    ```

2. 添加用户到`docker`组

    ```
    $ sudo usermod -aG docker $USER
    ```

3. 注销并重新登录，以便重新评估组成员资格
    * 如果在虚拟机上测试，则需要重启虚拟机
    * 在桌面`Linux`环境（如`X Windows`）中，完全注销会话，然后重新登录
    * 在`Linux`上，还可以运行以下命令来激活对组的更改：

        ```
        $ newgrp docker 
        ````

4. 使用`docker`命令验证：

    ```
    # 此命令下载测试镜像并在容器中运行它。当容器运行时，它会打印一条消息并退出
    $ docker run hello-world
    ```

如果在将用户添加到`Docker`组之前，最初使用`sudo`运行`Docker cli`命令可能会看到以下错误，这表明由于`sudo`命令的原因，`~/.docker/`目录是用不正确的权限创建的

```
WARNING: Error loading config file: /home/user/.docker/config.json - stat /home/user/.docker/config.json: permission denied
```

要解决此问题，请删除`~/.docker/`目录（该目录将自动重新创建，但任何自定义设置都将丢失），或者使用以下命令更改其所有权和权限：

```
$ sudo chown "$USER":"$USER" /home/"$USER"/.docker -R
$ sudo chmod g+rwx "$HOME/.docker" -R
```

## 开机自启动

使用`systemctl`命令实现`docker`守护进程开机自启动

```
# 允许开机自启动
$ sudo systemctl enable docker
# 停止开机自启动
$ sudo systemctl disable docker
```

