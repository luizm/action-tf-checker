FROM alpine:latest
LABEL "name"="tf-checker"
LABEL "maintainer"="Luiz Muller <contact@luizm.dev>"

ENV terraform_version 0.12.15
ENV temp_packages curl unzip

RUN apk add --no-cache bash
RUN apk add --no-cache $temp_packages

RUN curl -Ls https://releases.hashicorp.com/terraform/${terraform_version}/terraform_${terraform_version}_linux_amd64.zip -o /tmp/${terraform_version}.zip && \
    cd /tmp && unzip ${terraform_version}.zip && \
    mv terraform /usr/local/bin

RUN apk del $temp_packages
RUN rm -rf /tmp/*
RUN terraform --version

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
