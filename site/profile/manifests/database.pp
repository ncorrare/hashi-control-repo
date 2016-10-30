class profile::database {
  include profile::base
  class { '::mysql::server':
    override_options => {
     'mysqld' => {
       'bind-address' => '0.0.0.0',
     }
  }
  mysql_user { 'vault@%':
    ensure => 'present',
  }
  mysql_grant { 'vault@%/*.*':
    ensure     => 'present',
    options    => ['GRANT'],
    privileges => ['ALL'],
    table      => '*.*',
    user       => 'vault@%',
    notify     => Exec['provision-password'],
  }
  #This is a rather hacky way to provision the database password. Basically this script would be waiting for the vault server to be available and give it the password (which we assume it will happen within a minute of this server being available. Don't do this at home, basically.
  exec { 'provision-password':
    command   => '/bin/curl https://raw.githubusercontent.com/ncorrare/terraform-examples/master/setmysqlpassword.sh | /bin/bash',
    tries     => 6,
    try_sleep => 10,
    require   => Class['consul'],
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
