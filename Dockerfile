# ----- Sops ------
#
FROM golang:1.11-alpine AS sops
# install sops
RUN apk add --no-cache git
RUN go get github.com/lukesampson/figlet



#------- Deployer ------
#
FROM google/cloud-sdk:alpine

RUN apk add --no-cache py-pip && apk add git curl jq py-pip bash certbot && pip install yq && pip install --upgrade awscli && apk add --no-cache python3 && pip3 install certbot_dns_route53
COPY --from=sops /go/bin/figlet /usr/bin/

# Add font to be used in figlet
RUN git clone https://github.com/lukesampson/figlet
RUN mv figlet/figletlib/fonts . && rm -rf figlet
ENV GOPATH=/

#------ sops ----
RUN wget -q https://github.com/mozilla/sops/releases/download/v3.5.0/sops-v3.5.0.linux -O /usr/bin/sops && \
    chmod +x /usr/bin/sops

#------ helm ----
ARG HELM_VERSION
ENV HELM_VERSION ${HELM_VERSION:-3.2.4}
RUN wget -q https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz -O - | tar -xzO linux-amd64/helm > /usr/bin/helm && \
    chmod +x /usr/bin/helm

#------ kubectl
ARG KUBECTL_VERSION
ENV KUBECTL_VERSION ${KUBECTL_VERSION:-1.18.5}
RUN wget -q https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl -O /usr/bin/kubectl && \
    chmod +x /usr/bin/kubectl

# ON BUILD
ONBUILD ADD . /opt/codefresh/
ONBUILD RUN chmod +x /opt/codefresh/bin/*