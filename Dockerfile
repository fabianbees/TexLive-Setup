FROM alpine

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

RUN apk update && apk add \
    # some auxiliary tools
    wget \
    git \
    make \
    xz \
    # markup format conversion tool
    #"$PANDOC" \
    #"$PCITEPROC" \
    # XFig utilities
    #"$FIG2DEV" \
    # important utils
    htop \
    nano \
    # syntax highlighting package
    #"$PYGMENTS"mkdir /tmp/texlive-install
    perl \
    ca-certificates

COPY ./files/texlive2021.profile /
# This file is needed for the glossary to work
COPY ./files/.latexmkrc /
COPY ./files/update_texlive.sh /

RUN wget http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz && \
    tar xvzf install-tl-unx.tar.gz && \
    cd ./install-tl-2* && \
    #start installation
    ./install-tl --profile=/texlive2021.profile && \
    cd ~ && \
    rm -rf /install-tl-2* && \
    rm /texlive2021.profile && \
    chmod +x /update_texlive.sh  && \
    mv /update_texlive.sh ~ && \
    mv /.latexmkrc ~


RUN ~/update_texlive.sh


ENV HOME /data

WORKDIR /data


VOLUME ["/data"]
