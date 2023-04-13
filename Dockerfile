FROM amd64/ubuntu:jammy
ENV docker_url=https://download.docker.com/linux/static/stable/x86_64
ENV docker_version=23.0.3
ENV HELM_VERSION=v3.11.3
ENV MONGO_VERSION=4.4
ENV KUBECTL_VERSION=1.24.11/2023-03-17
ENV DEBIAN_FRONTEND="noninteractive"

LABEL maintainer="Moulick Aggarwal" email="moulickaggarwal@gmail.com"

# Clean up APT when done.
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    gnupg \
    ca-certificates \
    # software-properties-common \
    postgresql-client \
    netcat \
    telnet \
    dnsutils \
    iputils-ping \
    nano \
    redis-tools \
    iputils-ping \
    screen \
    npm \
    rsync \
    python3 \
    python3-pip \
    zip \
    unzip \
    jq \
    groff \
    less \
    curl \
    gettext \
    openssl \
    git \
    wget \
    parallel \
    default-jre \
    ssh \
    iptables \
    kafkacat \
    && \
    # Need to install libssl1.1 from ubuntu repo as it is not available in focal and needed for mongo shell
    curl -fsSL http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2.17_amd64.deb -o /tmp/libssl1.1.deb && \
    dpkg -i /tmp/libssl1.1.deb && \
    rm /tmp/libssl1.1.deb && \
    curl -fsSL https://pgp.mongodb.com/server-${MONGO_VERSION}.asc | gpg -o /usr/share/keyrings/mongodb-server-${MONGO_VERSION}.gpg --dearmor && \
    echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-${MONGO_VERSION}.gpg ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/${MONGO_VERSION} multiverse" | tee /etc/apt/sources.list.d/mongodb-org-${MONGO_VERSION}.list && \
    apt-get update -y && \
    apt-get install -y --no-install-recommends \
    mongodb-org-shell \
    mongodb-org-tools \
    && \
    apt-get clean && rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/* \
    && curl -fsSL $docker_url/docker-$docker_version.tgz | tar zxvf - --strip 1 -C /usr/bin docker/docker

RUN pip3 install --no-cache-dir --upgrade s3cmd==2.2.0 python-magic

RUN curl -o awscliv2.zip "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" && \
    unzip awscliv2.zip && \
    ls -lah && \
    ./aws/install && \
    rm -R awscliv2.zip ./aws && \
    cd /usr/local/bin && \
    curl -o kubectl "https://s3.us-west-2.amazonaws.com/amazon-eks/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" && \
    curl -o helm.tar.gz "https://get.helm.sh/helm-$HELM_VERSION-linux-amd64.tar.gz" && \
    curl -L -o amazonmq-cli.zip "https://github.com/antonwierenga/amazonmq-cli/releases/download/v0.2.2/amazonmq-cli-0.2.2.zip" && \
    unzip amazonmq-cli.zip -d $HOME/amazonmq-cli && \
    tar -xzvf helm.tar.gz -C /tmp && \
    rm helm.tar.gz && \
    mv /tmp/linux-amd64/helm . && \
    curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash && \
    rm -R /tmp/linux-amd64 && \
    rm -R amazonmq-cli.zip && \
    chmod +x kubectl && \
    chmod +x helm && \
    chmod +x kustomize
