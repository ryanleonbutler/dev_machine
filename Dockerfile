FROM alpine:latest

WORKDIR /root

RUN apk update;

# Build tools
RUN apk add --no-cache llvm && \
    apk add --no-cache gcc && \
    apk add --no-cache clang && \
    apk add --no-cache cmake && \
    apk add --no-cache make;
RUN apk add --no-cache build-base;
RUN apk add --no-cache bash libffi-dev openssl-dev bzip2-dev zlib-dev xz-dev readline-dev sqlite-dev tk-dev;
RUN apk add --no-cache python3 py3-pip; # Needed by nodejs to build

# Common tools
RUN apk add --no-cache curl && \
    apk add --no-cache wget && \
    apk add --no-cache unzip && \
    apk add --no-cache tar && \
    apk add --no-cache openssh && \
    apk add --no-cache git;

# Shell and shell tools
RUN apk add --no-cache fish && \
    apk add --no-cache zoxide && \
    apk add --no-cache fzf && \
    apk add --no-cache exa && \
    apk add --no-cache pipx && \
    apk add --no-cache starship;

# Update a bunch of tools
RUN apk add --update --no-cache less

# Neovim
RUN apk add --no-cache neovim;

# asdf-vm
RUN git clone https://github.com/asdf-vm/asdf.git ./.asdf --branch v0.14.0
ENV ASDF_DIR=/root/.asdf
RUN . "/root/.asdf/asdf.sh" && \
    asdf plugin-add lua https://github.com/Stratus3D/asdf-lua.git && \
    asdf plugin-add python && \
    asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git && \
    asdf plugin add golang https://github.com/asdf-community/asdf-golang.git;
RUN . "/root/.asdf/asdf.sh" && \
    asdf install lua 5.4.6;
RUN . "/root/.asdf/asdf.sh" && \
    asdf install python 3.11.8;
RUN . "/root/.asdf/asdf.sh" && \
    asdf nodejs update nodebuild;
RUN . "/root/.asdf/asdf.sh" && \
    ASDF_NODEJS_FORCE_COMPILE=1 asdf install nodejs 20.11.1;
RUN . "/root/.asdf/asdf.sh" && \
    asdf install golang 1.22.0;

RUN . "/root/.asdf/asdf.sh" && \
    asdf global lua 5.4.6;
RUN . "/root/.asdf/asdf.sh" && \
    asdf global 3.11.8;
RUN . "/root/.asdf/asdf.sh" && \
    asdf global nodejs 20.11.1;
RUN . "/root/.asdf/asdf.sh" && \
    asdf global golang 1.22.0;

RUN go env -w GOPROXY=direct

# Configs
COPY ./dotfiles ./.config
COPY ./dotfiles/.gitconfig .
COPY ./dotfiles/.gittemplate .
COPY ./shared_ssh_keys .
COPY ./.tool-versions .

# Shell setup
RUN mkdir -p ./.config/fish/completions && \
    mkdir -p ./.config/fish/conf.d && \
    mkdir -p ./.config/fish/functions;

# Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

ENV SHELL /usr/bin/fish

ENTRYPOINT ["fish"]
