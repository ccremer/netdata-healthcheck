#!/bin/bash

config_dir="/etc/netdata"
netdata_config="${config_dir}/netdata.conf"
config="${config_dir}/python.d/portcheck.conf"
tmp_config="/tmp/portcheck.yml"

#-----------------------
# Functions

write() {
    echo "${1}" >> ${tmp_config}
}

write_port_config() {

    if [[ -n ${N_PORT_UPDATE_EVERY} ]]; then
        write "update_every: ${N_PORT_UPDATE_EVERY}"
    fi

    write "${N_PORT_NAME}:"
    write "  host: ${N_PORT_HOST}"
    write "  port: ${N_PORT_PORT}"
    write "  timeout: ${N_PORT_TIMEOUT}"

}

log() {
    echo "[netdata] ${1}"
}

#-----------------------
# The actual work


if [[ -n ${N_PORT_PORT} && -n ${N_PORT_HOST} ]]; then
    orig="${config}.orig"
    mv ${config} ${orig}
    write_port_config
    merge-yaml -i "${orig}" ${tmp_config} -o ${config}
    rm ${tmp_config}
else
    log "WARNING: Environment variables N_PORT_PORT or N_PORT_HOST are not defined, which disables portcheck."
fi

# Enable python.d plugin
crudini --inplace --set ${netdata_config} plugins python.d yes
