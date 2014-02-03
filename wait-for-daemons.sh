#!/bin/bash

usage()
{
cat << EOF
usage: $0 options

This script polls supervisorctl status and only exits when all the programs passed in as arguments
have the status RUNNING. If a program is not configured to be running under supervisord then it will
be ignored.

OPTIONS:
   -h      Show this message
   -p      Optionally specify path to supervisorctl

EXAMPLE USAGE:
   wait-for-daemons -p /usr/sbin/supervisorctl sshd apache2
EOF
}

SUPERVISORCTL_PATH="supervistorctl"
while getopts ":hp:" OPTION
do
    case $OPTION in
        h)
            usage
            exit 1
            ;;
        p)
            SUPERVISORCTL_PATH=$OPTARG
            ;;
        ?)
            usage
            exit
            ;;
    esac
done

shift $(( OPTIND - 1 ))
for program in "$@"; do
    echo "checking $program"
    while [ 1 ]; do
        if [ "`supervisorctl status $program`" == "No such process $program" ] ; then
            echo $program is not configured to be running
            break
        fi
        status=`supervisorctl status $program | awk '{print $2}'`
        if [ "$status" == "RUNNING" ] ; then
            echo $program running
            break
        else
            echo $program has status $status
            sleep 1
        fi
    done
done