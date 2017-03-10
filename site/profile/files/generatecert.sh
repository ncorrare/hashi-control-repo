#!/bin/bash
set -e
cd /usr/share/easy-rsa/2.0/
source ./vars
/usr/share/easy-rsa/2.0/clean-all
/usr/share/easy-rsa/2.0/build-ca --batch
/usr/share/easy-rsa/2.0/build-dh --batch
/usr/share/easy-rsa/2.0/build-key-server --batch $(hostname)
mkdir -p /etc/ssl/vault
cp /usr/share/easy-rsa/2.0/keys/ca.crt /etc/ssl/vault
cp /usr/share/easy-rsa/2.0/keys/$(hostname).* /etc/ssl/vault
chown -R vault:vault /etc/ssl/vault
cp /etc/ssl/vault/ca.crt /etc/pki/ca-trust/source/anchors/
cp /etc/ssl/vault/ca.crt /vagrant/
/bin/update-ca-trust
