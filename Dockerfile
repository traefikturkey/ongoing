# syntax=docker/dockerfile:1.4
FROM python:3.12-slim-bookworm
LABEL maintainer="Mike Glenn <mglenn@ilude.com>"

ARG PUID=${PUID:-1000}
ARG PGID=${PGID:-1000}

ARG USER=anvil
ARG TZ=America/New_York
ENV USER=${USER}
ENV TZ=${TZ}

ARG PROJECT_NAME
ENV PROJECT_NAME=${PROJECT_NAME}

ARG PROJECT_PATH
ENV PROJECT_PATH=${PROJECT_PATH}

ARG TERM_SHELL=zsh
ENV TERM_SHELL=${TERM_SHELL}

ENV LANGUAGE=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN=true

RUN apt-get update && apt-get install -y --no-install-recommends \
  bash \
  bash-completion \
  ansible \
  binutils \
  build-essential \
  ca-certificates \
  cmake \
  coreutils \
  curl \
  exa \
  extra-cmake-modules \
  findutils \
  git \
  iproute2 \
  jq \
  less \
  locales \
  make \
  openssl \
  openssh-client \
  ripgrep \
  rsync \
  sshpass \
  sudo \
  tar \
  tree \
  tzdata \
  util-linux \
  yq \
  zsh \
  zsh-autosuggestions \
  zsh-syntax-highlighting && \
  apt-get autoremove -fy && \
  apt-get clean && \
  apt-get autoclean -y && \
  rm -rf /var/lib/apt/lists/* && \
  # https://www.jeffgeerling.com/blog/2023/how-solve-error-externally-managed-environment-when-installing-pip3
  sudo rm -rf /usr/lib/python3.11/EXTERNALLY-MANAGED  

RUN sed -i 's/UID_MAX .*/UID_MAX    100000/' /etc/login.defs && \
    groupadd --gid ${PGID} ${USER} && \
    useradd --uid ${PUID} --gid ${PGID} -s /bin/${TERM_SHELL} -m ${USER} && \
    echo ${USER} ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/${USER} && \
    chmod 0440 /etc/sudoers.d/${USER} && \
    mkdir -p ${PROJECT_PATH} 

ENV HOME=/home/${USER}

COPY requirements.txt /tmp/requirements.txt
RUN pip3 install --upgrade pip && \
    pip3 install --upgrade setuptools && \
    pip3 install --upgrade wheel && \
    pip3 install --no-cache-dir -r /tmp/requirements.txt && \
    rm -rf /tmp/requirements.txt
    
COPY --chmod=755 <<-"EOF" /usr/local/bin/docker-entrypoint.sh
#!/bin/bash
set -e
if [ -v DOCKER_ENTRYPOINT_DEBUG ] && [ "$DOCKER_ENTRYPOINT_DEBUG" == 1 ]; then
  set -x
  set -o xtrace
fi

sudo chown ${USER}:${USER} /var/run/docker.sock

echo "Running: $@"
exec $@
EOF

USER ${USER}
  
# https://code.visualstudio.com/remote/advancedcontainers/start-processes#_adding-startup-commands-to-the-docker-image-instead
ENTRYPOINT [ "docker-entrypoint.sh" ]
CMD [ "sleep", "infinity" ]
