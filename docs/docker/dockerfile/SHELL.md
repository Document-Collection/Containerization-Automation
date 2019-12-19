
# SHELL

参考：[SHELL](https://docs.docker.com/engine/reference/builder/#shell)

`SHELL`指令在在`Docker1.12`中添加的，重写用于命令的`shell`形式的默认`shell`

对于`Linux`而言是`["/bin/sh", "-c"]`，对于`Windows`而言是`["cmd", "/S", "/C"]`

```
SHELL ["executable", "parameters"]
```

`SHELL`可以在`Dockerfiles`中出现多次，每次`SHELL`指令重写之前的设置，作用于后续的指令

其影响下面`3`个指令的`shell`形式

1. `RUN`
2. `CMD`
3. `ENTRYPOINT`