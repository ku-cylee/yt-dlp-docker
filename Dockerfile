FROM python:3.12-slim

LABEL org.opencontainers.image.authors="ku-cylee" \
      org.opencontainers.image.version="0.2"

ARG USERNAME=yt
ARG USERGROUP=$USERNAME

# Basic system configuration
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Seoul

RUN apt update && \
    apt upgrade -y && \
    apt install --no-install-recommends -y tzdata openssh-server vim sudo locales && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    locale-gen ko_KR.UTF-8 && \
    echo "alias ll='ls -alF'" >> /etc/bash.bashrc && \
    echo "LANG=C.UTF-8" >> /etc/environment && \
    echo "LC_ALL=C.UTF-8" >> /etc/environment

# Deno
ENV DENO_INSTALL=/usr/local

RUN apt install --no-install-recommends -y curl unzip && \
    curl -fsSL https://deno.land/install.sh | sh

# User account
RUN useradd -m -s /bin/bash --create-home $USERNAME && \
    usermod -aG sudo $USERNAME && \
    echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    mkdir /home/$USERNAME/.ssh && \
    chown -R $USERNAME:$USERGROUP /home/$USERNAME/.ssh && \
    chmod 700 /home/$USERNAME/.ssh

COPY --chown=$USERNAME:$USERGROUP ./youtube.pub /home/$USERNAME/.ssh/authorized_keys

# yt-dlp dependencies
RUN apt install --no-install-recommends -y wget ffmpeg && \
    pip3 install --no-cache-dir -U yt-dlp-ejs

# yt-dlp installation
RUN wget https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -O /usr/local/bin/yt-dlp && \
    chmod +x /usr/local/bin/yt-dlp

# yt-dlp configuration

COPY --chown=$USERNAME:$USERGROUP ./yt-dlp.conf /home/$USERNAME/yt-dlp.conf

RUN mkdir /home/$USERNAME/downloads && \
    chown -R $USERNAME:$USERGROUP /home/$USERNAME/downloads

WORKDIR /home/$USERNAME
VOLUME /home/$USERNAME/downloads

# Remove apt cache
RUN apt clean && \
    rm -rf /var/lib/apt/lists/*

# Run SSH Daemon
EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
