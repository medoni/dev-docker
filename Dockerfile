ARG ALPINE_VERSION=edge
ARG POWERSHELL_VERSION=7.4.1
ARG GOLANG_DOCKER_IMAGE=golang:latest

FROM $GOLANG_DOCKER_IMAGE as gobuild

FROM alpine:$ALPINE_VERSION
ARG ALPINE_VERSION
ARG POWERSHELL_VERSION

# main packages
RUN echo http://dl-cdn.alpinelinux.org/alpine/${ALPINE_VERSION}/testing/ >> /etc/apk/repositories
RUN apk update
RUN apk add --no-cache \
    bash \
    curl \
    wget \
    man-db \
    build-base \
    net-tools \
    traceroute \
    mtr \
    git \
    bat

RUN apk add --no-cache \
    cowsay \
    fortune \
    lolcat \
    figlet

# powershell
RUN apk add --no-cache \
    ca-certificates \
    less \
    ncurses-terminfo-base \
    krb5-libs \
    libgcc \
    libintl \
    libssl1.1 \
    libstdc++ \
    tzdata \
    userspace-rcu \
    zlib \
    icu-libs

# man pages
RUN apk list -I | sed -rn '/-doc/! s/([a-z-]+[a-z]).*/\1/p' | xargs -tI§ apk add §-doc

RUN apk add --no-cache \
    lttng-ust
RUN curl -L https://github.com/PowerShell/PowerShell/releases/download/v$POWERSHELL_VERSION/powershell-$POWERSHELL_VERSION-linux-musl-x64.tar.gz -o /tmp/powershell.tar.gz
RUN mkdir -p /opt/microsoft/powershell/7
RUN tar zxf /tmp/powershell.tar.gz -C /opt/microsoft/powershell/7
RUN chmod +x /opt/microsoft/powershell/7/pwsh
RUN ln -s /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh

# install go
COPY --from=gobuild /usr/local/go/ /usr/local/go/
RUN /usr/local/go/bin/go install -v github.com/ardnew/wslpath@latest

# frontend tools
RUN apk add --no-cache nodejs npm
RUN curl -fsSL https://get.pnpm.io/install.sh | ENV="$HOME/.bashrc" SHELL="$(which bash)" bash -

# install dotnet
RUN curl -L https://dot.net/v1/dotnet-install.sh -o /tmp/dotnet-install.sh
RUN chmod +x /tmp/dotnet-install.sh
RUN /tmp/dotnet-install.sh --channel 8.0
RUN /tmp/dotnet-install.sh --channel 7.0
RUN /tmp/dotnet-install.sh --channel 6.0
RUN ln -s /root/.dotnet/dotnet /usr/local/bin/dotnet

# docker
COPY --from=docker:dind /usr/local/bin/docker /usr/local/bin/
COPY --from=docker:dind /usr/local/libexec/docker/ /usr/local/libexec/docker/

# setup powershell
RUN pwsh -command Install-Module -Force DirColors
RUN mkdir /root/.local/share/powershell/PSReadLine/ \
    && touch /root/.local/share/powershell/PSReadLine/ConsoleHost_history.txt

ENTRYPOINT pwsh