# $ docker build -t zjzstu/ubuntu:18.04 -t zjzstu/ubuntu:latest .
# $ docker run -it --rm zjzstu/ubuntu bash

FROM ubuntu:18.04

LABEL maintainer "zhujian <zjzstu@github.com>"

COPY sources.list .
RUN mv sources.list /etc/apt/sources.list
RUN apt-get update && apt-get install -f