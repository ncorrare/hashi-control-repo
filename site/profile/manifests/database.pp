class profile::database {
  include '::mysql::server'
  class { '::consul':
    config_hash => {
      'data_dir'   => '/opt/consul',
      'datacenter' => 'east-aws',
      'log_level'  => 'INFO',
      'node_name'  => $::fqdn,
      'retry_join' => [$::consulserver],
    }
  }
  consul::service { 'redis':
    #checks  => [
    #  {
    #    script   => '/usr/local/bin/check_redis.py',
    #    interval => '10s'
    #  }
    #],
    port    => 3306,
    tags    => ['blogs']
  }
}
