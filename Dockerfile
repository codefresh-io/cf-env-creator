# ----- Sops ------
#
FROM golang:1.10-alpine AS sops
# install sops
RUN apk add --no-cache git && go get -u go.mozilla.org/sops/cmd/sops && which sops

#------ helm ----
FROM dtzar/helm-kubectl:2.8.1 as helm

#------- Deployer ------
#
FROM google/cloud-sdk:alpine

RUN apk add --no-cache py-pip && pip install --upgrade awscli

COPY --from=sops /go/bin/sops /usr/bin/
COPY --from=helm /bin/helm /usr/bin/
COPY --from=helm /usr/local/bin/kubectl /usr/bin/

# ON BUILD
ONBUILD ADD . /opt/codefresh/
ONBUILD RUN chmod +x /opt/codefresh/bin/*