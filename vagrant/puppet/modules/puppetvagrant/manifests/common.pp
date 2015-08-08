class common (
  $vagrant_home = '',
  $root_home    = ''
  ){

  if $vagrant_home == '' {
    $real_vagrant_home = '/home/vagrant'
  }
  else {
    $real_vagrant_home = $vagrant_home
  }

  if $root_home == '' {
    $real_root_home = '/root'
  }
  else {
    $real_root_home = $root_home
  }

  host {
    'puppet':     ip => '192.168.1.2';
    'centos7':     ip => '192.168.1.2';
    'centos6':   ip => '192.168.1.3';
    'centos5':   ip => '192.168.1.4';
  }

  # hiera config template files,
  # maybe used for testing hiera
  #
  file { '/etc/hiera.yaml':
    source => '/vagrant/vagrant/puppet/files/hiera.yaml',
    owner  => 'root',
    group  => 'root',
  }

  file { '/etc/puppet/hiera.yaml':
    ensure => 'link',
    target => '/etc/hiera.yaml',
  }

  file { 'puppet.conf':
    path   => '/etc/puppet/puppet.conf',
    source => '/vagrant/vagrant/puppet/files/puppet.conf',
    owner  => 'root',
    group  => 'root',
  }

  file { '/var/lib/hiera/defaults.yaml':
    ensure  => present,
    replace => no,
    mode    => '0644',
    content => "---\n",
  }

  file { '/var/lib/hiera/global.yaml':
    ensure  => present,
    replace => no,
    mode    => '0644',
    content => "---\n",
  }
}
