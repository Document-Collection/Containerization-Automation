# [Ubuntu]nvidia-docker安装

参考：[NVIDIA/nvidia-docker](https://github.com/NVIDIA/nvidia-docker)

安装`Nvidia`容器工具包，允许在容器中实现`GPU`加速

![](./imgs/docker-nvidia.png)

## 环境

当前主机系统为`Ubuntu 18.04`，`Docker`版本为`19.03.5`，并且主机已安装了`Nvidia`驱动，参考[[Ubuntu 18.04]PPA方式安装Nvidia驱动](https://zj-linux-guide.readthedocs.io/zh_CN/latest/tool-install-configure/[Ubuntu%2018.04]PPA%E6%96%B9%E5%BC%8F%E5%AE%89%E8%A3%85Nvidia%E9%A9%B1%E5%8A%A8/)

## 安装

在主机系统上安装`Nvidia`容器工具包

```
# Add the package repositories
$ distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
$ curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
$ curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

$ sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit
$ sudo systemctl restart docker
```

## 测试

`Nvidia`提供了几个已配置好`cuda`的镜像，参考[nvidia](https://hub.docker.com/u/nvidia)

安装完成后，测试容器中是否可以使用`cuda`

```
$ docker run --gpus all nvidia/cuda:10.2-base-ubuntu18.04 nvidia-smi
Unable to find image 'nvidia/cuda:10.2-base-ubuntu18.04' locally
10.2-base-ubuntu18.04: Pulling from nvidia/cuda
Digest: sha256:15fc2f88d247eaa8781f6d3d01613250771ac9394e4543257f2bba5610b96974
Status: Downloaded newer image for nvidia/cuda:10.2-base-ubuntu18.04
Tue Dec 24 12:01:41 2019       
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 440.26       Driver Version: 440.26       CUDA Version: 10.2     |
|-------------------------------+----------------------+----------------------+
| GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|===============================+======================+======================|
|   0  GeForce 940MX       Off  | 00000000:02:00.0 Off |                  N/A |
| N/A   42C    P0    N/A /  N/A |    643MiB /  2004MiB |     21%      Default |
+-------------------------------+----------------------+----------------------+
                                                                               
+-----------------------------------------------------------------------------+
| Processes:                                                       GPU Memory |
|  GPU       PID   Type   Process name                             Usage      |
|=============================================================================|
+-----------------------------------------------------------------------------+
```