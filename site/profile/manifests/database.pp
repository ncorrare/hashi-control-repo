class profile::database {
  include profile::base
  class { '::mysql::server':
    override_options => {
     'mysqld' => {
       'bind-address' => '0.0.0.0',
     }
    },
    users => {
      'vault@%' => {
        ensure                   => 'present',
        max_connections_per_hour => '0',
        max_queries_per_hour     => '0',
        max_updates_per_hour     => '0',
        max_user_connections     => '0',
        password_hash            => '*EBF77CA105EA04A4A6DF363D804A00530B3AB248',
      }
    },
  }

  mysql_grant { 'vault@%/*.*':
    ensure     => 'present',
    options    => ['GRANT'],
    privileges => ['ALL'],
    table      => '*.*',
    user       => 'vault@%',
  }

  class { '::consul':
    config_hash => {
      'data_dir'   => '/opt/consul',
      'datacenter' => 'enablement',
      'bind_addr'  => $facts['networking']['interfaces']['eth0']['ip'],
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
    tags    => ['production','mysql','persistence']
  }
}
