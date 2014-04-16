omnibus-openstack-build
=======================
This repository provides the tooling for building [omnibus-openstack](https://github.com/craigtracey/omnibus-openstack) packages. Currently it supports building by way of Vagrant or OpenStack Heat, but other methods of building are being worked on. And, while this has been written to build packages specifically for Ubuntu Precise, there is likely little that would need to be done to build these packages for other distros.

Building with Vagrant
---------------------
Building packages from within Vagrant, is as simple as executing the build_vagrant.sh and providing a manifest path:
```
usage: ./build_vagrant.sh <options>

A tool for building omnibus-openstack within a Vagrant instance.

OPTIONS:
   -h   this help message
   -m   manifest file to be passed omnibus-openstack
   -g   git repository to build against
   -b   git branch to use (default: master)
   -p   provision only
```

This builder is somewhat different than the standard omnibus build mechanisms. The intention is to support a variety of build techniques.  After all, if we are trying to build OpenStack packages, we probably have a cloud to build them on.  By wrapping Vagrant provisioning with this script, we can make all of the build mechanisms *kinda* look the same. More work needs to be done around this.

Building with Heat
------------------
Building packages with Heat is similar:
```
usage: ./build_heat.sh <options>

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
```

Prior to using Heat for provisioning, you will need to first configure your Heat environment.  An example is provided at 'heat/environment.yml.sample'.  Update this file to match your environment settings, and rename this file to 'heat/environment.yml'.

Common
------
Both of these wrappers create an instance and then execute .omnibus_builder.sh. .omnibus_builder.sh does all of the heavy lifting: it brings all of the common building code to one place.

Todos
-----
* Refactor the wrappers to share common bash functions.


License and Author
==================

Copyright 2013-2014, Craig Tracey <craigtracey@gmail.com>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
