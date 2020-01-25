FROM jenkins/jnlp-slave

USER root

RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
RUN apt-get update && \
    apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common \
    git \
    sudo \
    libunwind8 \
    gettext

RUN add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable"

RUN apt-get update && \
    apt-get install -y docker-ce

RUN usermod -aG docker jenkins
RUN usermod -aG sudo jenkins

RUN apt-get update && apt-get install -y sudo apt-transport-https
RUN curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
RUN echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list
RUN apt-get update
RUN apt-get install -y kubectl
RUN curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
USER jenkins
ENTRYPOINT ["/entrypoint.sh"]
# ENTRYPOINT sudo /etc/init.d/docker start && jenkins-agent

# FROM jenkins/jnlp-slave
# USER root
# RUN curl -sSL https://get.docker.com/ | sh
# RUN apt-get update && apt-get install -y sudo apt-transport-https
# RUN curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
# RUN echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list
# RUN apt-get update
# RUN apt-get install -y kubectl
# RUN curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
# USER jenkins
