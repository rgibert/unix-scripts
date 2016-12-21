#!/bin/bash

function print_help() {
    echo "usage: $(basename ${0}) FQDN"
    echo ""
    echo "    FQDN    FQDN of key pair to validate, expects to find FQDN.cer and FQDN.key files"
    echo ""
}

if [[ "${1}" == "--help" ]] || [[ "${1}" == "-h" ]]; then
    print_help
else
    FQDN=${1}
fi

# Validate required tools are installed
for CMD in openssl diff; do
    if [[ ! -f $(which ${CMD}) ]]; then
        echo "ERROR: ${CMD} command not found"
        exit 1
    fi
done

# Validate input key pair exists
for EXT in cer key; do
    if [[ ! -f "${FQDN}.${EXT}" ]]; then
        echo "ERROR: ${FQDN}.${EXT} file not found"
        exit 1
    fi
done

export C=$(openssl x509 -noout -modulus -in ${FQDN}.cer | openssl md5)
export K=$(openssl rsa -noout -modulus -in ${FQDN}.key | openssl md5)
if [[ $(diff <(echo ${C}) <(echo ${K}) | wc -l) -eq 0 ]]; then
    echo "Key pair match"
    exit 0
else
    echo "Key pair DO NOT match"
    exit 1
fi
