#
# this configures our puppet test vm
#

# install required packages
#

class puppetvagrant {
  $vagrant_home = '/home/vagrant'
  $root_home    = '/root'

  include rhel
  include rvm

  Class['rhel'] -> Class['common'] -> Class['rvm']

  class {'common':
    vagrant_home => $vagrant_home,
    root_home    => $root_home,
  }
}
