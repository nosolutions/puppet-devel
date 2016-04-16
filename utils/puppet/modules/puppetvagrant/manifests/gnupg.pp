class puppetvagrant::gnupg {
  exec { 'create_gpgconf':
      command => 'gpg -k',
      path    => '/usr/bin:/bin',
  } ->
  file { '/root/.gnupg/gpg.conf':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0600',
    content => template('puppetvagrant/gpg.conf.erb')
  }
}
