# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_version ">= 1.7.4"

$:.unshift File.dirname(__FILE__) + '/lib'

require 'puppetdevel/settings'

$PUPPETMODULES = """
mkdir -p /etc/puppet/modules;
export http_proxy=http://#{SETTINGS.http_proxy} \
export https_proxy=http://#{SETTINGS.http_proxy};
puppet module --modulepath=/etc/puppet/modules install maestrodev/rvm;
puppet module --modulepath=/etc/puppet/modules install saz/sudo
"""

$PUPPETMODULES_DEVEL = """
mkdir -p /etc/puppet/modules;
export http_proxy=http://#{SETTINGS.http_proxy} \
export https_proxy=http://#{SETTINGS.http_proxy};
puppet module --modulepath=/etc/puppet/modules install vshn/gitlab;
puppet module --modulepath=/etc/puppet/modules install rtyler/jenkins
"""

$FACTER_SETTINGS = {
  'http_proxy' => SETTINGS.http_proxy,
  'puppet_desired_version' => SETTINGS.puppet_version
}

def configure_provisioners(config)
  config.vm.provision "gitconfig", type: :file, source: "~/.gitconfig", destination: ".gitconfig"  if File.exists? ENV['HOME'] + '/.gitconfig'
  config.vm.provision "puppetmodules", type: :shell, inline: $PUPPETMODULES
  config.vm.provision "basic", type: :puppet do |puppet|
    puppet.facter = $FACTER_SETTINGS
    puppet.manifests_path = "utils/puppet/manifests"
    puppet.module_path = "utils/puppet/modules"
    puppet.manifest_file  = "centos.pp"
    puppet.environment_path = "utils/puppet/environments"
    puppet.environment = "vagrant"
    # puppet.options = '--verbose --debug'
  end
end

Vagrant.configure("2") do |config|
  config.ssh.forward_agent = true
  config.vm.box_check_update = false

  config.vm.define "centos7", primary: true do |centos7|
    centos7.vm.box_version = '= 1.0.2'
    centos7.vm.box = "puppetlabs/centos-7.0-64-puppet"
    centos7.vm.hostname = 'centos7'

    configure_provisioners(centos7)

    if File.exists? "#{File.dirname(__FILE__)}/.puppetdeveldevel"
      config.vm.provider "virtualbox" do |v|
        v.memory = 1024
      end

      config.vm.network "forwarded_port", host_ip: '127.0.0.1', guest: 443,   host: 8081, auto_correct: true
      config.vm.network "forwarded_port", host_ip: '127.0.0.1', guest: 8081, host: 8082, auto_correct: true
      centos7.vm.provision "puppetmodules_devel", type:  :shell do |shell|
        shell.inline = $PUPPETMODULES_DEVEL
      end
      centos7.vm.provision "testing", type: :puppet do |puppet|
        puppet.facter = $FACTER_SETTINGS
        puppet.manifests_path = "utils/puppet/manifests"
        puppet.module_path = "utils/puppet/modules"
        puppet.manifest_file  = "devel.pp"
        puppet.environment_path = "utils/puppet/environments"
        puppet.environment = "vagrant"
        # puppet.options = '--verbose --debug'
      end
    end
  end

  config.vm.define "centos6", primary: true, autostart: false do |centos6|
    centos6.vm.box_version = '= 1.0.2'
    centos6.vm.box = "puppetlabs/centos-6.6-64-puppet"
    centos6.vm.hostname = 'centos6'
    configure_provisioners(centos6)
  end
end
