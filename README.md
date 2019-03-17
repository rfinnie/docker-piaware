# docker-piaware - PiAware Docker container image

[https://github.com/rfinnie/docker-piaware](https://github.com/rfinnie/docker-piaware)

This image runs [PiAware](https://flightaware.com/adsb/piaware/) + FlightAware's dump1090-fa software.

This image should build on any architecture, and is currently being built for arm64 and amd64.  Raspbian images may be supported once buster is released (for "recent" Docker).

It requires no persistent storage and does not need to be run in a privileged container, but does require some light scripting to determine your RTL2832U to pass through to the container.  Here is a typical invocation:

```
# Blacklist the kernel dvb_usb_rtl28xxu module
echo "blacklist dvb_usb_rtl28xxu" >/etc/modprobe.d/blacklist-rtl28xxu.conf

# Plug in the RTL2832U module

# Determine the USB device entry for the RTL2832U module
USBDEV="$(lsusb | perl -ne '/^Bus (\d+) Device (\d+): .* RTL2832U DVB-T$/ && print "/dev/bus/usb/$1/$2"')"

# Configuration
export FA_USER="Your FlightAware username"
export FA_PASSWORD="Your FlightAware password"
export FA_FEEDER_ID="Your FlightAware feeder ID"

docker run \
  --rm \
  --name piaware \
  --device "$USBDEV" \
  -e FA_USER \
  -e FA_PASSWORD \
  -e FA_FEEDER_ID \
  -p 8080:8080 \
  rfinnie/piaware
```

Your FlightAware feeder ID can be found by logging into FlightAware and going to your feeder stats page.  It'll be a UUID under "Unique Identifier".

If this is a new site, don't set FA_FEEDER_ID.  The first time you run the container, FlightAware will generate and display a new feeder ID in the container output.  Note this UUID and use it for future invocations (otherwise a new feeder ID will be generated every time).  Also be sure to go the FlightAware site configuration page and set latitude/longitude of the site, and other information.

Port 8080 is the local SkyView information page (visual representation of planes in the sky).  Other ports are available, such as 30002 for the raw feed.
