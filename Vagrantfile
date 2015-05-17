# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|


  config.vm.define "master", primary: true do |master|
    master.vm.box = "puppetlabs/centos-7.0-64-puppet"
    master.vm.hostname = 'centos7'
    master.vm.box_url = "puppetlabs/centos-7.0-64-puppet"
    master.vm.network "private_network", ip: "192.168.1.2", virtualbox__intnet: true

    master.vm.provision :puppet do |puppet|
      puppet.manifest_file  = "master.pp"
      puppet.manifests_path = "vagrant/puppet/manifests"
      puppet.module_path = "vagrant/puppet/modules"
      puppet.options = '--verbose --debug'
    end
  end

  config.vm.define "centos6" do |centos6|
    centos6.vm.box = "centos-65-x64-virtualbox-puppet"
    centos6.vm.hostname = 'centos6'
    centos6.vm.box_url = "http://puppet-vagrant-boxes.puppetlabs.com/centos-65-x64-virtualbox-puppet.box"
    centos6.vm.network "private_network", ip: "192.168.1.3"

    centos6.vm.provision :puppet do |puppet|
      puppet.manifest_file  = "agent.pp"
      puppet.manifests_path = "vagrant/puppet/manifests"
      puppet.module_path = "vagrant/puppet/modules"
      puppet.options = '--verbose --debug'
    end
  end

  config.vm.define "centos5" do |rh|
    rh.vm.box = "centos-510-x64-virtualbox-puppet"
    rh.vm.hostname = 'centos5'
    rh.vm.box_url = "http://puppet-vagrant-boxes.puppetlabs.com/centos-510-x64-virtualbox-puppet.box"
    rh.vm.network :private_network, ip: "192.168.1.4", virtualbox__intnet: true

    rh.vm.provision :puppet do |puppet|
      puppet.manifest_file  = "agent.pp"
      puppet.manifests_path = "vagrant/puppet/manifests"
      puppet.module_path = "vagrant/puppet/modules"
      puppet.options = '--verbose --debug'
    end
  end

  config.vm.define "sol10agent" do |sol10|
    sol10.vm.box = "vagrant-sol10-puppet"
    sol10.vm.hostname = 'sol10agent'
    sol10.vm.box_url = "http://<insert server here>/vagrant/vagrant-sol10-puppet.box"
    sol10.vm.network :private_network, ip: "192.168.1.5", virtualbox__intnet: true

    sol10.vm.provision :puppet do |puppet|
      puppet.manifest_file  = "agent.pp"
      puppet.manifests_path = "vagrant/puppet/manifests"
      puppet.module_path = "vagrant/puppet/modules"
    end
  end

  config.vm.define "sol11agent" do |sol11|
    sol11.vm.box = "vagrant-sol11-pueppet"
    sol11.vm.hostname = 'sol11agent'
    sol11.vm.box_url = "http://<insert server here>/vagrant/vagrant-sol11-puppet.box"
    sol11.vm.network :private_network, ip: "192.168.1.6", virtualbox__intnet: true
  end

end
