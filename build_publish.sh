#!/bin/sh

set -e
set -x

export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y --no-install-recommends net-tools iproute2 adduser lighttpd socat perl-modules iputils-ping ca-certificates

(dpkg -i /tmp/dump1090-fa_*.deb /tmp/piaware_*.deb || apt-get -y --no-install-recommends -f install)
apt-get clean

lighty-enable-mod piaware

adduser --system --home /run/dump1090-fa --uid 900 --group --quiet dump1090-fa
adduser --system --home /run/fr24feed --uid 901 --group --quiet fr24feed
adduser --system --home /run/adsbexchange --uid 902 --group --quiet adsbexchange

rm -f /tmp/*.deb
