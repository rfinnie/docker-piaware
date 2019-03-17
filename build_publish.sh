#!/bin/sh

set -e
set -x

export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y --no-install-recommends adduser lighttpd perl-modules

(dpkg -i /tmp/dump1090-fa_*.deb /tmp/piaware_*.deb || apt-get -y --no-install-recommends -f install)
apt-get clean

lighty-enable-mod piaware

adduser --system --home /run/dump1090-fa --uid 900 --group --quiet dump1090-fa

rm -f /tmp/*.deb
