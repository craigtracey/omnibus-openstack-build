#!/bin/bash

set -e

usage()
{
cat << EOF
usage: $0 <options>

A tool for building omnibus-openstack within a Heat stack.

OPTIONS:
   -h   this help message
   -m   manifest file to be passed omnibus-openstack
   -g   git repository to build against
   -b   git branch to use (default: master)
   -u   build user
   -k   user's ssh key
   -e   heat environment file to use (default: heat/environment.yml)
   -p   provision only
EOF
}

GIT_REPO="https://github.com/craigtracey/omnibus-openstack-build.git"
GIT_BRANCH="master"
OMNIBUS_MANIFEST="openstack-config.yml"
OMNIBUS_BUILD_USER=""
OMNIBUS_BUILD_KEY=""
HEAT_ENVIRONMENT="./heat/environment.yml"
PROVISION_ONLY=0

while getopts “hm:g:b:pu:k:e:” OPTION
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
        u)
            OMNIBUS_BUILD_USER=$OPTARG
            ;;
        k)
            OMNIBUS_BUILD_KEY=$OPTARG
            ;;
        e)
            HEAT_ENVIRONMENT=$OPTARG
            ;;
        ?)
            usage
            exit -1
            ;;
    esac
done

if [ -z "$OMNIBUS_BUILD_USER" ]; then
    echo "You must provide a build user (-u)"
    exit -1;
fi

if [ ! -f "$OMNIBUS_BUILD_KEY" ]; then
    echo "'$OMNIBUS_BUILD_KEY' is not a file"
    exit -1;
fi

if [ ! -f "$HEAT_ENVIRONMENT" ]; then
    echo "'$HEAT_ENVIRONMENT' is not a file"
    exit -1;
fi

NEW_UUID=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1)
STACK_NAME="omnibus-openstack-$NEW_UUID"

wait_for_stack() {
    STACK_NAME=$1
    while [ 1 ]; do
        if heat stack-list | grep " $STACK_NAME " | grep -v CREATE_IN_PROGRESS >> /dev/null; then
            break
        fi
        echo "Waiting for stack creation..."
        sleep 2
    done;
}

wait_for_ssh() {
    STACK_FIP=$1
    KEY=$2
    USER=$3
    LIMIT=60
    I=0
    while [ $I -le "$LIMIT" ]; do
        echo "ssh -q -i $KEY -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $USER@$STACK_FIP exit"
        if ssh -q -i $KEY -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $USER@$STACK_FIP exit; then
            break
        fi
        echo "Waiting for ssh server to be available..."
        sleep 2
    done;
}

if [ "$PROVISION_ONLY" == "0" ]; then
    echo "Launching build stack ($STACK_NAME)..."
    echo "heat stack-create -f "./heat/omnibus-openstack.yml" -e "$HEAT_ENVIRONMENT" $STACK_NAME"
    heat stack-create -f "./heat/omnibus-openstack.yml" -e "$HEAT_ENVIRONMENT" $STACK_NAME >> /dev/null
    wait_for_stack $STACK_NAME
fi

OMNIBUS_FIP=`heat output-show $STACK_NAME omnibus_fip | sed 's/"//g'`
if [ -z "$OMNIBUS_FIP" ]; then
    echo "Failed to get a floating IP for $STACK_NAME"
    exit -1
fi

echo "Using omnibus floating IP of: $OMNIBUS_FIP"


wait_for_ssh $OMNIBUS_FIP $OMNIBUS_BUILD_KEY $OMNIBUS_BUILD_USER

scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i $OMNIBUS_BUILD_KEY .omnibus_builder.sh $OMNIBUS_BUILD_USER@$OMNIBUS_FIP:/tmp/.omnibus_builder.sh
scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i $OMNIBUS_BUILD_KEY $OMNIBUS_MANIFEST $OMNIBUS_BUILD_USER@$OMNIBUS_FIP:/tmp/.omnibus_manifest.yml
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i $OMNIBUS_BUILD_KEY $OMNIBUS_BUILD_USER@$OMNIBUS_FIP "bash -c 'chmod +x /tmp/.omnibus_builder.sh && sudo /tmp/.omnibus_builder.sh -m /tmp/.omnibus_manifest.yml -b $GIT_BRANCH -g $GIT_REPO'"

mkdir -p pkg
scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i $OMNIBUS_BUILD_KEY $OMNIBUS_BUILD_USER@$OMNIBUS_FIP:/tmp/omnibus-openstack/pkg/* pkg

echo "DONE"
