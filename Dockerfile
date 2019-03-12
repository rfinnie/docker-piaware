FROM ubuntu:bionic as build
WORKDIR /build

COPY build_packages.sh /build/

RUN /build/build_packages.sh


FROM ubuntu:bionic as publish

COPY --from=build /build/fr24feed/fr24feed /usr/local/bin/
COPY --from=build /build/piaware_builder/package-bionic/dump1090-fa_*.deb /tmp/
COPY --from=build /build/piaware_builder/piaware_*.deb /tmp/
COPY lighttpd_config_50-piaware.conf /etc/lighttpd/conf-available/50-piaware.conf
COPY feed-adsbexchange /usr/local/bin/feed-adsbexchange
COPY init /init
COPY build_publish.sh /tmp/

RUN /tmp/build_publish.sh && rm -f /tmp/build_publish.sh

EXPOSE 8080
EXPOSE 8754

CMD ["/init"]
