#!/bin/sh

set -e
set -x

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get -y --no-install-recommends install git ca-certificates build-essential devscripts fakeroot debhelper wget curl jq tar
apt-get -y --no-install-recommends install tcl8.6-dev python3-dev python3-venv libz-dev
apt-get -y --no-install-recommends install librtlsdr-dev libusb-1.0-0-dev pkg-config dh-systemd libncurses5-dev libbladerf-dev

mkdir -p /build/fr24feed
cd /build/fr24feed
DEB_ARCH=$(dpkg --print-architecture)
case $DEB_ARCH in
  i386)
    FR24_URL="$(curl -s https://repo-feed.flightradar24.com/fr24feed_versions.json | jq -r '.platform.linux_x86_tgz.url.software')"
    ;;
  amd64)
    FR24_URL="$(curl -s https://repo-feed.flightradar24.com/fr24feed_versions.json | jq -r '.platform.linux_x86_64_tgz.url.software')"
    ;;
  arm64)
    FR24_URL="$(curl -s https://repo-feed.flightradar24.com/fr24feed_versions.json | jq -r '.platform.linux_arm_tgz.url.software')"
    ;;
  armhf)
    FR24_URL="$(curl -s https://repo-feed.flightradar24.com/fr24feed_versions.json | jq -r '.platform.linux_arm_tgz.url.software')"
    ;;
  *)
    echo "Unknown architecture: $DEB_ARCH"
    exit 1
esac
if [ -n "$FR24_URL" ]; then
  wget "$FR24_URL"
  tar zxvf fr24feed_*.tgz
  cp fr24feed_*/fr24feed .
else
  cat <<"EOM" >fr24feed
#!/bin/sh

echo "fr24feed: Unsupported architecture, exiting"
exit 0
EOM
fi
chmod 0755 fr24feed

cd /build
git clone --depth=1 https://github.com/flightaware/piaware_builder

cd /build/piaware_builder
./sensible-build.sh bionic
cd /build/piaware_builder/package-bionic
debuild -b -us -uc
cd /build/piaware_builder/package-bionic/dump1090
debuild -b -us -uc
