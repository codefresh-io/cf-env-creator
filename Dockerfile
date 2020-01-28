# ----- Sops ------
#
FROM golang:1.11-alpine AS sops
# install sops
RUN apk add --no-cache git curl && curl "https://github.com/mozilla/sops/releases/download/v3.5.0/sops-v3.5.0.linux" -L --output /go/bin/sops && chmod +x /go/bin/sops
RUN go get github.com/lukesampson/figlet

#------ helm ----
FROM dtzar/helm-kubectl:3.0.1 as helm

#------- Deployer ------
#
FROM google/cloud-sdk:alpine

RUN apk add --no-cache py-pip && apk add git curl jq py-pip bash certbot && pip install yq && pip install --upgrade awscli && apk add --no-cache python3 && pip3 install certbot_dns_route53
COPY --from=sops /go/bin/sops /usr/bin/
COPY --from=sops /go/bin/figlet /usr/bin/
COPY --from=helm /usr/local/bin/helm /usr/bin/
COPY --from=helm /usr/local/bin/kubectl /usr/bin/

# Add font to be used in figlet
RUN git clone https://github.com/lukesampson/figlet
RUN mv figlet/figletlib/fonts . && rm -rf figlet
ENV GOPATH=/

# ON BUILD
ONBUILD ADD . /opt/codefresh/
ONBUILD RUN chmod +x /opt/codefresh/bin/*