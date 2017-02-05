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
      'datacenter' => 'demo',
      'log_level'  => 'INFO',
      'node_name'  => $::fqdn,
      'retry_join' => 'consul.hashicorp.demo',
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
    tags    => ['caching','memcache','production']
  }
}

