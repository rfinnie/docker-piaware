FROM ubuntu:bionic as build
WORKDIR /build

COPY build_packages.sh /build/

RUN /build/build_packages.sh


FROM ubuntu:bionic as publish

COPY --from=build /build/fr24feed/fr24feed /tmp/
COPY --from=build /build/dump1090-fa_*.deb /tmp/
COPY --from=build /build/piaware_builder/piaware_*.deb /tmp/
COPY lighttpd_config_50-piaware.conf /etc/lighttpd/conf-available/50-piaware.conf
COPY feed-adsbexchange /usr/local/bin/feed-adsbexchange
COPY init /init

RUN export DEBIAN_FRONTEND=noninteractive && \
    cp /tmp/fr24feed /usr/local/bin/fr24feed && \
    apt-get update -y && \
    apt-get install -y --no-install-recommends net-tools iproute2 adduser lighttpd socat perl-modules iputils-ping ca-certificates && \
    (dpkg -i /tmp/dump1090-fa_*.deb /tmp/piaware_*.deb || apt-get -y --no-install-recommends -f install) && \
    apt-get clean && \
    lighty-enable-mod piaware && \
    adduser --system --home /run/fr24 --no-create-home --quiet fr24 && \
    adduser --system --home /run/adsbexchange --no-create-home --quiet adsbexchange && \
    rm -f /tmp/*.deb /tmp/fr24feed

EXPOSE 8080
EXPOSE 8754

CMD ["/init"]
