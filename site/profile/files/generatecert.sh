#!/bin/bash
set -e
cd /usr/share/easy-rsa/2.0/
source ./vars
/usr/share/easy-rsa/2.0/clean-all
/usr/share/easy-rsa/2.0/build-ca --batch
/usr/share/easy-rsa/2.0/build-dh --batch
/usr/share/easy-rsa/2.0/build-key-server --batch $(hostname)
cp /usr/share/easy-rsa/2.0/keys/ca.crt /etc/vault
cp /usr/share/easy-rsa/2.0/keys/$(hostname).* /etc/vault
chown -R vault:vault /etc/vault
cp /etc/vault/ca.crt /etc/pki/ca-trust/source/anchors/
/bin/update-ca-trust
