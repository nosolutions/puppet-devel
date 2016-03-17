class puppetvagrant::jenkins {
  class { 'jenkins':
    proxy_host         => $::http_proxy,
    proxy_port         => '8080',
    configure_firewall => false,
    config_hash        => {
      'JENKINS_PORT' => { 'value' => '8081' },
      'HTTP_PORT'    => { 'value' => '8081' },
    }
  }

  jenkins::plugin { 'credentials':
    version => '1.24',
    notify  => Service['jenkins']
    } ->
  jenkins::plugin { 'ssh-credentials':
    version => '1.11',
    notify  => Service['jenkins']
  } ->
  jenkins::plugin { 'scm-api':
    version => '0.2',
    notify  => Service['jenkins']
  } ->
  jenkins::plugin { 'git':
    version => '2.4.0',
    notify  => Service['jenkins']
  } ->
  jenkins::plugin { 'git-client':
    version => '1.19.0',
    notify  => Service['jenkins']
  } ->
  jenkins::plugin { 'ruby-runtime':
    version => '0.12',
    notify  => Service['jenkins']
  } ->
  jenkins::plugin { 'gitlab-hook':
    version => '1.4.0',
    notify  => Service['jenkins']
  }

  file { '/home/vagrant/.ssh/id_rsa':
    ensure => file,
    owner  => 'vagrant',
    group  => 'vagrant',
    mode   => '0600',
    source => 'puppet:///modules/puppetvagrant/gitlab'
  } ->
  jenkins::credentials { 'jenkins-deploy-key':
    password            => '',
    private_key_or_path => '/home/vagrant/.ssh/id_rsa',
    uuid                => 'jenkins-ssh-key',
  }

  file { '/home/vagrant/.ssh/id_rsa.pub':
    ensure => file,
    owner  => 'vagrant',
    group  => 'vagrant',
    mode   => '0600',
    source => 'puppet:///modules/puppetvagrant/gitlab.pub'
  }

}
