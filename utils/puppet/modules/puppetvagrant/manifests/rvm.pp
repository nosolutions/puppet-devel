# install and configure rvm
#
class puppetvagrant::rvm {

  class { '::rvm':
    key_server => 'hkp://pgp.mit.edu'
  }

  $ruby_version = '2.1.10'

  if $::http_proxy and $::http_proxy != "" {
    Rvm_gem {
      proxy_url => "http://${::http_proxy}"
    }

    Class['::rvm'] {
      proxy_url => $http_proxy
    }
  }

  rvm::system_user { 'vagrant': }

  rvm_system_ruby {
    "ruby-${ruby_version}":
      ensure      => 'present',
  }

  rvm_gemset {
    "ruby-${ruby_version}@puppet":
      ensure  => present,
      require => Rvm_system_ruby["ruby-${ruby_version}"];
  }

  rvm_alias {
    'puppet':
      ensure      => present,
      target_ruby => "ruby-${ruby_version}@puppet",
      require     => Rvm_gemset["ruby-${ruby_version}@puppet"];
  }

  file { ['/etc/gemrc', '/home/vagrant/.gemrc', '/root/.gemrc']:
      ensure  =>  file,
      content => template('puppetvagrant/gemrc.erb')
  } ->
  rvm_gem { "ruby-${ruby_version}@puppet/bundler":
    ensure  => 'latest',
    require => Rvm_gemset["ruby-${ruby_version}@puppet"],
  }

  file_line { 'ignore_project_rvmrc':
    ensure => present,
    path   => '/etc/rvmrc',
    line   => 'rvm_project_rvmrc=0',
  }
}
