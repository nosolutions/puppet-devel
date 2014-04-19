# puppet-devel

A puppet vagrant development environment.

## Usage

- Clone the repo
- Add your module to puppet-module.yml
- Run `rake clone`
- Start a puppet master and agents
   `vagrant up master`

   `vagrant up rhagent`
   
## Supported Vagrant Boxes

The master and rhagent should work out of the box as they are using the puppetlabs
centos 6 vagrant boxes.

To use the Solaris 10/11 boxes you have to create a Solaris 10/11 virtualbox appliance with puppet and OpenCSW preinstalled.
