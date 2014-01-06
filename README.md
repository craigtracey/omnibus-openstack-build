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
