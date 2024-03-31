# using debian as main distro
FROM mcr.microsoft.com/powershell:latest

# main packages
RUN apt-get update
RUN yes | unminimize
RUN apt-get install -y \
        curl \
        wget \
        man \
        build-essential \
        net-tools \
        traceroute \
        iputils-ping \
        mtr \
        btop \
        ctop \
        git \
        bat

RUN apt-get install -y \
        cowsay \
        fortune \
        lolcat \
        boxes \
        figlet

# install go
RUN \
    apt-get install -y \
        golang-go
RUN /bin/go install -v github.com/ardnew/wslpath@latest
RUN /bin/go install -v github.com/jesseduffield/lazydocker@latest

# frontend tools
RUN apt-get install -y \
        nodejs
RUN curl -fsSL https://get.pnpm.io/install.sh | ENV="$HOME/.bashrc" SHELL="$(which bash)" bash -

# install dotnet
RUN \
    curl https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -o packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb \
    && rm packages-microsoft-prod.deb \
    && apt-get install -y \
        dotnet-sdk-8.0 \
        dotnet-sdk-6.0

# docker
COPY --from=docker:dind /usr/local/bin/docker /usr/local/bin/
COPY --from=docker:dind /usr/local/libexec/docker/ /usr/local/libexec/docker/

# setup powershell
RUN pwsh -command Install-Module -Force DirColors
RUN mkdir /root/.local/share/powershell/PSReadLine/ \
    && touch /root/.local/share/powershell/PSReadLine/ConsoleHost_history.txt