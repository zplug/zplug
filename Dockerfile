FROM ubuntu:xenial

RUN apt update && apt-get install -y software-properties-common && \
    add-apt-repository -y ppa:jonathonf/vim && \
    apt-get update && apt-get install -y locales build-essential openssh-server git vim zsh tmux curl unzip sudo && \
    rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US.UTF-8

RUN groupadd -g 1000 zplug && \
    useradd -g zplug -G sudo -m -s /bin/zsh zplug && \
    echo 'zplug:zplug' | chpasswd

# .ssh dir needs to be copied from your home
ADD .ssh /home/zplug/.ssh

ADD . /home/zplug/.zplug

RUN chown -R zplug:zplug /home/zplug
RUN chmod 600 /home/zplug/.ssh/id_rsa

USER zplug
WORKDIR /home/zplug

CMD ["/bin/zsh"]
