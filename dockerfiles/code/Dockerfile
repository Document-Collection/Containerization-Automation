
FROM zjzstu/ubuntu:latest
LABEL maintainer "zhujian <zjzstu@github.com>"

WORKDIR /app
COPY code*.deb ./
RUN set -eux && \
	# 安装依赖和额外工具
	apt-get update && \
	apt-get install -y libnotify4  libnss3  gnupg libxkbfile1  libsecret-1-0  libgtk-3-0 libxss1 libx11-xcb1 libasound2 libcanberra-gtk-module libglib2.0-0 dbus wget gosu && \
	# verify that the binary works
	gosu nobody true && \
	# 下载安装包
	# wget https://vscode.cdn.azure.cn/stable/b37e54c98e1a74ba89e03073e5a3761284e3ffb0/code_1.38.1-1568209190_amd64.deb && \
	# 新建用户user，并修改安装包属主/属组
	useradd -s /bin/bash -m user && \
	chown user:user *.deb && \
	dpkg -i code_1.38.1-1568209190_amd64.deb && \
	# 删除
	rm code*.deb && \
	apt-get autoremove -y --purge && apt-get autoclean -y && apt-get clean -y && \
	find /var/lib/apt/lists -type f -delete && \
	find /var/cache -type f -delete && \
	find /var/log -type f -delete && \
	find /usr/share/doc -type f -delete && \
	find /usr/share/man -type f -delete

COPY docker-entrypoint.sh ./
# 赋予docker-entrypoint.sh可执行权限
RUN chmod a+x docker-entrypoint.sh

ENTRYPOINT ["/app/docker-entrypoint.sh"]
