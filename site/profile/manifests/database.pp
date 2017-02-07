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
        password                 => 'gu3sss0mep4ssw0rds4r3justst4t1c',
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
      'datacenter' => 'demo',
      'log_level'  => 'INFO',
      'node_name'  => $::fqdn,
      'retry_join' => ['consul.hashicorp.demo'],
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
