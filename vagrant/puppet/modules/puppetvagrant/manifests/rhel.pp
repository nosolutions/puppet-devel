# == Class: rhel
#
#
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if it
#   has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should not be used in preference to class parameters  as of
#   Puppet 2.6.)
#
# === Examples
#
#  class { sysdoc:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ]
#  }
#
# === Authors
#
# Toni Schmidbauer <toni@stderr.at>
#
# === Copyright
#
# Copyright 2014 Toni Schmibauer
#
class rhel {

  service { 'iptables':
    ensure    => stopped,
  }

  package { 'git':
    ensure  => 'latest',
  #  require => Augeas['yum.conf'],
  }

  package { 'vim-enhanced':
    ensure  => 'latest',
  #  require => Augeas['yum.conf'],
  }

  augeas { 'puppetconf':
    context => '/files/etc/puppet/puppet.conf',
    changes => [
                'set production/modulepath "$confdir/forge:$confdir/modules"',
                'set agent/server "192.168.1.2"',
                ],
  }
}
