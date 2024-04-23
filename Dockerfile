ARG ALPINE_VERSION=edge
ARG POWERSHELL_VERSION=7.4.1
ARG GOLANG_DOCKER_IMAGE=golang:latest

# STAGE: GO Environment
FROM $GOLANG_DOCKER_IMAGE as gobuild

# STAGE: Powershell environment
FROM alpine:$ALPINE_VERSION as pwshbuild
ARG ALPINE_VERSION
ARG POWERSHELL_VERSION
RUN echo http://dl-cdn.alpinelinux.org/alpine/${ALPINE_VERSION}/testing/ >> /etc/apk/repositories
RUN apk update
RUN apk add --no-cache \
    curl \
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

RUN apk add --no-cache \
    lttng-ust
RUN curl -L https://github.com/PowerShell/PowerShell/releases/download/v$POWERSHELL_VERSION/powershell-$POWERSHELL_VERSION-linux-musl-x64.tar.gz -o /tmp/powershell.tar.gz
RUN mkdir -p /opt/microsoft/powershell/7
RUN tar zxf /tmp/powershell.tar.gz -C /opt/microsoft/powershell/7

# STAGE: dotnet
FROM alpine:$ALPINE_VERSION as dotnetbuild
RUN apk update
RUN apk add --no-cache curl bash
RUN curl -L https://dot.net/v1/dotnet-install.sh -o /tmp/dotnet-install.sh
RUN chmod +x /tmp/dotnet-install.sh
RUN /tmp/dotnet-install.sh --channel 8.0
RUN /tmp/dotnet-install.sh --channel 7.0
RUN /tmp/dotnet-install.sh --channel 6.0

# STAGE: main
FROM alpine:$ALPINE_VERSION as main
ARG ALPINE_VERSION
RUN echo http://dl-cdn.alpinelinux.org/alpine/${ALPINE_VERSION}/testing/ >> /etc/apk/repositories
# main packages
RUN apk update
RUN apk add --no-cache \
    curl curl-doc \
    wget wget-doc \
    bash bash-doc \
    man-db man-db-doc \
    util-linux \
    openssh openssh-doc \
    bat bat-doc \
    ncdu \
    ncdu-doc

# network tools
RUN apk add --no-cache \
    net-tools net-tools-doc traceroute-doc \
    traceroute \
    mtr mtr-doc

# development tools
RUN apk add --no-cache \
    git git-doc \
    build-base \
    python3 \
    trivy

# funny commands
RUN apk add --no-cache \
    cowsay cowsay-doc \
    fortune fortune-doc \
    lolcat \
    figlet figlet-doc

# additional docs
RUN apk add --no-cache \
    busybox-doc \
    binutils-doc \
    apk-tools-doc \
    c-ares-doc \
    ca-certificates-doc \
    file-doc \
    gcc-doc \
    gdbm-doc \
    gmp-doc \
    groff-doc \
    less-doc \
    libbsd-doc \
    libedit-doc \
    libidn-doc \
    libmd-doc \
    libpipeline-doc \
    libpsl-doc \
    libseccomp-doc \
    libunistring-doc \
    make-doc \
    mpc-doc \
    patch-doc \
    pcre-doc \
    perl-doc \
    perl-error-doc \
    readline-doc \
    tzdata-doc \
    userspace-rcu-doc \
    zlib-doc

# powershell
COPY --from=pwshbuild /opt/microsoft/powershell /opt/microsoft/powershell
RUN chmod +x /opt/microsoft/powershell/7/pwsh
RUN ln -s /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh

# install go
COPY --from=gobuild /usr/local/go/ /usr/local/go/
RUN /usr/local/go/bin/go install -v github.com/ardnew/wslpath@latest

# frontend tools
RUN apk add --no-cache nodejs npm
RUN curl -fsSL https://get.pnpm.io/install.sh | ENV="$HOME/.bashrc" SHELL="$(which bash)" bash -

# install dotnet
COPY --from=dotnetbuild /root/.dotnet/ /root/.dotnet/
RUN ln -s /root/.dotnet/dotnet /usr/local/bin/dotnet

# docker
COPY --from=docker:dind /usr/local/bin/docker /usr/local/bin/
COPY --from=docker:dind /usr/local/libexec/docker/ /usr/local/libexec/docker/

# setup powershell
RUN pwsh -command Install-Module -Force DirColors
RUN mkdir /root/.local/share/powershell/PSReadLine/ \
    && touch /root/.local/share/powershell/PSReadLine/ConsoleHost_history.txt

ENTRYPOINT pwsh