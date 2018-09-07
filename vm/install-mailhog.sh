#!/usr/bin/env bash

# Install MailHog
sudo curl -O https://storage.googleapis.com/golang/go1.9.3.linux-amd64.tar.gz \
  && tar -xvf go1.9.3.linux-amd64.tar.gz \
  && rm -rf go1.9.3.linux-amd64.tar.gz \
  && chown -R root:root ./go \
  && mv go /usr/local \
  && ln -fs /usr/local/go/bin/go /usr/bin \
  && ln -fs /usr/bin/go /etc/alternatives \
  && mkdir -p /root/gocode \
  && export GOPATH=/root/gocode \
  && go get github.com/mailhog/MailHog \
  && mv /root/gocode/bin/MailHog /usr/local/bin/mailhog \
  && rm -rf /root/gocode

cat << EOF | sudo tee /etc/systemd/system/mailhog.service > /dev/null
[Unit]
Description=MailHog service

[Service]
ExecStart=/usr/local/bin/mailhog \
  -api-bind-addr 127.0.0.1:8025 \
  -ui-bind-addr 127.0.0.1:8025 \
  -smtp-bind-addr 127.0.0.1:1025

[Install]
WantedBy=multi-user.target
EOF

sudo service mailhog start
