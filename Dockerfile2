FROM ubuntu:20.04
#FROM alpine

ARG USER_NAME=latex
ARG USER_HOME=/home/latex
ARG USER_ID=1000
ARG USER_GECOS=LaTeX

RUN adduser \
  --home "$USER_HOME" \
  --uid $USER_ID \
  --gecos "$USER_GECOS" \
  --disabled-password \
  "$USER_NAME"

ARG WGET=wget
ARG GIT=git
ARG MAKE=make
ARG SUDO=sudo
ARG PANDOC=pandoc
ARG PCITEPROC=pandoc-citeproc
ARG PYGMENTS=python3-pygments
ARG FIG2DEV=fig2dev

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

RUN apt update -q && apt install -qy \
    # some auxiliary tools
    "$WGET" \
    "$GIT" \
    "$MAKE" \
    "$SUDO" \
    # markup format conversion tool
    "$PANDOC" \
    "$PCITEPROC" \
    # XFig utilities
    "$FIG2DEV" \
    # important utils
    htop nano \
    # syntax highlighting package
    "$PYGMENTS" && \
    # Removing documentation packages *after* installing them is kind of hacky,
    # but it only adds some overhead while building the image.
    apt --purge remove -y .\*-doc$ && \
    # Remove more unnecessary stuff
    apt clean -y && \
    apt autoremove && \
    rm -rf /var/lib/apt/lists/* && \
    echo "ALL ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Install TexLive with scheme-basic



COPY TexLive_2020_Setup.sh /tmp/

RUN chmod +x /tmp/TexLive_2020_Setup.sh; \
    /tmp/TexLive_2020_Setup.sh; \
    rm /tmp/TexLive_2020_Setup.sh

#ENV PATH="/usr/local/texlive/2020/bin/x86_64-linux:${PATH}"

RUN ~/update_texlive.sh


ENV HOME /data

WORKDIR /data


VOLUME ["/data"]
