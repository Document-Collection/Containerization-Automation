
# service启动docker失效

```
$ service docker start
Job for docker.service failed because the control process exited with error code. See "systemctl status docker.service" and "journalctl -xe" for details.

$ systemctl status docker.service
● docker.service - Docker Application Container Engine
   Loaded: loaded (/lib/systemd/system/docker.service; enabled; vendor preset: enabled)
   Active: failed (Result: start-limit-hit) since 四 2019-09-19 16:16:09 CST; 6s ago
     Docs: https://docs.docker.com
  Process: 7950 ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock (code=exited, status=1/FAILURE)
 Main PID: 7950 (code=exited, status=1/FAILURE)

9月 19 16:16:07 zj-ThinkPad-T470p systemd[1]: Failed to start Docker Application Container Engine.
9月 19 16:16:07 zj-ThinkPad-T470p systemd[1]: docker.service: Unit entered failed state.
9月 19 16:16:07 zj-ThinkPad-T470p systemd[1]: docker.service: Failed with result 'exit-code'.
9月 19 16:16:09 zj-ThinkPad-T470p systemd[1]: docker.service: Service hold-off time over, scheduling restart.
9月 19 16:16:09 zj-ThinkPad-T470p systemd[1]: Stopped Docker Application Container Engine.
9月 19 16:16:09 zj-ThinkPad-T470p systemd[1]: docker.service: Start request repeated too quickly.
9月 19 16:16:09 zj-ThinkPad-T470p systemd[1]: Failed to start Docker Application Container Engine.
9月 19 16:16:09 zj-ThinkPad-T470p systemd[1]: docker.service: Unit entered failed state.
9月 19 16:16:09 zj-ThinkPad-T470p systemd[1]: docker.service: Failed with result 'start-limit-hit'.
```

我的问题是`/etc/docker/daemon.json`配置出错

```
$ cat /etc/docker/daemon.json 
{
    "mtu": 1450,
    "registry-mirrors": ["https://xxx.mirror.aliyuncs.com"]，
    "dns": ["192.168.0.1", "8.8.8.8"]
}
```

去掉`dns`键值对后重新启动成功

```
$ sudo service docker start
$ ps aux | grep docker
root      8263  2.0  0.5 805596 82912 ?        Ssl  16:19   0:00 /usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
zj        8468  0.0  0.0  15964  1016 pts/2    R+   16:19   0:00 grep --color=auto docker
```