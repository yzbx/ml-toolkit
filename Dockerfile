# FROM nvidia/driver:418.87.01-ubuntu18.04
# FROM nvidia/driver:460.73.01-ubuntu20.04
# FROM nvidia/driver:460.32.03-ubuntu20.04
# FROM nvidia/driver:450.80.02-ubuntu20.04

# 460.32.03 --> CUDA11.2
FROM nvidia/driver:460.32.03-ubuntu20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/3bf863cc.pub && \
  apt-get update && \
  apt-get install -yq build-essential cmake libncurses5-dev libncursesw5-dev && \
  rm -rf /var/lib/{apt,dpkg,cache,log}

# install nvtop
COPY . /nvtop
WORKDIR /nvtop
RUN mkdir -p /nvtop/build && \
  cd /nvtop/build && \
  cmake .. && \
  make && \
  make install && \
  rm -rf /nvtop/build

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
  apt-get install -y git build-essential wget curl zip \
  libglib2.0-0 libgl1-mesa-glx autojump fd-find fzf yank \
  jq mycli man tmux vim unar \
  rdfind fdupes tree time htop bash-completion neovim && \
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
  /opt/conda/bin/pip install jupyter notebook numpy opencv_python Pillow scipy tqdm pandas seaborn imagesize nptyping easydict matplotlib

# config vim 
COPY vimrc.txt /root/.vimrc
RUN mkdir -p /root/.vim/bundle
RUN git clone --filter=blob:none https://github.com/Shougo/neobundle.vim ~/.vim/bundle/neobundle.vim
RUN mkdir -p ~/.vim/pack/python-mode/start
RUN git clone --recurse-submodules https://github.com/python-mode/python-mode.git
RUN cd /root/.vim/bundle/neobundle.vim && bin/neoinstall

WORKDIR /workspace

ENTRYPOINT []
CMD /usr/local/bin/nvtop
