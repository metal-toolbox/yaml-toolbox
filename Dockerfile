FROM golang:1.18.4-alpine3.16 AS builder

ENV PACKAGES="\
  kubectl \
  helm \
  curl \
  "

RUN apk add \
  --no-cache \
  --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ \
  --allow-untrusted \
  $PACKAGES

RUN mkdir /user \
  && echo 'nobody:x:65534:65534:nobody:/:' > /user/passwd \
  && echo 'nobody:x:65534:' > /user/group

RUN mkdir /tmp/kube-linter \
  && curl -L -o /tmp/kube-linter/kube-linter.tar.gz \
  https://github.com/stackrox/kube-linter/releases/download/0.2.6/kube-linter-linux.tar.gz \
  && tar -xzf /tmp/kube-linter/kube-linter.tar.gz -C /tmp/kube-linter \
  && chmod +x /tmp/kube-linter/kube-linter

RUN mkdir /tmp/kubeaudit \
  && curl -L -o /tmp/kubeaudit/kubeaudit.tar.gz \
  https://github.com/Shopify/kubeaudit/releases/download/0.16.0/kubeaudit_0.16.0_linux_amd64.tar.gz \
  && tar -xzf /tmp/kubeaudit/kubeaudit.tar.gz -C /tmp/kubeaudit \
  && chmod +x /tmp/kubeaudit/kubeaudit

RUN mkdir /tmp/kubesec \
  && curl -L -o /tmp/kubesec/kubesec.tar.gz \
  https://github.com/controlplaneio/kubesec/releases/download/v2.11.4/kubesec_linux_amd64.tar.gz \
  && tar -xzf /tmp/kubesec/kubesec.tar.gz -C /tmp/kubesec \
  && chmod +x /tmp/kubesec/kubesec

FROM alpine:3.16

WORKDIR /src

COPY --from=builder /user/group /user/passwd /etc/

COPY --chown=nobody --from=builder /usr/bin/kubectl /usr/bin/kubectl
COPY --chown=nobody --from=builder /usr/bin/helm /usr/bin/helm
COPY --chown=nobody --from=builder /tmp/kubesec/kubesec /usr/bin/kubesec
COPY --chown=nobody --from=builder /tmp/kubeaudit/kubeaudit /usr/bin/kubeaudit
COPY --chown=nobody --from=builder /tmp/kube-linter/kube-linter /usr/bin/kube-linter

COPY --chown=nobody --from=k8s.gcr.io/kustomize/kustomize:v5.4.3 /app/kustomize /usr/bin/kustomize
COPY --chown=nobody --from=ghcr.io/yannh/kubeconform:v0.4.14 /kubeconform /usr/bin/kubeconform
COPY --chown=nobody --from=zegl/kube-score:v1.14.0 /kube-score /usr/bin/kube-score

USER nobody:nobody

CMD ["/bin/sh"]