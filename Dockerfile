FROM ubuntu:24.04

RUN apt update && \
    apt install -y openssh-server && \
    mkdir -p /run/sshd

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
