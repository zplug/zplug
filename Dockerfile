FROM ubuntu:noble

RUN apt-get update && \
    apt-get install -y locales build-essential openssh-server git vim zsh tmux curl unzip sudo && \
    rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US.UTF-8

RUN groupadd -g 1000 zplug && \
    useradd -g zplug -G sudo -m -s /bin/zsh zplug && \
    echo 'zplug:zplug' | chpasswd

ADD . /home/zplug/.zplug

RUN chown -R zplug:zplug /home/zplug

USER zplug
WORKDIR /home/zplug

CMD ["/bin/zsh"]
