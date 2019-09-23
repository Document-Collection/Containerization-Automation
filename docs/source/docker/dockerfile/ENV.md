
# ENV

参考：[ENV](https://docs.docker.com/engine/reference/builder/#env)

`ENV`指令为镜像设置环境变量，将出现在构建阶段所有后续指令的环境中

## 语法

有`2`种实现方式

```
ENV <key> <value>
ENV <key>=<value> ...
```

第一种形式只能设置单个变量值，第一个空格后的整个字符串将被视为包含空白字符的变量值，如果使用引号字符需要转义

第二种形式可以设置多个键值对，对于空格，可以使用引号或者转义字符设置；可设多行，使用反斜杠结尾

```
ENV myName John Doe
ENV myDog Rex The Dog
ENV myCat fluffy
# 两者等价
ENV myName="John Doe" \
    myDog=Rex\ The\ Dog \
    myCat=fluffy
```

## 命令行设置

可以在启动容器时使用标识符`-e, --env list`设置环境变量

```
$ docker run --env AUTH=zj --env AUTH2=zj2 -it --rm zjzstu/ubuntu:18.04 bash
root@7d1a026785bf:/# echo $AUTH
zj
root@7d1a026785bf:/# echo $AUTH2
zj2
```

## 查询

除了在容器内查询外，还可以使用`docker inspect`查询环境变量

```
"Config": {
            ...
            ...
            "Env": [
                "AUTH=zj",
                "AUTH2=zj2",
                "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
            ],
            ...
            ...
        },
```