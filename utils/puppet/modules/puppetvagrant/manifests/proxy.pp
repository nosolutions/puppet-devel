class puppetvagrant::proxy {

  if $::http_proxy {
    file_line { 'yum proxy':
      ensure => present,
      path   => '/etc/yum.conf',
      line   => "proxy=http://${::http_proxy}"
    }

    exec { 'create_gpgconf':
      command => 'gpg -k',
      path    => '/usr/bin:/bin',
    } ->
    file_line { 'gpg_conf':
      ensure => present,
      path   => '/root/.gnupg/gpg.conf',
      line   => "keyserver-options http-proxy=${::http_proxy}"
    }

    file { '/root/.curlrc':
      ensure => present,
    } ->
    file_line { 'curlrc':
      ensure => present,
      path   => '/root/.curlrc',
      line   => "proxy = ${::http_proxy}"
    }
  }
}
