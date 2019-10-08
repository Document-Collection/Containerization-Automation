
参考：

[sshcode](https://github.com/cdr/sshcode)

[code-server](https://github.com/cdr/code-server)

[WSL下使用VcXsrv启动chromium browser及常见错误解析 (ubuntu18.04， 图形界面)](https://www.cnblogs.com/freestylesoccor/articles/9630758.html)

[解决 canberra-gtk-module 加载失败的问题](https://blog.csdn.net/Longyu_wlz/article/details/85254588)

[VSCode: There is no Pip installer available in the selected environment](https://stackoverflow.com/questions/50993566/vscode-there-is-no-pip-installer-available-in-the-selected-environment)

启动`docker`:

```
$ docker run -d \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -e DISPLAY=unix${DISPLAY} \
    -e LOCAL_USER_ID=`id -u ${USER}` \
    -e XMODIFIERS="@im=fcitx" \
    -e QT_IM_MODULE="fcitx" \
    -e GTK_IM_MODULE="fcitx" \
    -v ${HOME}/docs:/home/user/docs \
    --name code \
    code:v1
```

## 问题

`vscode`无法输入中文，以及中文显示乱码问题？

通过`docker exec`进入容器，可以在命令行输入和显示中文
