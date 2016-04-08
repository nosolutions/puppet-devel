class puppetvagrant::setup {
  if $::http_proxy and $::http_proxy != "" {
    Exec {
      environment => ["http_proxy=http://${::http_proxy}", "https_proxy=http://${::http_proxy}"],
    }
  }

  exec { 'bundle_install.sh':
    cwd  => '/vagrant',
    path => ['/vagrant/utils'],
    user => 'vagrant',
  }

  exec { 'module_skeleton.sh':
    cwd  => '/vagrant',
    path => ['/vagrant/utils'],
    user => 'vagrant',
  }

  file { '/etc/puppet/local':
    ensure => 'link',
    target => '/vagrant/modules'
  }

  file { '/etc/puppet/environments':
    ensure => 'directory',
  }

  file { '/etc/puppet/environments/production':
    ensure  => 'directory',
    require => File['/etc/puppet/environments']
  }

  file { '/etc/puppet/environments/production/local':
    ensure  => 'link',
    target  => '/vagrant/modules',
    require => File['/etc/puppet/environments/production']
  }

  file { '/etc/puppet/environments/production/site':
    ensure  => 'link',
    target  => '/vagrant/puppet/site',
    require => File['/etc/puppet/environments/production']
  }

  file { '/etc/puppet/puppet.conf':
    ensure => 'file',
    source => 'puppet:///modules/puppetvagrant/puppet.conf'
  }

  file { '/etc/puppet/environments/production/environment.conf':
    ensure => 'file',
    source => 'puppet:///modules/puppetvagrant/environment.conf'
  }

  file { '/home/vagrant/.bashrc':
    ensure => 'file',
    content => template('puppetvagrant/bashrc.erb')
  }

  file { '/home/vagrant/.git-prompt.sh':
    ensure => 'file',
    source => 'puppet:///modules/puppetvagrant/git-prompt.sh'
  }

  file { '/home/vagrant/.git-completion.bash':
    ensure => 'file',
    source => 'puppet:///modules/puppetvagrant/git-completion.bash'
  }

  file { '/home/vagrant/.rake-completion.bash':
    ensure => 'file',
    source => 'puppet:///modules/puppetvagrant/rake.sh'
  }

  file { '/home/vagrant/.bash_profile':
    ensure => 'file',
    source => 'puppet:///modules/puppetvagrant/bash_profile'
  }

  service { 'firewalld':
    ensure => 'stopped',
    enable => false,
  }

}
