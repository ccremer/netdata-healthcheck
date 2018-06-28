#!/bin/sh

config_dir="/etc/netdata"
netdata_config="${config_dir}/netdata.conf"
fping_conf="${config_dir}/fping.conf"

log() {
    echo "[netdata] ${1}"
}

if [[ -z ${N_FPING_HOSTNAMES} ]]; then
    log "WARNING: Environment variable N_FPING_HOSTNAMES is not defined, which disables fping."
else
    # Apply the fping configs
    mv ${fping_conf} ${fping_conf}.orig
    echo "hosts=\"${N_FPING_HOSTNAMES}\"" >> ${fping_conf}
    echo "ping_every=\"${N_FPING_PING_EVERY}\"" >> ${fping_conf}
    echo "fping_opts=\"${N_FPING_OPTS}\"" >> ${fping_conf}
    if [[ -n ${N_FPING_UPDATE_EVERY} ]]; then
        echo "update_every=${N_FPING_UPDATE_EVERY}" >> ${fping_conf}
    fi
fi

# Enable fping plugin
crudini --inplace --set ${netdata_config} plugins fping yes
