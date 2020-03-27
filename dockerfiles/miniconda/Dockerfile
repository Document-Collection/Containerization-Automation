FROM zjzstu/ubuntu:18.04
LABEL maintainer "zhujian <zjzstu@github.com>"

ENV PATH /opt/conda/bin:$PATH

RUN set -eux && \
    apt-get update --fix-missing && \
    apt-get install -y wget bzip2 ca-certificates curl git gosu && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 指定用户名
ENV USER zj
RUN set -eux && \
    useradd -s /bin/bash -m ${USER}

USER ${USER}

RUN set -eux && \
    echo ~ && \
    wget https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda3-py38_4.8.2-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p ~/conda && \
    rm ~/miniconda.sh && \
    ~/conda/bin/conda clean -tipsy && \
    echo ". /home/${USER}/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc

USER root

ENV TINI_VERSION v0.16.1
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini
RUN chmod +x /usr/bin/tini

ENTRYPOINT [ "/usr/bin/tini", "--" ]
CMD [ "/bin/bash" ]