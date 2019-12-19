
# LABEL

参考：[LABEL](https://docs.docker.com/engine/reference/builder/#label)

`LABEL`指令为镜像添加元数据

## 语法

```
LABEL <key>=<value> <key>=<value> <key>=<value> ...
```

使用键值对形式，单个`LABEL`指令可以添加一个或多个键值对，一个`Dockerfile`文件中可以包含多个`LABEL`指令

**如果键值对存在空格或者过长，可以使用双引号和反斜杠**

```
LABEL "com.example.vendor"="ACME Incorporated"
LABEL com.example.label-with-value="foo"
LABEL multi.label1="value1" multi.label2="value2" other="value3"
LABEL multi.label1="value1" \
      multi.label2="value2" \
      other="value3"
```

## 继承

新的镜像可以继承来自基镜像或者父镜像的`LABEL`信息，如果设置了同名键值对，则会覆盖之前的信息

## 查询

使用命令`docker inspect`进行查询

```
$ docker inspect IMAGE | grep -i LABEL
```
