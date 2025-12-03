FROM debian:12-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    openssh-client \
    git \
    fish \
    vim \
    nano \
    curl \
    sudo \
    wget \
    unzip \
    gpg \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list \
    && apt-get update \
    && apt-get install -y terraform \
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

# Switch to sre user to install Ansible collections
USER $USERNAME

# Install required Ansible collections
RUN ansible-galaxy collection install community.general \
    && ansible-galaxy collection install ansible.posix

WORKDIR /workspace
CMD ["/bin/bash"]
