class puppetvagrant::gitlab {
  file { '/etc/gitlab':
    ensure => 'directory',
    mode   => '0700',
    owner  => 'root',
    group  => 'root',
  } ->
  file { '/etc/gitlab/ssl':
    ensure => 'directory',
    mode   => '0700',
    owner  => 'root',
    group  => 'root',
  } ->
  file {'/etc/gitlab/ssl/localhost.crt':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0600',
    source => 'puppet:///modules/puppetvagrant/localhost.crt'
  }  ->
  file {'/etc/gitlab/ssl/localhost.key':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0600',
    source => 'puppet:///modules/puppetvagrant/localhost.key',
    # notify => Exec['reconfigure_gitlab']
  } ->
  class { 'gitlab':
    external_url => 'https://localhost',
  }
}
