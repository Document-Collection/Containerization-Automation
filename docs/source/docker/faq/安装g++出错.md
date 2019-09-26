
# 安装g++出错

参考：

[Ubuntu18.04LTS安装g++错误以及解决方法](http://blog.sina.com.cn/s/blog_64bb0c990102yv3a.html)

[安装g++出现的问题解决了一部分，还有一些。求大神指教](https://forum.ubuntu.org.cn/viewtopic.php?t=465488)

使用`Docker`镜像`Ubuntu:18.04`，安装`g++`时出现错误

```
The following packages have unmet dependencies:
 g++ : Depends: g++-5 (>= 5.3.1-3~) but it is not going to be installed
E: Unable to correct problems, you have held broken packages.
```

网上查询时发现可能是系统镜像源设置出错，我使用了`Ubuntu 16.04`的阿里镜像。在[Mirrors](https://opsx.alibaba.com/mirror)中找到`Ubuntu 18.04`的镜像源配置

```
deb http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse

deb http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse

deb http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse

deb http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse

deb http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse
```

重新配置后，成功安装`g++`