omnibus-openstack-example
=========================
This repository is simply an example of how one would use [omnibus-openstack](https://github.com/craigtracey/omnibus-openstack)

Installation
------------
```
bundle install --binstubs
```

### Using Vagrant
Included is a vagrant build lab, you can use it to autobuild the omni packages
````
 vagrant plugin install vagrant-berkshelf
 vagrant plugin install vagrant-omnibus
````

````
vagrant up
````

````
vagrant up ubuntu-12.04
````

### Using Docker
Included is a docker build lab, you can use it to autobuild the omni packages

Run this to build the omnibus builder docker image, this only needs to be done once unless there are breaking changes made to supporting repos.

````
docker build -t omnibus-openstack .
````

Run this to build the packages and export them to the mapped volume ( `./pkg` in this example )

```
docker run -v $PWD/pkg:/build/pkg:rw omnibus-openstack
```

