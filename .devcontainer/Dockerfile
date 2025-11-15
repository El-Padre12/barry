FROM debian:12-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    openssh-client \
    git \
    vim \
    nano \
    curl \
    sudo \
    && rm -rf /var/lib/apt/lists/*

ARG USERNAME=sre
ARG USER_UID=1000
ARG USER_GID=1000


RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Pre-create Ansible directory with correct permissions
RUN mkdir -p /home/$USERNAME/.ansible \
    && chown -R $USERNAME:$USERNAME /home/$USERNAME/.ansible

RUN pip install --no-cache-dir --break-system-packages ansible

USER $USERNAME
WORKDIR /workspace

CMD ["/bin/bash"]
