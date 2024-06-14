# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.209.3/containers/cpp/.devcontainer/base.Dockerfile

# [Choice] Debian / Ubuntu version (use Debian 11/9, Ubuntu 18.04/21.04 on local arm64/Apple Silicon): debian-11, debian-10, debian-9, ubuntu-21.04, ubuntu-20.04, ubuntu-18.04
ARG VARIANT="ubuntu-22.04"
FROM mcr.microsoft.com/vscode/devcontainers/cpp:${VARIANT}


ENV TZ="Asia/Shanghai"
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# change apt source
COPY ./config/sources.list.amd64 /etc/apt/sources.list.amd64
COPY ./config/sources.list.arm64 /etc/apt/sources.list.arm64
RUN if [ "$(uname -m)" = "x86_64" ]; then \
    mv /etc/apt/sources.list /etc/apt/sources.list.bak && \
    cp /etc/apt/sources.list.amd64 /etc/apt/sources.list; \
    elif [ "$(uname -m)" = "aarch64" ]; then \
    mv /etc/apt/sources.list /etc/apt/sources.list.bak && \
    cp /etc/apt/sources.list.arm64 /etc/apt/sources.list; \
    fi
COPY ./config/tmux.conf /root/.tmux.conf

# [Optional] Uncomment this section to install additional packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>
RUN apt-get update && apt-get -y install\
    tree\
    vim\
    tmux\
    python3-pip\
    libjansson-dev\
    libsnappy-dev\
    liblzma-dev\
    libz-dev\
    pkg-config\
    libssl-dev\
    tldr\
    nodejs\
    clangd-15\
    graphviz\
    inetutils-ping