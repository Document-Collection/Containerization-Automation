#!/bin/bash

USER_ID=${LOCAL_USER_ID:-9001}
chown -R $USER_ID /app

# 修改usr用户ID
usermod -u $USER_ID user
usermod -a -G root user
export HOME=/home/user

# 切换到user用户再执行wps
exec gosu user $@