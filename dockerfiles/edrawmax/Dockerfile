FROM zjzstu/ubuntu:18.04
LABEL maintainer "zhujian <zjzstu@github.com>"

WORKDIR /app
RUN set -eux && \
	apt-get update && \
	apt-get install -y wget gosu && \
	gosu nobody true && \
    apt-get install -y libglib2.0-dev libgl1 libnvidia-gl-435 libxcb-render-util0 libdbus-1-3 libxrender1 libfontconfig1 libxi6 && \
    wget https://www.edrawsoft.cn/2download/edrawmax-9-amd64-cn.deb && \
    useradd -s /bin/bash -m user && \
    chown -R user:user /app && \
    dpkg -i *.deb && \
    rm -f *.deb && \
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