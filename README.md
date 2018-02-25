# netdata-healthcheck

[netdata-minimal](https://github.com/ccremer/netdata-minimal) with ping, http and port checks enabled

## Environment Variables

These environment variables are supported **in addition** to the base image:

Key | Default value | Accepted values | Description
--- | ---           | ---             | ---
`N_FPING_HOSTNAMES`    | (unset) | string  | Space separated list of DNS hostnames or IP addresses.
`N_FPING_PING_EVERY`   | `200`   | integer | The amount of ms between each ping.
`N_FPING_OPTS`         | `-R -b 56 -i 1 -r 0 -t 5000` | string | See below.
`N_FPING_UPDATE_EVERY` | (unset) | integer | The chart update frequency for fping (by default inherits from netdata).
`N_HTTP_URL`           | (unset) | string  | Full URL to the server e.g. `https://server:8443/path`.
`N_HTTP_NAME`          | `local` | string  | The job name of the http check.
`N_HTTP_REGEX`         | (unset) | regex   | Optional regex to search for in the HTTP response.
`N_HTTP_REDIRECT`      | `yes`   | `yes` or `no` | Follow 3xx redirections before checking regex.
`N_HTTP_STATUS_CODES`  | `200`   | integer list | Specify a space separated list of acceptable http status codes.
`N_HTTP_TIMEOUT`       | `1`     | decimal | Specify the response timeout in seconds (supports decimals).
`N_HTTP_UPDATE_EVERY`  | (unset) | integer | The chart update frequency for http checks (by default inherits from netdata).
`N_PORT_HOST`          | (unset) | IP or DNS | The host for the port check.
`N_PORT_PORT`          | (unset) | integer | Ports number to check on `N_PORT_HOST`.
`N_PORT_NAME`          | `local` | string  | The job name of the port check.
`N_PORT_TIMEOUT`       | `1`     | integer | The socket timeout when connecting.
`N_PORT_UPDATE_EVERY`  | (unset) | integer | The chart update frequency for port checks (by default inherits from netdata).

Make sure to properly escape the supplied regex for yaml-parsing.

The default fping options are:
* -R      = send packets with random data
* -b 56   = the number of bytes per packet
* -i 1    = 1 ms when sending packets to others hosts (switching hosts)
* -r 0    = never retry packets
* -t 5000 = per packet timeout at 5000 ms


## Notes

* If you want check multiple hosts for port/http then you will have to mount `/etc/netdata/python.d/httpcheck.conf`
  and `/etc/netdata/python.d/portcheck.conf` from outside this container. But then you should not specify
  `N_HTTP_URL` or `N_PORT_PORT` resp. anymore, as they would probably cause a mess in your config.
* By default, a series of 5 pings will be sent to every host per second. If you don't want to bombard your
  hosts, set `N_FPING_UPDATE_EVERY` to `5` and `N_FPING_PING_EVERY` to `1000`
  in order to send 1 ping every second. The downside is, that the chart will be updated every 5 seconds
  instead of every 1 second. `fping` is only enabled if you set `N_FPING_HOSTNAMES`.
* If you provide hostnames in `N_FPING_HOSTNAMES`, they must be resolvable at container startup. Otherwise
  the affected hosts won't be in the charts.
* Alarms are disabled by default, but you can enable them on a nedata master, if this container is a slave.

## Docker Compose Quick start

```yaml
version: '3'
services:
  netdata-healthcheck:
    image: braindoctor/netdata-healthcheck
    environment:
      - N_FPING_HOSTNAMES=google.com
      - N_HTTP_URL=https://google.com/
      - N_PORT_HOST=google.com
      - N_PORT_PORT=443
      - N_ENABLE_WEB=yes
    ports:
      - "19999:19999"
```

`$ docker-compose up -d`

You can now browse to http://localhost:19999/

## Docker Compose Full example

```yaml
version: '3'
services:
  netdata-healthcheck:
    restart: unless-stopped
    image: braindoctor/netdata-healthcheck
    container_name: netdata-healthcheck
    volumes:
      - /etc/localtime:/etc/localtime:ro
    extra_hosts:
      - "google:8.8.8.8"
    environment:
      - N_FPING_UPDATE_EVERY=1
      - N_FPING_PING_EVERY=200
      - N_FPING_HOSTNAMES=google
      - N_FPING_OPTS=-R -b 56 -i 1 -r 0 -t 5000
      - N_HTTP_URL=https://google.com/
      - N_HTTP_NAME=google
      - N_HTTP_REGEX=.*
      - N_HTTP_REDIRECT=yes
      - N_HTTP_STATUS_CODES=200 301
      - N_HTTP_TIMEOUT=1
      - N_HTTP_UPDATE_EVERY=1
      - N_PORT_HOST=google.com
      - N_PORT_PORT=443
      - N_PORT_NAME=google
      - N_PORT_TIMEOUT=1
      - N_PORT_UPDATE_EVERY=1
      # streaming is optional, but recommended if you have a netdata master
      - N_STREAM_DESTINATION=your.netdata.master
      - N_STREAM_API_KEY=11111111-2222-3333-4444-555555555555
    # for testing enable web and ports (not required for streaming only):
      - N_ENABLE_WEB=yes
    ports:
      - "19999:19999"
```

Pro tip: You can add `extra_hosts` to create host names that do not require a TLD, so that
the charts will have sensible names that do not expose host names. The downside is that the
extra_host parameters do not accept other host names, they must be IP addresses.
