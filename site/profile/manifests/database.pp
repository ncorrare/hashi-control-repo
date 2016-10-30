class profile::database {
  include profile::base
  class { '::mysql::server':
    override_options => {
     'mysqld' => {
       'bind-address' => '0.0.0.0',
     }
  }
  mysql_user { 'vault@*':
    ensure => 'present',
  }
  mysql_grant { 'vault@*/*.*':
    ensure     => 'present',
    options    => ['GRANT'],
    privileges => ['ALL'],
    table      => '*.*',
    user       => 'vault@*',
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
