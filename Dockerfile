from alpine:latest

MAINTAINER Ryan Butler (https://github.com/ryanleonbutler)

WORKDIR /home/rlb

RUN apk update && \
    apk add doas && \
    apk add --no-cache shadow && \
    rm -f /tmp/* /etc/apk/cache/*;

RUN apk add --no-cache git && \
    apk add --no-cache unzip && \
    apk add --no-cache curl && \
    apk add --no-cache wget && \
    apk add --no-cache build-base && \
    apk add --no-cache cmake && \
    apk add --no-cache clang && \
    apk add --no-cache llvm && \
    apk add --no-cache gcc && \
    apk add --no-cache fish && \
    apk add --no-cache zoxide && \
    apk add --no-cache fzf && \
    apk add --no-cache exa && \
    apk add --no-cache starship && \
    apk add --no-cache neovim && \
    apk add --no-cache --update python3 py3-pip && \
    apk add --no-cache --update nodejs npm && \
    apk add --no-cache --update sqlite-libs sqlite-dev && \
    apk add --no-cache --update lua lua-dev; 

RUN cd /tmp && \
    git clone https://github.com/keplerproject/luarocks.git && \
    cd luarocks && \
    sh ./configure && \
    make build install && \
    cd && \
    rm -rf /tmp/* /root/.cache/luarocks /etc/apk/cache/*;

RUN apk add --no-cache --update go && \
    go env -w GOPROXY=direct

# RUN curl –proto '=https' –tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

COPY ./dotfiles ./.config
COPY ./dotfiles/.gitconfig .
COPY ./dotfiles/.gittemplate .

RUN mkdir -p ./.config/fish/completions && \
     mkdir -p ./.config/fish/conf.d && \
     mkdir -p ./.config/fish/functions;

ENV USER=rlb
ENV GROUP=developers

RUN addgroup -S $GROUP && \
    adduser \
    --disabled-password \
    "$USER" \
    wheel && \
    echo "permit $USER as root" > /etc/doas.d/doas.conf; \
    echo "permit nopass :wheel as root" >> /etc/doas.d/doas.config;

RUN chown -R rlb:developers /home/rlb

USER rlb
ENV SHELL /usr/bin/fish
RUN chsh -s /usr/bin/fish

ENTRYPOINT ["fish"]
