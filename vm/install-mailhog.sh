#!/usr/bin/env bash

# Install MailHog
curl -O https://storage.googleapis.com/golang/go1.9.3.linux-amd64.tar.gz \
  && tar -xf go1.9.3.linux-amd64.tar.gz \
  && rm -rf go1.9.3.linux-amd64.tar.gz \
  && sudo mv ./go /usr/local \
  && sudo chown -R root:root /usr/local/go \
  && sudo ln -fs /usr/local/go/bin/go /usr/bin \
  && sudo ln -fs /usr/bin/go /etc/alternatives \
  && mkdir ~/gocode \
  && export GOPATH=~/gocode \
  && go get github.com/mailhog/MailHog \
  && go get github.com/mailhog/mhsendmail \
  && sudo mv ~/gocode/bin/MailHog /usr/local/bin/mailhog \
  && sudo mv ~/gocode/bin/mhsendmail /usr/local/bin/mhsendmail \
  && rm -rf ~/gocode

cat << EOF | sudo tee /etc/systemd/system/mailhog.service > /dev/null
[Unit]
Description=MailHog service

[Service]
ExecStart=/usr/local/bin/mailhog -api-bind-addr 127.0.0.1:8025 -ui-bind-addr 127.0.0.1:8025 -smtp-bind-addr 127.0.0.1:1025

[Install]
WantedBy=multi-user.target
EOF

sudo service mailhog start
