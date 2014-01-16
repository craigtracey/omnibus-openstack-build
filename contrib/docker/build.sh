#!/bin/sh

project_dir='/opt/openstack'

mkdir -p ${project_dir}
export PATH=/usr/local/bin:$PATH
cd /build
bundle install --path=/root/.bundler

export CHEF_GIT_REV={$CHEF_GIT_REV:-'master'}
bundle exec omnibus-openstack build -m /build/openstack-config.yml -c /tmp/.cache