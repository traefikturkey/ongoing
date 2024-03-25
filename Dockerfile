# syntax=docker/dockerfile:1.4
ARG PYTHON_VERSION=3.12

FROM python:${PYTHON_VERSION}-slim-bookworm as base
LABEL maintainer="Mike Glenn <mglenn@ilude.com>"

ARG PUID=${PUID:-1000}
ARG PGID=${PGID:-1000}

ARG USER=anvil
ARG TZ=America/New_York
ENV USER=${USER}
ENV TZ=${TZ}

ARG PROJECT_NAME
ENV PROJECT_NAME=${PROJECT_NAME}

ARG PROJECT_PATH=/app
ENV PROJECT_PATH=${PROJECT_PATH}

ENV PYTHON_DEPS_PATH=/dependencies
ENV PYTHONPATH="${PYTHONPATH}:${PYTHON_DEPS_PATH}"
ENV PYTHONUNBUFFERED=TRUE

ENV LANGUAGE=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN=true

ENV HOME=/home/${USER}
ARG TERM_SHELL=zsh
ENV TERM_SHELL=${TERM_SHELL} 

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    bash-completion \
    ca-certificates \
    curl \
    less \
    locales \
    make \
    tzdata \
    zsh && \
    # install google chrome for webdriver
    curl -o google-chrome-stable_current_amd64.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    apt install -fy ./google-chrome-stable_current_amd64.deb && \
    rm -rf google-chrome-stable_current_amd64.deb && \ 
    # cleanup
    apt-get autoremove -fy && \
    apt-get clean && \
    apt-get autoclean -y && \
    rm -rf /var/lib/apt/lists/* 

RUN sed -i 's/UID_MAX .*/UID_MAX    100000/' /etc/login.defs && \
    groupadd --gid ${PGID} ${USER} && \
    useradd --uid ${PUID} --gid ${PGID} -s /bin/${TERM_SHELL} -m ${USER} && \
    echo "alias l='ls -lhA --color=auto --group-directories-first'" >> /etc/zshenv && \
    echo "alias es='env | sort'" >> /etc/zshenv && \
    echo "PS1='\h:\$(pwd) \$ '" >> /etc/zshenv && \
    mkdir -p ${PROJECT_PATH} && \
    chown -R ${USER}:${USER} ${PROJECT_PATH} && \
    # https://www.jeffgeerling.com/blog/2023/how-solve-error-externally-managed-environment-when-installing-pip3
    rm -rf /usr/lib/python${PYTHON_VERSION}/EXTERNALLY-MANAGED 

COPY --chmod=755 <<-"EOF" /usr/local/bin/docker-entrypoint.sh
#!/bin/bash
set -e
if [ -v DOCKER_ENTRYPOINT_DEBUG ] && [ "$DOCKER_ENTRYPOINT_DEBUG" == 1 ]; then
  set -x
  set -o xtrace
fi

# Check if the directory exists
if [ -d "${PROJECT_PATH}/.devcontainer/entrypoint.d" ]; then
  # Loop through all *.sh files in the directory and execute them
  for script in "${PROJECT_PATH}/.devcontainer/entrypoint.d"/*.sh; do
    chmod +x "$script"
    echo "Executing entrypoint script: $script"
    "$script"
  done
fi

echo "Running: $@"
exec $@
EOF

WORKDIR $PROJECT_PATH
ENTRYPOINT [ "docker-entrypoint.sh" ]


##############################
# Begin build 
##############################
FROM base as build

RUN apt-get update && apt-get install -y --no-install-recommends \
    binutils \
    build-essential \
    cmake \
    coreutils \
    extra-cmake-modules \
    findutils \
    git \
    openssl \
    openssh-client \
    wget && \
    apt-get autoremove -fy && \
    apt-get clean && \
    apt-get autoclean -y && \
    rm -rf /var/lib/apt/lists/* 

COPY requirements.txt requirements.txt
RUN pip3 install --upgrade pip && \
    pip3 install --upgrade setuptools && \
    pip3 install --upgrade wheel && \
    mkdir -p ${PYTHON_DEPS_PATH} && \
    chown -R ${USER}:${USER} ${PROJECT_PATH} ${PYTHON_DEPS_PATH} && \
    pip3 install --no-cache-dir --target=${PYTHON_DEPS_PATH} -r requirements.txt && \
    rm -rf requirements.txt

##############################
# Begin production 
##############################
FROM base as production

COPY --from=build --chown=${USER}:${USER}	${PYTHON_DEPS_PATH} ${PYTHON_DEPS_PATH}
COPY --chown=${USER}:${USER} app ${PROJECT_PATH}
USER ${USER}

CMD [ "python3", "app.py" ]


##############################
# Begin devcontainer 
##############################
FROM build as devcontainer

RUN apt-get update && apt-get install -y --no-install-recommends \
    ansible \
    dnsutils \
    exa \
    iproute2 \
    jq \
    openssh-client \
    ripgrep \
    rsync \
    sshpass \
    sudo \
    tar \
    tree \
    util-linux \
    yq \
    zsh-autosuggestions \
    zsh-syntax-highlighting && \
    apt-get autoremove -fy && \
    apt-get clean && \
    apt-get autoclean -y && \
    rm -rf /var/lib/apt/lists/* 

RUN echo ${USER} ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/${USER} && \
    chmod 0440 /etc/sudoers.d/${USER} 

ENV DOTFILES_URL=https://github.com/ilude/dotfiles.git

USER ${USER}
  
# https://code.visualstudio.com/remote/advancedcontainers/start-processes#_adding-startup-commands-to-the-docker-image-instead
CMD [ "sleep", "infinity" ]
