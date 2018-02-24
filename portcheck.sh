#!/usr/bin/env bash

config_dir="/etc/netdata"
netdata_config="${config_dir}/netdata.conf"
config="${config_dir}/python.d/portcheck.conf"


#-----------------------
# Functions

write() {
    echo "${1}" >> ${config}
}

write_port_config() {

    if [[ -n ${N_PORT_UPDATE_EVERY} ]]; then
        write "update_every: ${N_PORT_UPDATE_EVERY}"
    fi

    write "${N_PORT_NAME}:"
    write "  host: ${N_PORT_HOST}"
    write "  timeout: ${N_PORT_TIMEOUT}"
    write "  ports:"

    for port in ${N_PORT_PORTS}; do
        write "    - ${port}"
    done

}

#-----------------------
# The actual work


if [[ -n ${N_PORT_PORTS} ]]; then
    write_port_config
else
    echo "WARNING: Environment variable N_PORT_PORTS is not defined, which disables portcheck."
fi

# Enable python.d plugin
crudini --inplace --set ${netdata_config} plugins python.d yes
