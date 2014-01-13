# -*- mode: ruby -*-
# vi: set ft=ruby :

require "vagrant"

if Vagrant::VERSION < "1.2.1"
  raise "The Omnibus Build Lab is only compatible with Vagrant 1.2.1+"
end

host_project_path = File.expand_path("..", __FILE__)
guest_project_path = "/home/vagrant/#{File.basename(host_project_path)}"
project_name = 'openstack'
host_name = "#{project_name}-omnibus-build-lab"
bootstrap_chef_version = '11.8.2'

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
        c.omnibus.chef_version = bootstrap_chef_version

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

      config.berkshelf.enabled = true
      config.ssh.forward_agent = true

      config.vm.synced_folder '.', '/vagrant', :id => 'vagrant-root', :nfs => use_nfs
      config.vm.synced_folder host_project_path, guest_project_path, :nfs => use_nfs

      # Uncomment for DEV MODE
      # config.vm.synced_folder File.expand_path('../../omnibus-ruby', __FILE__), '/home/vagrant/omnibus-ruby', :nfs => use_nfs
      # config.vm.synced_folder File.expand_path('../../omnibus-software', __FILE__), '/home/vagrant/omnibus-software', :nfs => use_nfs

      # prepare VM to be an Omnibus builder
      c.vm.provision :chef_solo do |chef|
        chef.nfs = use_nfs
        chef.json = {
          'omnibus' => {
            'build_user' => 'vagrant',
            'build_dir' => guest_project_path,
            'install_dir' => "/opt/openstack"
          }
        }
        chef.run_list = [
          'recipe[omnibus::default]',
          'recipe[omnibus-openstack::default]'
        ]
      end

      c.vm.provision :shell, :inline => <<-OMNIBUS_BUILD
        sudo mkdir -p /opt/#{project_name}
        sudo chown vagrant /opt/#{project_name}
        export PATH=/usr/local/bin:$PATH
        cd #{guest_project_path}
        sudo su vagrant -c "bundle install --path=/home/vagrant/.bundler"
        export CHEF_GIT_REV=#{ENV['CHEF_GIT_REV'] || 'master'}
        sudo su vagrant -c "bundle exec omnibus-openstack build -m /vagrant/openstack-config.json -c /tmp/omnibus-cache"
      OMNIBUS_BUILD

    end # config.vm.define.platform
  end # each_with_index
end # Vagrant.configure
