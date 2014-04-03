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

BUILD_DIR="/tmp/omnibus-openstack"

while getopts “hm:g:b:t:” OPTION
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
        ?)
            usage
            exit -1
            ;;
    esac
done

prepare_debian() {
    apt-get update
    apt-get install -y curl git libffi-dev build-essential
}

if lsb_release -i | grep Ubuntu >> /dev/null; then
    prepare_debian
else
    echo "Unknown platform"
    exit -1
fi

curl -L https://www.opscode.com/chef/install.sh | bash
export PATH=/opt/chef/embedded/bin/:$PATH
gem install bundler --no-rdoc --no-ri

TEMPDIR=`mktemp -d`
git clone $GIT_REPO -b $GIT_BRANCH $TEMPDIR/omnibus-openstack-build

rm -rf $BUILD_DIR
ln -s $TEMPDIR $BUILD_DIR

cd $BUILD_DIR/omnibus-openstack-build
bundle install
bundle exec berks install --path cookbooks
chef-solo -j chef-solo/solo.json -c chef-solo/solo.rb
bundle exec omnibus-openstack build -m $OMNIBUS_MANIFEST -c /tmp/.cache
