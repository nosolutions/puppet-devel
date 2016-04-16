class puppetvagrant::proxy {

  if $::http_proxy {
    file_line { 'yum proxy':
      ensure => present,
      path   => '/etc/yum.conf',
      line   => "proxy=http://${::http_proxy}"
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
