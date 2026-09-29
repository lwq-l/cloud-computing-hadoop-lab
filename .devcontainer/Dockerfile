FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

ARG HADOOP_VERSION=3.4.1

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    openjdk-11-jdk \
    openssh-client \
    openssh-server \
    rsync \
    curl \
    wget \
    procps \
    net-tools \
    nano \
    && rm -rf /var/lib/apt/lists/*

RUN wget -q https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz -O /tmp/hadoop.tar.gz \
    && tar -xzf /tmp/hadoop.tar.gz -C /opt \
    && mv /opt/hadoop-${HADOOP_VERSION} /opt/hadoop \
    && rm /tmp/hadoop.tar.gz \
    && chown -R vscode:vscode /opt/hadoop

RUN mkdir -p /run/sshd && ssh-keygen -A

ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV HADOOP_HOME=/opt/hadoop
ENV HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop
ENV PATH=/opt/hadoop/bin:/opt/hadoop/sbin:${PATH}

USER vscode
