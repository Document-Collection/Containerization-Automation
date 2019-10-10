
FROM zjzstu/ubuntu:latest
LABEL maintainer "zhujian <zjzstu@github.com>"

WORKDIR /app
COPY wps_symbol_fonts.zip ./

RUN set -eux && \
	# 安装wps依赖，安装额外工具xdg-utils/unzip/wget/gosu
	apt-get update && \
	apt-get install -y libfreetype6 libcups2 libglib2.0-0 libglu1-mesa libsm6 libxrender1 libfontconfig1 libxext6 libxcb1 libgtk2.0-0 libcanberra-gtk-module xdg-utils unzip wget gosu && \
	# verify that the binary works
	gosu nobody true && \
	# 下载安装包
	wget http://kdl.cc.ksosoft.com/wps-community/download/8865/wps-office_11.1.0.8865_amd64.deb && \
	wget http://kdl.cc.ksosoft.com/wps-community/download/fonts/wps-office-fonts_1.0_all.deb && \
	# 新建用户user，并修改安装包属主/属组
	useradd -s /bin/bash -m user && \
	chown user:user wps*.deb && \
	# 安装wps及中文字体
	unzip wps_symbol_fonts.zip -d /usr/share/fonts/ && \
	chmod 755 /usr/share/fonts/*.ttf && \
	chmod 755 /usr/share/fonts/*.TTF && \
	dpkg -i wps-office_11.1.0.8865_amd64.deb && \
	dpkg -i wps-office-fonts_1.0_all.deb && \
	# 删除
	rm *.deb wps_symbol_fonts.zip && \
	apt-get remove -y --purge wget unzip && \
	apt-get autoclean -y && apt-get clean -y && \
	find /var/lib/apt/lists -type f -delete && \
	find /var/cache -type f -delete && \
	find /var/log -type f -delete && \
	find /usr/share/doc -type f -delete && \
	find /usr/share/man -type f -delete

COPY docker-entrypoint.sh ./
# 赋予docker-entrypoint.sh可执行权限
RUN chmod a+x docker-entrypoint.sh

ENTRYPOINT ["/app/docker-entrypoint.sh"]