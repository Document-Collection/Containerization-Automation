# $ docker build -t zjzstu/ssh .
# $ docker run -d -P --name test_sshd zjzstu/ssh:latest
FROM zjzstu/ubuntu:18.04
LABEL maintainer "zhujian <zjzstu@github.com>"

RUN apt-get update && apt-get install -y openssh-server
RUN mkdir /var/run/sshd && \ 
    echo 'root:zhujian' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
    # SSH login fix. Otherwise user is kicked off after login

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]