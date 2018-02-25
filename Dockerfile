FROM braindoctor/netdata-minimal

RUN \
    # Currently, the only way to install these plugins, as they are not in netdata main repo (yet)
    # Plugins
    curl -o /usr/libexec/netdata/python.d/portcheck.chart.py \
        https://raw.githubusercontent.com/ccremer/netdata/portcheck/python.d/portcheck.chart.py && \
    curl -o /usr/libexec/netdata/python.d/httpcheck.chart.py \
        https://raw.githubusercontent.com/ccremer/netdata/httpcheck/python.d/httpcheck.chart.py && \
    # Configuration
    curl -o /etc/netdata/python.d/portcheck.conf \
        https://raw.githubusercontent.com/ccremer/netdata/portcheck/conf.d/python.d/portcheck.conf && \
    curl -o /etc/netdata/python.d/httpcheck.conf \
        https://raw.githubusercontent.com/ccremer/netdata/httpcheck/conf.d/python.d/httpcheck.conf && \
    # Alarms
    curl -o /etc/netdata/health.d/httpcheck.conf \
        https://raw.githubusercontent.com/ccremer/netdata/httpcheck/conf.d/health.d/httpcheck.conf && \
    curl -o /etc/netdata/health.d/portcheck.conf \
        https://raw.githubusercontent.com/ccremer/netdata/portcheck/conf.d/health.d/portcheck.conf

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
