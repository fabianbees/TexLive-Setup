FROM ubuntu:20.04

ARG USER_NAME=latex
ARG USER_HOME=/home/latex
ARG USER_ID=1000
ARG USER_GECOS=LaTeX
ARG MINIMAL_INSTALLATION=true

RUN adduser \
  --home "$USER_HOME" \
  --uid $USER_ID \
  --gecos "$USER_GECOS" \
  --disabled-password \
  "$USER_NAME"

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

RUN apt update && apt install -y \
    sudo \
    wget \
    git \
    make \
    htop \
    nano \
    perl \
    ca-certificates \
    pandoc \
    pandoc-citeproc \
    python3-pygments \
    fig2dev \
    # Removing documentation packages *after* installing them is kind of hacky,
    # but it only adds some overhead while building the image.
    && apt --purge remove -y .\*-doc$ && \
    # Remove more unnecessary stuff
    apt clean -y && \
    apt autoremove && \
    rm -rf /var/lib/apt/lists/* && \
    echo "ALL ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers


COPY TexLive_Setup.sh /tmp/

RUN chmod +x /tmp/TexLive_Setup.sh; \
    #start installation
    case "$MINIMAL_INSTALLATION" in \
        true) echo "MINIMAL INSTALLATION" && su - latex -c "sudo /tmp/TexLive_Setup.sh --min" ;; \
        false) echo "FULL INSTALLATION" && su - latex -c "sudo /tmp/TexLive_Setup.sh --full" ;; \
        *) echo "NO INSTALLATION CANDIDATE" ;; \
    esac; \
    rm /tmp/TexLive_Setup.sh


ENV HOME /data

WORKDIR /data

VOLUME ["/data"]