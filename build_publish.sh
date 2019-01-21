#!/bin/sh

set -e

cp /tmp/fr24feed /usr/local/bin/fr24feed

export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y --no-install-recommends net-tools iproute2 adduser lighttpd socat perl-modules iputils-ping ca-certificates

(dpkg -i /tmp/dump1090-fa_*.deb /tmp/piaware_*.deb || apt-get -y --no-install-recommends -f install)
apt-get clean

lighty-enable-mod piaware

adduser --system --home /run/fr24 --no-create-home --quiet fr24
adduser --system --home /run/adsbexchange --no-create-home --quiet adsbexchange

rm -f /tmp/*.deb /tmp/fr24feed

