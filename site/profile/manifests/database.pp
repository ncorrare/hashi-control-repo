class profile::database {
  include profile::base
  include '::mysql::server'
  class { '::consul':
    config_hash => {
      'data_dir'   => '/opt/consul',
      'datacenter' => 'aws',
      'log_level'  => 'INFO',
      'node_name'  => $::fqdn,
      'retry_join' => [$::consulserver],
    }
  }
  consul::service { 'mysql':
    checks  => [
      {
        script   => '/bin/mysql -u root -e "SELECT 1" > /dev/null',
        interval => '10s'
      }
    ],
    port    => 3306,
    tags    => ['blogs']
  }
}
