# -*- mode: ruby -*-
# vi: set ft=ruby :

require "vagrant"

if Vagrant::VERSION < "1.2.1"
  raise "The Omnibus Build Lab is only compatible with Vagrant 1.2.1+"
end

manifest_file = ENV['OMNIBUS_OPENSTACK_MANIFEST'] || "openstack-config.yml"
omnibus_branch = ENV['OMNIBUS_OPENSTACK_BRANCH'] || "master"

Vagrant.configure('2') do |config|

  %w{
    ubuntu-12.04
  }.each_with_index do |platform, index|

    config.vm.define platform do |c|

      case platform
      when 'ubuntu-12.04'
        use_nfs = false
        c.vm.box = platform
        c.vm.box_url = "http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_#{platform}_chef-provisionerless.box"

        c.vm.provider :virtualbox do |vb|
          # Give enough horsepower to build without taking all day.
          vb.customize [
            'modifyvm', :id,
            '--memory', '1536',
            '--cpus', '2'
          ]
        end

      end # case

      ####################################################################
      # CONFIG SHARED ACROSS ALL PLATFORMS
      ####################################################################

      config.vm.synced_folder '.', '/vagrant', :id => 'vagrant-root', :nfs => use_nfs

      c.vm.provision :shell, :inline => <<-OMNIBUS_BUILD
        chmod +x /vagrant/build.sh
        sudo /vagrant/build.sh -b #{omnibus_branch} -m /vagrant/#{manifest_file}
      OMNIBUS_BUILD

    end # config.vm.define.platform
  end # each_with_index
end # Vagrant.configure
