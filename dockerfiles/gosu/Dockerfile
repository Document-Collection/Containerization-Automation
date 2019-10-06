FROM zjzstu/ubuntu:18.04
LABEL maintainer "zhujian <zjzstu@github.com>"

WORKDIR /app
RUN set -eux && \
	apt-get update && \
	apt-get install -y gosu && \
	rm -rf /var/lib/apt/lists/* && \
    # verify that the binary works
	gosu nobody true && \
	useradd -s /bin/bash -m user

COPY docker-entrypoint.sh .
RUN chmod a+x docker-entrypoint.sh

ENTRYPOINT ["/app/docker-entrypoint.sh"]
