#!/bin/bash

set -e

usage()
{
cat << EOF
usage: $0 <options>

A tool for building omnibus-openstack within a Vagrant instance.

OPTIONS:
   -h   this help message
   -m   manifest file to be passed omnibus-openstack
   -g   git repository to build against
   -b   git branch to use (default: master)
   -p   provision only
EOF
}

GIT_REPO="https://github.com/craigtracey/omnibus-openstack-build.git"
GIT_BRANCH="master"
OMNIBUS_MANIFEST="openstack-config.yml"
PROVISION_ONLY=0

BUILD_DIR="/tmp/omnibus-openstack"

while getopts “hm:g:b:p” OPTION
do
    case $OPTION in
        h)
            usage
            exit 0
            ;;
        m)
            OMNIBUS_MANIFEST=$OPTARG
            ;;
        g)
            GIT_REPO=$OPTARG
            ;;
        b)
            GIT_BRANCH=$OPTARG
            ;;
        p)
            PROVISION_ONLY=1
            ;;
        ?)
            usage
            exit -1
            ;;
    esac
done

if [ ! -f "$OMNIBUS_MANIFEST" ]; then
    echo "$OMNIBUS_MANIFEST is not a file"
    exit -1
fi

mkdir -p .omnibus
TEMPFILE=$(mktemp -p .omnibus -t tmp_omnibus_manifestXXXX.yml)
cp $OMNIBUS_MANIFEST $TEMPFILE

export OMNIBUS_OPENSTACK_MANIFEST="$TEMPFILE"
export OMNIBUS_OPENSTACK_BRANCH=$GIT_BRANCH

if [[ "$PROVISION_ONLY" == "0" ]]; then
    vagrant up
else
    vagrant provision
fi

exit
