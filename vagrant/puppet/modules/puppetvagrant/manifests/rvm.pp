class puppetvagrant::rvm {
  class { '::rvm':
    proxy_url    => $::http_proxy
  }

  rvm::system_user { vagrant: }

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
      target_ruby => 'ruby-2.1.6@puppet',
      ensure      => present,
      require     => Rvm_gemset['ruby-2.1.6@puppet'];
  }

  file { ['/etc/gemrc', '/home/vagrant/.gemrc', '/root/.gemrc']:
      ensure =>  present,
      content => template('puppetvagrant/gemrc.erb')
  } ->
  rvm_gem {
  'ruby-2.1.6@puppet/bundler':
    ensure  => 'latest',
    require => Rvm_gemset['ruby-2.1.6@puppet'],
  }

  file_line { 'rvm use puppet':
    ensure => present,
    path   => '/home/vagrant/.bash_profile',
    line   => 'rvm use puppet'
  }
}
