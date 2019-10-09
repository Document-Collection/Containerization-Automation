
FROM zjzstu/ubuntu:18.04
LABEL maintainer "zhujian <zjzstu@github.com>"

WORKDIR /app

RUN set -eux && \
	apt-get update && \
	apt-get install -y libnotify4 libnss3 libxkbfile1 libsecret-1-0 libgtk-3-0 libxss1 libx11-xcb1 libasound2 ttf-wqy-microhei python3-pip curl wget gosu && \
	# verify that the binary works
	gosu nobody true && \
	# 下载安装包
	wget https://vscode.cdn.azure.cn/stable/b37e54c98e1a74ba89e03073e5a3761284e3ffb0/code_1.38.1-1568209190_amd64.deb && \
	# 新建用户user，并修改安装包属主/属组
	useradd -s /bin/bash -m user && \
	chown -R user:user /app && \
	chmod a+x *.deb && \
	dpkg -i code_1.38.1-1568209190_amd64.deb && \
	apt-get install -f -y && \
	# 删除
	rm code*.deb && \ 
	apt-get autoclean -y && apt-get clean -y && \
	find /var/lib/apt/lists -type f -delete && \
	find /var/cache -type f -delete && \
	find /var/log -type f -delete && \
	find /usr/share/doc -type f -delete && \
	find /usr/share/man -type f -delete

COPY docker-entrypoint.sh ./
RUN chmod a+x docker-entrypoint.sh && \
	chown user:user docker-entrypoint.sh
ENTRYPOINT ["/app/docker-entrypoint.sh"]
