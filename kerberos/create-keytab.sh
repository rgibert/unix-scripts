#!/bin/bash

function check_installed() {
    which ${1} &> /dev/null
    if [[ $? -ne 0 ]]; then
        print_err "${1} not found and required by this script"
    fi
}

function print_help() {
    echo "Usage: $(basename ${0}) [options]"
    echo ""
    echo "  Required:"
    echo ""
    echo "    -u principal   principal to be added"
    echo "    -f file        keytab file to save to"
    echo ""
    echo "  Optional:"
    echo ""
    echo "    -c ciphers     space separated list of ciphers to add (default = aes256-cts-hmax-sha1-96,arcfour-hmac)"
    echo "    -p password    principal's password"
    echo "    -o             if provided will overwrite the keytab, otherwise will add to it"
    echo "    -h             help screen"
}

function print_err() {
    echo "ERROR: ${1}"
    print_help
    exit 1
}

overwrite=0
ciphers="aes256-cts-hmax-sha1-96,arcfour-hmac"

while getopts ":u:f:p:c:oh" OPT; do
    shopt -s nocasematch
    case ${OPT} in
        u)
            principal=${OPTARG}
            ;;
        f)
            keytab=${OPTARG}
            ;;
        p)
            password=${OPTARG}
            ;;
        c)
            ciphers=${OPTARG}
            ;;
        o)
            overwrite=1
            ;;
        *)
            print_help
            ;;
    esac
done

if [[ -z ${principal} ]]; then
    print_err "-u principal not specified"
elif [[ -z ${keytab} ]]; then
    print_err "-f file not specified"
elif [[ -z ${password} ]]; then
    echo -n "Please enter the password for ${principal}"
    read -s password
    echo ""
fi

if [[ -f ${keytab} ]] && [[ ${overwrite} -eq 1 ]]; then
    rm -f ${keytab} &> /dev/null
fi

IFS=","
for cipher in ${ciphers}; do
    printf "%b" "addent -password -p ${principal} -k 1 -e ${cipher}\n${password}\nwrite_kt ${keytab}" | ktutil &> /dev/null
done
IFS=" "

printf "%b" "read_kt ${keytab}\nlist" | ktutil
