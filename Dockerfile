FROM alpine:3.13

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

RUN apk update && apk add \
    bash \
    wget \
    git \
    make \
    xz \
    htop \
    nano \
    perl \
    ca-certificates
    # markup format conversion tool
    #"$PANDOC" \
    #"$PCITEPROC" \
    # XFig utilities
    #"$FIG2DEV" \
    # important utils

    # syntax highlighting package
    #"$PYGMENTS"mkdir /tmp/texlive-install


COPY ./files/texlive2021.profile /home/latex/
COPY ./files/texliveMIN.profile /home/latex/
# This file is needed for the glossary to work
COPY ./files/.latexmkrc /home/latex/
COPY ./files/update_texlive.sh /home/latex/

RUN cd /home/latex/ && \
    apkArch="$(apk --print-arch)"; \
    case "$apkArch" in \
        aarch64) echo "binary_aarch64-linux 1" | tee -a ./texlive2021.profile ./texliveMIN.profile ;; \
        x86) echo "binary_x86_64-linux 1" | tee -a ./texlive2021.profile ./texliveMIN.profile ;; \
        armhf) echo "binary_armhf-linux 1" | tee -a ./texlive2021.profile ./texliveMIN.profile ;; \
    esac; \
    wget http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz && \
    tar xvzf install-tl-unx.tar.gz && \
    cd ./install-tl-2* && \
    #start installation
    if [[ -z "$MINIMAL_INSTALLATION" ]]; \
        then echo "FULL INSTALLATION" && ./install-tl --profile ../texlive2021.profile; \
        else echo "MINIMAL INSTALLATION" && ./install-tl --profile ../texliveMIN.profile; \
    fi && \
    cd /home/latex/ && \
    rm -rf ./install-tl-2* && \
    rm ./texlive2021.profile && \
    rm ./texliveMIN.profile && \
    chmod +x ./update_texlive.sh  && \
    mv ./update_texlive.sh /bin/ && \
    mv ./.latexmkrc /home/latex/ && \
    chown latex:latex /home/latex/.latexmkrc


RUN /bin/update_texlive.sh


ENV HOME /data

WORKDIR /data

VOLUME ["/data"]