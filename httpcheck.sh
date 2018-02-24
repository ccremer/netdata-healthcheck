#!/usr/bin/env bash

config_dir="/etc/netdata"
netdata_config="${config_dir}/netdata.conf"
config="${config_dir}/python.d/httpcheck.conf"


#-----------------------
# Functions

write() {
    echo "${1}" >> ${config}
}

write_http_config() {

    if [[ -n ${N_HTTP_UPDATE_EVERY} ]]; then
        write "update_every: ${N_HTTP_UPDATE_EVERY}"
    fi

    write "${N_HTTP_NAME}:"
    write "  url: ${N_HTTP_URL}"
    write "  timeout: ${N_HTTP_TIMEOUT}"
    write "  redirect: ${N_HTTP_REDIRECT}"
    write "  status_accepted:"

    for code in ${N_HTTP_STATUS_CODES}; do
        write "    - ${code}"
    done

    if [[ -n ${N_HTTP_REGEX} ]]; then
        write "  regex: ${N_HTTP_REGEX}"
    fi

}

#-----------------------
# The actual work


if [[ -n ${N_HTTP_URL} ]]; then
    write_http_config
else
    echo "WARNING: Environment variable N_HTTP_URL is not defined, which disables httpcheck."
fi

cat ${config}

# Enable python.d plugin
crudini --inplace --set ${netdata_config} plugins python.d yes
