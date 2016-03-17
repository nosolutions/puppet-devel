# install required packages
#
class puppetvagrant::packages {
  Package {
    allow_virtual => false,
  }

  package { 'git':
    ensure => installed,
  }

  package { 'augeas-devel':
    ensure => installed,
  }
}
