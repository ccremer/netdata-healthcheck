#!/bin/bash

config_dir="/etc/netdata"
netdata_config="${config_dir}/netdata.conf"
config="${config_dir}/python.d/httpcheck.conf"
tmp_config="/tmp/httpcheck.yml"

#-----------------------
# Functions

write() {
    echo "${1}" >> ${tmp_config}
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

log() {
    echo "[netdata] ${1}"
}

#-----------------------
# The actual work


if [[ -n ${N_HTTP_URL} ]]; then
    orig="${config}.orig"
    mv ${config} ${orig}
    write_http_config
    merge-yaml -i "${orig}" ${tmp_config} -o ${config}
    rm ${tmp_config}
else
    log "WARNING: Environment variable N_HTTP_URL is not defined, which disables httpcheck."
fi

# Enable python.d plugin
crudini --inplace --set ${netdata_config} plugins python.d yes
