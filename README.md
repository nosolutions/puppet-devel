## Table of contents

1. [What is puppet-devel?](#what-is-puppet-devel?)
2. [Getting started](#getting-started)
  * [Prerequisites](#prerequisites)
  * [Bootstrapping the development environment](#bootstrapping-the-development-environment)
  * [Changing proxy settings](#changing-proxy-settings)
  * [Mapped Folders](#mapped-folders)
  * [Rake](#rake)
  * [Configuration](#configuration)
  * [Cloning the site modules](#cloning-the-site-modules)
3. [Creating a module](#creating-a-module)
  * [Module naming conventions] (#module-naming-conventions)
4. [Working on an existing module](#working-on-an-existing-module)
5. [Releasing a module](#releasing-a-module)
6. [Deploying a module](#deploying-a-module)
7. [Creating a site-module](#creating-a-site-module)
8. [Working with vagrant](#working-with-vagrant)
9. [Ruby environments](#ruby-environments)
  * [Running puppet as root](#running-puppet-as-root)

## What is puppet-devel?

A puppet development environment within a virtual box image. Currently the
following boxes are supported:

- Centos 7
- Centos 6

## Getting started

Clone me.

### Prerequisites

You need a working installation of the following software components:

- virtualbox (http://virtubalbox.org)
- vagrant (http://vagrantup.com)
- git (http://git-scm.org)

Please always use the latest and greatest `vagrant` version available
(1.7.4 as of this time).

`puppet-devel` supports the following vagrant boxes:

- `puppetlabs/centos7` version 1.0.2
- `puppetlabs/centos6` version 1.0.2

if you have any problems running vagrant please make sure you use the
appropriate box version.

### Bootstrapping the development environment

Before using git the first time please set our name and email address

```
$ git config --global user.name "Your Name"
$ git config --global user.email "youre-mail.address"
```

Clone the `puppet-devel` repository with:

```
$ git clone https://github.com/nosolutions/puppet-devel.git
```

It may be necessary to use a http proxy for downloading the base
box. Use the environment variables `http_proxy` and `https_proxy` for
specifing a proxy server.

Change into the `puppet-devel` directory and start the default vagrant
box (CentOS 7).

### Changing proxy settings

If you are in a private network it may be required to set the
environment variables _http_proxy_ and _https_proxy_ before running
`vagrant up`.

```
$ export http_proxy=http://your.proxy:proxy-port
$ export https_proxy=$http_proxy
```
You may also need to change the proxy settings for provisioning the
vagrant box. this has to be done in the file `.settings.yaml`,

```
$ cd puppet-devel
$ vi .settings.yaml
```

change the `http_proxy` proxy setting.

Now run `vagrant up`:

```
$ cd puppet-devel
$ vagrant status
Current machine states:

centos7                   not created (virtualbox)
centos6                   not created (virtualbox)

This environment represents multiple VMs. The VMs are all listed
above with their current state. For more information about a specific
VM, run `vagrant status NAME`.

$ vagrant up
...
```

If a proxy is required, please use

```
$ export http_proxy=http://<you proxy>:<proxy port>
$ export https_proxy=$https_proxy
$ vagrant up
```

If you call `vagrant up` the first time `vagrant` will start
downloading the so called base box (puppetlabs/centos7 version
1.0.2). After downloading, it's going to start provisioning the
box. This will take some time, so please be patient.

After provisioning, you can start using the box:

```
$ vagrant status
Current machine states:

centos7                   running (virtualbox)
centos6                   not created (virtualbox)

This environment represents multiple VMs. The VMs are all listed
above with their current state. For more information about a specific
VM, run `vagrant status NAME`.
```

Before logging into the development environment the first time you
need to

- start ssh-agent
- load you Gitlab key into the ssh-agent

otherwise certain commands a are going to fail.

```
$ eval `ssh-agent`
$ ssh-add .ssh/<your gitlab private keyfile>
```

Login to the default box with

```
$ vagrant ssh
Last login: Wed Aug 26 08:55:55 2015 from 10.0.2.2
Using /usr/local/rvm/gems/ruby-2.1.6 with gemset puppet
[vagrant@centos7 ~]$ ssh-add -l
4096 <you key fingerprint> <path to you private key file (RSA)
[vagrant@centos7 ~]$
```

All commands listed below should be executed within the vagrant box.

### Mapped folders

One feature of `vagrant` are so called mapped folders. This means all
files within the `puppet-devel` directory you created above are also
available within the vagrant box in the folder `/vagrant/`.

Outside the box

```
$ ls -t
README.md  modules/  lib/  puppet/  Gemfile.lock  Gemfile  config.yaml  Vagrantfile  utils/  Rakefile  LICENSE
```

Inside the box:

```
$ vagrant ssh
[vagrant@centos7 ~]$ ls -t /vagrant/
README.md  modules/  lib/  puppet/  Gemfile.lock  Gemfile  config.yaml  Vagrantfile  utils/  Rakefile  LICENSE
[vagrant@centos7 ~]$
```

So it's possible to edit files outside the box and use the same files
within the box for testing.

### Rake

There's a `Rakefile` in the root directory of the `puppet-devel`
repository (`/vagrant/Rakefile` within the box) that helps with
cloning existing repositories and creating new modules. It supports
creating new site modules (which is deprectated) and modules hosted in
separate git repositories.

Rake looks in the current directory for a valid Rakefile so there a
command `grake` that always calls rake in `/vagrant`. Please always
use `grake` if you need to call the targets listed below.

The following targets are available:

```ruby
$ grake
calling rake in /vagrant

rake clean                       # remove all cloned repositories
rake clone                       # clone configured git repositories
rake config                      # configure the development environment
rake console:acceptance[module]  # show the console output of the acceptance job for a module
rake console:deployment          # show the console output of the deployment job
rake console:unittest[module]    # show the console output of the unittest job for a module
rake fixmodulelinks              # fix links to local modules for puppet apply testing
rake hiera:clone                 # clone the hiera data repository
rake hiera:deploy                # deploy hiera data
rake legacy:deploy               # deploy the leagcy puppet modules
rake legacy:release              # create a new release of legacy puppet modules
rake module:add                  # add an exising module you would like to work on
rake module:create[module]       # create a new standalone module
rake module:deploy[module]       # deploy a module
rake module:release[module]      # create a new release
rake module:remove[module]       # completely remove a module (local copy, repository and jenkins jobs)
rake module:site                 # create a new site module
rake module:status[module]       # show the current build status for a module
rake spec                        # Run RSpec code examples
```

### Configuration

Before you create your first module you have to configure the
development environment:

```
$ cd /vagrant
$ grake config
What is your gitlab host [localhost] ?
On what port is gitlab listing on [443] ?
What is your gitlab ssh port [9418] ?
What is your gitlab group [puppetmodules] ?
What is your gitlab username ? test
Please enter your Gitlab password:
What is your jenkins host [localhost] ?
On what port is jenkins listing on [80] ?
What is your jenkins username [jenkins] ?
Please enter your the Jenkins password for user jenkins:
```

In the default installation the password for user jenkins is `jenkins`.

## Cloning legacy modules

If you would like to start working on legacy modules (managed in one
large repository puppet/puppet.git), execute

```
$ cd /vagrant
$ grake clone
```

You can now jump to [Creating a site-module](#creating-a-site-module)
if you would like to create a new site module.

## Creating a new module

Use `grake module:create` to create a new standalong puppet module. So for
example lets create a new `test` module.

```
$ grake module:create
calling rake in /vagrant

What is the name of the new module ? pup-testmodule
Who wrote this module [Toni Schmidbauer] ?
Please enter a short summary for this module [I was to lazy for a summary!] ?

----------------------------------------
{
  "name": "pup-testmodule",
  "version": "0.1.0",
  "author": "Toni Schmidbauer",
  "summary": "I was to lazy for a summary!",
  "license": "Apache-2.0",
  "source": "ssh://git@localhost:9418/puppetmodules/testmodule.git",
  "project_page": "https://localhost:443/puppetmodules/pup-testmodule",
  "issues_url": "https://localhost:443/puppetmodules/pup-testmodule/issues",
  "dependencies": [
    {"name":"puppetlabs-stdlib","version_requirement":">= 1.0.0"}
  ]
}
----------------------------------------
About to generate this module; continue [Yes] ?

Branch master set up to track remote branch master from origin.
```

This will create a new puppet module `testmodule` in the folder
`/vagrant/modules/`.  `/vagrant/modules/testmodule` is an
independent GIT repository. So you have to change to this directory
when executing GIT commands.

In addition to creating the local module in `modules/` `grake module:create`
will also create a central git repository on our gitlab server and
various jenkins jobs for testing, releasing and deploying the module.

### Module naming conventions

According to puppetlabs every module must have a prefix (organization
name/company name). Modules without a prefix will not work with the
puppetforge (https://forge.puppetlabs.com).

Keep in mind that the module name is used _without_ the prefix within
puppet. So the `pup-testmodule` module becomes `testmodule` when
used in puppet code. Our module deployment strips the prefix from the
modules.

To avoid conflicts with official modules (hosted on the forge), please
make sure before creating a new module that the name is not already
used. For example we would like to create a module to deploy
openssh. We would like to name the module `openssh`, but there is
already a module `openssh` on the forge. So we should name our new
module `pupopenssh` and the full name becomes `pup-pupopenssh`. Even
better use the module from the forge!

If this is confusing to you please refer to the
[offical puppetlabs documentation](https://docs.puppetlabs.com/puppet/latest/reference/modules_publishing.html#a-note-on-module-names).

## Checking the test status of a module

To see the status of the unittest and acceptance jobs execute `grake module:status[module name]`.

```
$ grake module:status[pup-testmodule]
calling rake in /vagrant

Jenkins job pup-testmodule_unittest is in status: success
Jenkins job pup-testmodule_acceptance is in status: failure
```

The console output of unittest is available via `grake console:unittest[module name]`.

```
grake console:unittest[pup-testmodule]
calling rake in /vagrant

==> Started by remote host localhost with note: triggered by push on branch master with 1 commits
Building on master in workspace /var/lib/jenkins/jobs/pup-testmodule_unittest/workspace

[Output of the unittest]
```

For the output of acceptance tests execute `grake console:acceptance[module name]`.

```
grake console:acceptance[pup-testmodule]
calling rake in /vagrant

==> Started by remote host gitlab with note: triggered by push on branch master with 1 commits
Building remotely on puppetkvm (puppet_acceptance) in workspace /var/lib/jenkins/workspace/pup-testmodule_acceptance
```

## Working on an existing module

If you would like to work on an existing puppet module start by
configuring the module you would like to work on via

```
$ grake module:add
Enter the module name ? puppet-tsm
Where can I find the module ? https://github.com/nosolutions/puppet-tsm.git
```

You can then clone the module with `grake clone` and start working.

```
$ grake clone
calling rake in /vagrant

=> successfully cloned your modules
```

## Releasing a module

To create a new release execute `grake module:release[module name]

```
grake module:release[pup-testmodule]
calling rake in /vagrant

Jenkins job pup-testmodule_unittest is in status: success
Jenkins job pup-testmodule_acceptance is in status: failure
=> The current version of testmodule is 0.1.0.
Is this a major(x), minor(y) or bugfix(z) release (x/y/Z) [Z] ?
=> The current version of testmodule is now 0.1.1
```

We are using semantic versioning for module version, read more about semver at

[http://semver.org](http://semver.org).

`grake module:release` will not allow creating new releases if the
unittest are not working. See
[Checking the test status of a module](checking-the-test-status-of-a-module)
for more information.

## Deploying a module

To deploy a module to a puppet master execute `grake module:deploy[module name]`.
You can use tab-completion for the environment and the release

```
$ grake module:deploy[pup-testmodule]
calling rake in /vagrant

Jenkins job pup-testmodule_unittest is in status: success
Jenkins job pup-testmodule_acceptance is in status: failure
What environment would you like to deploy to? [tab tab]
development  production   testing
What environment would you like to deploy to? development
What version would you like to deploy? 0.[tab tab]
0.1.1  0.2.0
What version would you like to deploy? 0.2.0
```

You can check the status of the deployment with `grake console:deployment`

```
$ grake console:deployment
calling rake in /vagrant

==> Started by user Jenkins
Building on master in workspace /var/lib/jenkins/jobs/puppet-deployment/workspace

[Output of the deployment job]
```

## Working with vagrant

List available boxes with

```
vagrant status
```

Boot a preconfigured vagrant box with

```
vagrant up centos7
```

When `vagrant up` finishes you can login to the box with

```
vagrant ssh centos7
```

The puppet-devel repository and all its files and sub-repos are
available in the `/vagrant` folder.

## Ruby environments

We are using ruby's `rvm` to provide a stable development environment
within the vagrant box. The default rvm environment used is currently
`ruby-2.1.6@puppet` and all required ruby gems are also installed
within this gemset. Installation of required Gem's is done with
bundler when provisioning the vagrant box. So manual changes to the
gem setup are discouraged.

So the default rake targets when working on a module should work out
of the box, e.g:

- `rake lint`
- `rake spec`
- `rake syntax`

### Running puppet as root

Because of the use of `rvm` when you execute `sudo -i` as the vagrant
user to become root, your current envionment settings will be lost and
you are using the default puppet installation of the vagrant box.

To use the right puppet version as user root, please use the shell
alias `root`. so

```
[vagrant@centos7 ~]$ root
[root@centos7 vagrant]# which puppet
/vagrant/bin/puppet
[root@centos7 vagrant]#
```
