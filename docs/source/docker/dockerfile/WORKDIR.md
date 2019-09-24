
# WORKDIR

参考：[WORKDIR](https://docs.docker.com/engine/reference/builder/#workdir)

`WORKDIR`指令为`RUN，CMD，ENTRYPOINT，COPY`和`ADD`指令设置了工作路径

## 语法

```
WORKDIR /path/to/workdir
```

* `Dockerfile`文件中可以设置多条`WORKDIR`指令，其作用于后续的指令
* 可以设置`WORKDIR`为相对路径，其相对于上一条`WORKDIR`指令的路径
* 可以使用`ENV`设定的环境变量

## 示例


```
WORKDIR /a
WORKDIR b
WORKDIR c
RUN pwd
```

最后的`pwd`命令输出为`/a/b/c`

```
ENV DIRPATH /path
WORKDIR $DIRPATH/$DIRNAME
RUN pwd
```

最后的`pwd`命令输出为`/path/$DIRNAME`