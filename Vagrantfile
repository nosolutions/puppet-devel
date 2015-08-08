# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|


  config.vm.define "centos7", primary: true do |centos7|
    centos7.vm.box = "puppetlabs/centos-7.0-64-puppet"
    centos7.vm.hostname = 'centos7'
    centos7.vm.box_url = "puppetlabs/centos-7.0-64-puppet"
    centos7.vm.network "private_network", ip: "192.168.1.2", virtualbox__intnet: true

    centos7.vm.provision :shell do |shell|
      shell.inline = "mkdir -p /etc/puppet/modules;
                      puppet module install maestrodev/rvm;
                      puppet module install saz/sudo"
    end

    centos7.vm.provision :puppet do |puppet|
      puppet.manifest_file  = "master.pp"
      puppet.manifests_path = "vagrant/puppet/manifests"
      puppet.module_path = "vagrant/puppet/modules"
      puppet.options = '--verbose --debug'
    end
  end

  config.vm.define "centos6" do |centos6|
    centos6.vm.box = "puppetlabs/centos-6.6-64-puppet"
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
end
