# $ docker build -t zjzstu/wps:latest .
# $ docker run -d -v /etc/localtime:/etc/localtime:ro \
# -v /tmp/.X11-unix:/tmp/.X11-unix \
# -e DISPLAY=unix$DISPLAY \
# -v $HOME/slides:/root/slides \
# -e GDK_SCALE \
# -e GDK_DPI_SCALE \
# --name wps \
# wps

FROM zjzstu/ubuntu:18.04
LABEL maintainer "zhujian <zjzstu@github.com>"

WORKDIR /app
COPY wps_symbol_fonts.zip ./

# 安装依赖
# RUN apt-get update && apt-get install -f && \
RUN apt-get update && \
	apt-get install -y libfreetype6 libcups2 libglib2.0-0 libglu1-mesa libsm6 libxrender1 libfontconfig1 libxext6 libxcb1 xdg-utils unzip wget && \
	# 下载安装包
	wget http://kdl.cc.ksosoft.com/wps-community/download/8865/wps-office_11.1.0.8865_amd64.deb && \
	wget http://kdl.cc.ksosoft.com/wps-community/download/fonts/wps-office-fonts_1.0_all.deb && \
	# 安装wps及中文字体
	unzip wps_symbol_fonts.zip -d /usr/share/fonts/ && \
	chmod 755 /usr/share/fonts/*.ttf && \
	chmod 755 /usr/share/fonts/*.TTF && \
	dpkg -i wps-office_11.1.0.8865_amd64.deb && \
	dpkg -i wps-office-fonts_1.0_all.deb && \
	# 删除
	rm *.deb wps_symbol_fonts.zip && \
	apt-get remove -y --purge wget unzip && \
	apt-get autoremove -y --purge && apt-get autoclean -y && apt-get clean -y && \
	find /var/lib/apt/lists -type f -delete && \
	find /var/cache -type f -delete && \
	find /var/log -type f -delete && \
	find /usr/share/doc -type f -delete && \
	find /usr/share/man -type f -delete

ENTRYPOINT ["/usr/bin/wps"]