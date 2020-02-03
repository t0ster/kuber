FROM alpine

RUN apk add --no-cache bash curl openssl
# RUN apt-get update && apt-get install -y curl
ENV DOCKERVERSION=19.03.5
RUN curl -fsSLO https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKERVERSION}.tgz \
  && tar xzvf docker-${DOCKERVERSION}.tgz --strip 1 \
                 -C /usr/local/bin docker/docker \
  && rm docker-${DOCKERVERSION}.tgz
RUN curl -L https://git.io/get_helm.sh | bash
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
RUN chmod +x ./kubectl
RUN mv ./kubectl /usr/local/bin/kubectl


FROM alpine
COPY --from=0 /usr/local/bin/docker /usr/local/bin/docker
COPY --from=0 /usr/local/bin/helm /usr/local/bin/helm
COPY --from=0 /usr/local/bin/kubectl /usr/local/bin/kubectl
