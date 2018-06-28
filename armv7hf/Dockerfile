FROM braindoctor/netdata-minimal:armv7hf
RUN ["cross-build-start"]

ENV \
    N_HTTP_TIMEOUT="1" \
    N_HTTP_STATUS_CODES="200" \
    N_HTTP_REDIRECT="yes" \
    N_HTTP_NAME="local" \
    N_PORT_NAME="local" \
    N_PORT_TIMEOUT="1" \
    N_FPING_OPTS="-R -b 56 -i 1 -r 0 -t 5000" \
    N_FPING_PING_EVERY="200"

COPY ["httpcheck.sh", "portcheck.sh", "fping.sh", "/etc/netdata/pre-start.d/"]
COPY ["*.yml", "/etc/netdata/overrides/"]

RUN ["cross-build-end"]