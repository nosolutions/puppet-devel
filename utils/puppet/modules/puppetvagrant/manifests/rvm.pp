# install and configure rvm
#
class puppetvagrant::rvm {
  class { '::rvm':
    proxy_url    => $::http_proxy
  }

  if $::http_proxy {
    Rvm_gem {
      proxy_url => "http://${::http_proxy}"
    }
  }

  rvm::system_user { 'vagrant': }

  rvm_system_ruby {
    'ruby-2.1.6':
      ensure      => 'present',
  }

  rvm_gemset {
    'ruby-2.1.6@puppet':
      ensure  => present,
      require => Rvm_system_ruby['ruby-2.1.6'];
  }

  rvm_alias {
    'puppet':
      ensure      => present,
      target_ruby => 'ruby-2.1.6@puppet',
      require     => Rvm_gemset['ruby-2.1.6@puppet'];
  }

  file { ['/etc/gemrc', '/home/vagrant/.gemrc', '/root/.gemrc']:
      ensure  =>  file,
      content => template('puppetvagrant/gemrc.erb')
  } ->
  rvm_gem { 'ruby-2.1.6@puppet/bundler':
    ensure  => 'latest',
    require => Rvm_gemset['ruby-2.1.6@puppet'],
  }

  file_line { 'ignore_project_rvmrc':
    ensure => present,
    path   => '/etc/rvmrc',
    line   => 'rvm_project_rvmrc=0',
  }
}
