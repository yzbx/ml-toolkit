FROM ubuntu:20.04
# install cheat from https://github.com/cheat/cheat/releases/tag/4.2.3

ENV LANG=C.UTF-8
ENV PATH=/opt/conda/bin:$PATH
ENV TZ=Asia/Shanghai
ENV DEBIAN_FRONTEND=noninteractive
# ARG MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-py39_4.11.0-Linux-x86_64.sh"
ARG MINICONDA_URL="https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda3-py39_4.11.0-Linux-x86_64.sh"

RUN sed -i 's/archive.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list && \
    apt-get update && \
    apt install -y tzdata && \
    ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime && \
    echo ${TZ} > /etc/timezone && \
    dpkg-reconfigure --frontend noninteractive tzdata && \
    apt-get install -y git build-essential wget curl zip libglib2.0-0 libgl1-mesa-glx autojump fd-find fzf yank jq mycli man tmux vim unar \
    rdfind fdupes && \
    echo ". /usr/share/autojump/autojump.sh" >> ~/.bashrc && \
    wget "${MINICONDA_URL}" -O miniconda.sh -q && \
    mkdir -p /opt && \
    sh miniconda.sh -b -p /opt/conda && \
    rm miniconda.sh && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc && \
    find /opt/conda/ -follow -type f -name '*.a' -delete && \
    find /opt/conda/ -follow -type f -name '*.js.map' -delete && \
    /opt/conda/bin/conda clean -afy && \
    /opt/conda/bin/pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple && \
    /opt/conda/bin/pip install jupyter numpy

WORKDIR /workspace
