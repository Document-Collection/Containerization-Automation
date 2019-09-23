
# CMD

参考：[CMD](https://docs.docker.com/engine/reference/builder/#cmd)

一个`Dockerfile`文件仅能执行一条`CMD`指令。如果存在多条`CMD`指令，仅最后一个`CMD`指令起作用

## 语法

`CMD`指令有`3`种书写格式：

1. `CMD ["executable","param1","param2"]`（`exec`形式，推荐）
2. `CMD ["param1","param2"]`（`ENTRYPOINT`指令的默认参数）
3. `CMD command param1 param2`（`shell`形式）

## 作用

`CMD`指令的主要目的是提供容器默认操作。可以通过`CMD`指定一个可执行文件，如果在`Dockerfile`中指定了`ENTRYPOINT`，那么`CMD`指定的可执行文件会被忽略

**注意：如果`CMD`指令用于提供`ENTRYPOINT`指令参数，那么两者必须按`JSON`数组格式编写**

**注意：如果使用`exec`格式，其将会解析成`JSON`数组，所以必须使用双引号而不是单引号**

调用`shell`命令：

* `exec`形式的`CMD`指令不会调用命令行`shell`，所以如果要使用`shell`命令，必须显示调用`shell`，比如`CMD [ "sh", "-c", "echo $HOME" ]`
* `shell`形式的`CMD`指令可以直接调用，比如`CMD echo $HOME`

调用非`shell`命令，必须使用`exec`形式，且使用命令绝对路径，比如`CMD ["/usr/bin/wc","--help"]`

**如果在运行`docker run`时指定了运行命令，将会覆盖`CMD`指令操作**

## RUN vs. CMD

* `RUN`用于在镜像构建时运行，并提交运行结果
* `CMD`在构建时不执行任何操作，但指定镜像的预期命令

## 示例一

## 示例二

## 示例三

