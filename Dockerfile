# dockerfile

FROM paulczar/chef-client

RUN apt-get -yqq update

RUN apt-get -yqq install git wget curl

ADD . /build

RUN mkdir -p /build/pkg

RUN cd /build && /opt/chef/embedded/bin/berks install --path /chef/cookbooks

RUN chef-solo -c /build/contrib/docker/solo.rb -j /build/contrib/docker/chef.json

RUN chmod +x /build/contrib/docker/build.sh

CMD ["/build/contrib/docker/build.sh"]

