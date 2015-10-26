#!/bin/bash

usage()
{
cat << EOF
usage: $0 options

This script polls supervisorctl status and only exits when all the programs passed in as arguments
have the status RUNNING. If a program is not configured to be running under supervisord then it will
be ignored.

OPTIONS:
   -a      Wait for all programs managed by supervisor to have started
   -h      Show this message
   -p      Optionally specify path to supervisorctl

EXAMPLE USAGE:
   wait-for-daemons -p /usr/sbin/supervisorctl sshd apache2
EOF
}

SUPERVISORCTL_PATH="supervisorctl"
while getopts ":ahp:" OPTION
do
    case $OPTION in
        a)
            ALL_PROGRAMS=1
            ;;
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
if [ $ALL_PROGRAMS ] ; then
    PROGRAM_LIST=( $($SUPERVISORCTL_PATH avail | awk '{print $1}') )
    set ${PROGRAM_LIST[*]}
fi
for program in "$@"; do
    echo "checking $program"
    while [ 1 ]; do
        if [ "`$SUPERVISORCTL_PATH status $program`" == "No such process $program" ] ; then
            echo $program is not configured to be running
            break
        fi
        status=`$SUPERVISORCTL_PATH status $program | awk '{print $2}'`
        if [ "$status" == "RUNNING" ] ; then
            echo $program running
            break
        else
            echo $program has status $status
            sleep 1
        fi
    done
done