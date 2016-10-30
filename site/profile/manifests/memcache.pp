class profile::memcache {
  include profile::base
  package { 'memcached':
    ensure => present,
  }
  service { 'memcached':
    ensure  => running,
    enable  => true,
    require => Package['memcached'],
  }
  class { '::consul':
    config_hash => {
      'data_dir'   => '/opt/consul',
      'datacenter' => 'aws',
      'log_level'  => 'INFO',
      'node_name'  => $::fqdn,
      'retry_join' => [$::consulserver],
    }
  }
  consul::service { 'memcached':
    checks  => [
      {
        script   => "/bin/memstat --servers=$::fqdn",
        interval => '10s'
      }
    ],
    port    => 11211,
    tags    => ['blogs']
  }
}

