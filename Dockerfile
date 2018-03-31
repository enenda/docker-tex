FROM debian:9

LABEL maintainer "Alen Kocaj <alen.kocaj@posteo.at>"

RUN useradd --create-home --shell /bin/bash tex

RUN apt-get update \
    && apt-get install -y curl \
    && apt-get install -y unzip \
    && apt-get install -y texlive-full \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /home/tex/.fonts \
    && curl -L www.exljbris.com/dl/fontin_pc.zip --output /tmp/fontin.zip \
    && unzip /tmp/fontin.zip -d /usr/local/share/fonts \
    && fc-cache -f -v

USER tex
WORKDIR "/home/tex"