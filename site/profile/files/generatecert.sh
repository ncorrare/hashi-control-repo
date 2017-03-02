#!/bin/bash
set -e
cd /usr/share/easy-rsa/2.0/
source ./vars
./clean-all
./build-ca --batch
./build-dh --batch
./build-key-server --batch $(hostname)
mkdir -p /etc/vault
cp keys/ca.crt /etc/vault
cp keys/$(hostname).* /etc/vault
chown -R vault:vault /etc/vault
cp /etc/vault/ca.crt /etc/pki/ca-trust/source/anchors/
/bin/update-ca-trust
